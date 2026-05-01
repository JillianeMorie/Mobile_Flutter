import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ticketing_flutter/widgets/disable_route_pop.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketing_flutter/auth/login.dart';
import 'package:ticketing_flutter/services/mqtt_service.dart';
import 'package:ticketing_flutter/services/user_service.dart';
import 'package:ticketing_flutter/services/api_client.dart';
import 'package:ticketing_flutter/services/user_booking_record_service.dart';
import 'package:ticketing_flutter/services/user_luggage_tracker_service.dart';
import 'package:ticketing_flutter/user/user_logout.dart';
import 'package:ticketing_flutter/user/user_manage/user_manage.dart';
import 'package:ticketing_flutter/user/user_travel_info.dart';
import 'package:ticketing_flutter/user/user_explore.dart';
import 'package:ticketing_flutter/user/userabout.dart';
import 'package:ticketing_flutter/user/user_tracker_map_page.dart';
import 'package:ticketing_flutter/user/user_bookpage.dart';

class UserAccountDetailsPage extends StatefulWidget {
  const UserAccountDetailsPage({super.key});

  @override
  State<UserAccountDetailsPage> createState() => _UserAccountDetailsPageState();
}

class _UserAccountDetailsPageState extends State<UserAccountDetailsPage> {
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _bookedFlights = [];
  bool _isLoading = true;
  String? _error;

  String? _luggageStatus;
  bool _isSearchingLuggage = false;
  final MqttLocationService _mqttLocationService = MqttLocationService();

  final TextEditingController _mqttTopicController = TextEditingController();
  double? _lastLatitude;
  double? _lastLongitude;
  DateTime? _lastLuggageLocationPersistUtc;

  static const Duration _luggageNoSignalTimeout = Duration(seconds: 25);
  int _luggageTrackSession = 0;
  bool _luggageGotValidGpsFix = false;
  bool _luggageTrackerFailed = false;
  Timer? _luggageNoSignalTimer;

  /// Public HiveMQ broker (TCP). Web client uses WebSockets to the same broker.
  static const String _mqttBroker = 'broker.hivemq.com';
  static const int _mqttPort = 1883;

  /// Shown while MQTT connects/subscribes — broker accepts any topic string; that is not device validation.
  static const String _luggageAwaitingGpsMessage =
      'Waiting for luggage data…\n';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _luggageNoSignalTimer?.cancel();
    _mqttTopicController.dispose();
    _mqttLocationService.disconnect();
    super.dispose();
  }

  void _cancelLuggageNoSignalTimer() {
    _luggageNoSignalTimer?.cancel();
    _luggageNoSignalTimer = null;
  }

  void _beginLuggageNoSignalWatch(int session) {
    _cancelLuggageNoSignalTimer();
    _luggageNoSignalTimer = Timer(_luggageNoSignalTimeout, () async {
      if (!mounted || session != _luggageTrackSession) return;
      if (_luggageGotValidGpsFix) return;
      await _mqttLocationService.disconnect();
      if (!mounted || session != _luggageTrackSession) return;
      setState(() {
        _isSearchingLuggage = false;
        _luggageTrackerFailed = true;
        _luggageStatus =
            'No luggage signal for this device ID. Check the ID and try again.';
        _lastLatitude = null;
        _lastLongitude = null;
      });
    });
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userService = UserService();
    final loggedIn = await userService.isLoggedIn();
    if (!loggedIn) {
      if (mounted) {
        setState(() {
          _error = 'You are not logged in. Please login again.';
          _isLoading = false;
        });
      }
      return;
    }

    final user = await userService.getCurrentUser();
    final bookedFlights = user == null
        ? <Map<String, dynamic>>[]
        : await _loadBookedFlights(user);
    if (mounted) {
      setState(() {
        _user = user;
        _bookedFlights = bookedFlights;
        _isLoading = false;
      });
    }
  }

  void _maybePersistLocationFromMqtt(
    String statusText,
    double lat,
    double lng,
  ) {
    if (ApiClient.useMock) return;
    final now = DateTime.now();
    if (_lastLuggageLocationPersistUtc != null &&
        now.difference(_lastLuggageLocationPersistUtc!) <
            const Duration(seconds: 12)) {
      return;
    }
    _lastLuggageLocationPersistUtc = now;
    var text = statusText;
    if (text.length > 500) text = text.substring(0, 500);
    unawaited(
      UserLuggageTrackerService().upsert(
        lastLatitude: lat,
        lastLongitude: lng,
        lastStatusText: text,
      ),
    );
  }

  String _bookingHistoryKeyForUser(Map<String, dynamic> user) {
    final userIdRaw =
        user['UserId'] ?? user['userId'] ?? user['Id'] ?? user['id'];
    final userId = userIdRaw?.toString().trim();
    if (userId != null && userId.isNotEmpty) {
      return 'user_booking_history_$userId';
    }

    final emailRaw = user['Email'] ?? user['email'];
    final email = emailRaw?.toString().trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      return 'user_booking_history_$email';
    }

    // Last fallback, kept for safety when user payload is incomplete.
    return 'user_booking_history';
  }

  Future<List<Map<String, dynamic>>> _loadBookedFlights(
    Map<String, dynamic> user,
  ) async {
    if (!ApiClient.useMock) {
      final fromApi = await UserBookingRecordService().fetchMineNormalized();
      if (fromApi != null) {
        return fromApi;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final key = _bookingHistoryKeyForUser(user);
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  String? _readField(List<String> keys) {
    if (_user == null) return null;
    for (final key in keys) {
      if (_user!.containsKey(key) && _user![key] != null) {
        return _user![key].toString();
      }
    }
    return null;
  }

  Future<void> _logout() async {
    await logoutUserAndShowLogin(context);
  }

  Future<void> _trackLuggage() async {
    final topic = _mqttTopicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter device ID'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _luggageTrackSession++;
    final session = _luggageTrackSession;
    _luggageGotValidGpsFix = false;
    _luggageTrackerFailed = false;
    _cancelLuggageNoSignalTimer();

    setState(() {
      _isSearchingLuggage = true;
      _luggageStatus = 'Connecting…';
      _lastLatitude = null;
      _lastLongitude = null;
    });

    _beginLuggageNoSignalWatch(session);

    if (!ApiClient.useMock) {
      unawaited(UserLuggageTrackerService().upsert(mqttTopic: topic));
    }

    await _mqttLocationService.disconnect();

    await _mqttLocationService.subscribeToTracker(
      broker: _mqttBroker,
      port: _mqttPort,
      trackerId: null,
      topic: topic,
      useWebSocket: false,
      useTls: false,
      onStatus: (status) {
        if (!mounted) return;
        if (status.contains('Disconnected from MQTT')) {
          return;
        }
        final connecting = status.toLowerCase().contains('connecting');
        setState(() {
          _luggageTrackerFailed = false;
          _isSearchingLuggage = true;
          _luggageStatus = connecting
              ? 'Connecting…'
              : _luggageAwaitingGpsMessage;
        });
      },
      onData: (data) {
        if (!mounted) return;
        final lat = data.latitude;
        final lng = data.longitude;
        var statusForPersist = _luggageStatus ?? '';
        if (lat != null && lng != null) {
          _luggageGotValidGpsFix = true;
          _cancelLuggageNoSignalTimer();
        }
        setState(() {
          if (lat != null && lng != null) {
            _luggageTrackerFailed = false;
            _isSearchingLuggage = false;
            _lastLatitude = lat;
            _lastLongitude = lng;
            final ts = data.timestamp ?? DateTime.now().toIso8601String();
            _luggageStatus = 'Live GPS\nLat: $lat\nLng: $lng\nUpdated: $ts';
            statusForPersist = _luggageStatus!;
          } else {
            _isSearchingLuggage = true;
            _luggageTrackerFailed = false;
            _luggageStatus =
                '$_luggageAwaitingGpsMessage\n\n'
                'Last message had no latitude/longitude — check device ID, topic, or payload format.';
            statusForPersist = _luggageStatus!;
          }
        });
        if (lat != null && lng != null) {
          _maybePersistLocationFromMqtt(statusForPersist, lat, lng);
        }
      },
      onError: (error) {
        _cancelLuggageNoSignalTimer();
        if (!mounted) return;
        setState(() {
          _isSearchingLuggage = false;
          _luggageTrackerFailed = true;
          _lastLatitude = null;
          _lastLongitude = null;
          _luggageStatus = 'Not connected\nFailed\n$error';
        });
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuggageTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.luggage, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text(
                'Luggage Tracker',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mqttTopicController,
            textInputAction: TextInputAction.done,
            scrollPadding: const EdgeInsets.only(bottom: 120, top: 100),
            decoration: InputDecoration(
              labelText: 'Enter Device ID:',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1E3A8A),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 5, 23, 37),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSearchingLuggage ? null : _trackLuggage,
              child: _isSearchingLuggage
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Track',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          if (_luggageStatus != null) ...[
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final failed = _luggageTrackerFailed;
                final live = (_luggageStatus ?? '').startsWith('Live GPS');
                final pending = !failed && !live;
                final bg = failed
                    ? Colors.red.shade50
                    : live
                    ? Colors.green.shade50
                    : Colors.blue.shade50;
                final border = failed
                    ? Colors.red.shade200
                    : live
                    ? Colors.green.shade200
                    : Colors.blue.shade200;
                final iconColor = failed
                    ? Colors.red.shade700
                    : live
                    ? Colors.green
                    : Colors.blue.shade700;
                final icon = failed
                    ? Icons.error_outline
                    : live
                    ? Icons.check_circle
                    : Icons.hourglass_top;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: iconColor, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _luggageStatus!,
                          style: TextStyle(
                            fontSize: 14,
                            color: failed
                                ? Colors.red.shade900
                                : pending
                                ? Colors.blue.shade900
                                : Colors.black87,
                            fontWeight: (failed || pending)
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          if (_lastLatitude != null && _lastLongitude != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E3A8A)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserTrackerMapPage(
                        latitude: _lastLatitude!,
                        longitude: _lastLongitude!,
                        statusText: _luggageStatus,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map, color: Color(0xFF1E3A8A)),
                label: const Text(
                  'Open tracker map page',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookedFlightsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flight_takeoff, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text(
                'Booked Flights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_bookedFlights.isEmpty)
            const Text(
              'No booked flights yet.',
              style: TextStyle(color: Colors.black54, fontSize: 15),
            )
          else
            ..._bookedFlights.map((booking) {
              final from = booking['from']?.toString() ?? '';
              final to = booking['to']?.toString() ?? '';
              final date = booking['date']?.toString() ?? '';
              final time = booking['time']?.toString() ?? '';
              final flightNo = booking['flightNumber']?.toString() ?? '';
              final travelClass = booking['travelClass']?.toString() ?? '';
              final total = booking['total'];
              final totalLabel = total is num
                  ? "PHP ${total.toStringAsFixed(2)}"
                  : 'N/A';
              final bookingRef = booking['bookingRef']?.toString() ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$from -> $to',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Flight: $flightNo'),
                    Text('Departure: $date $time'),
                    Text('Class: $travelClass'),
                    Text('Total: $totalLabel'),
                    if (bookingRef.isNotEmpty) Text('Reference: $bookingRef'),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildContent({
    required String? fullName,
    required String? email,
    required String? phone,
    required String? dob,
    required String? gender,
  }) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 16),
                if (fullName != null) _buildInfoItem('Name', fullName),
                if (email != null) _buildInfoItem('Email', email),
                if (phone != null) _buildInfoItem('Phone', phone),
                if (dob != null) _buildInfoItem('Birthdate', dob),
                if (gender != null) _buildInfoItem('Gender', gender),
                if (_user != null && _user!.containsKey('Nationality'))
                  _buildInfoItem(
                    'Nationality',
                    _user!['Nationality']?.toString() ?? '',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildBookedFlightsSection(),
          const SizedBox(height: 24),
          _buildLuggageTracker(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _readField(['FullName', 'fullName', 'fullname']);
    final email = _readField(['Email', 'email']);
    final phone = _readField(['PhoneNumber', 'phone']);
    var dob = _readField(['DateOfBirth', 'dateOfBirth', 'dob', 'birthdate']);
    if (dob != null && dob.contains('T')) {
      dob = dob.split('T')[0];
    }
    final gender = _readField(['Gender', 'gender']);

    return DisableRoutePop(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        drawer: Drawer(
          width: 300.0,
          backgroundColor: const Color(0xFF111827),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF000000),
                        Color(0xFF111827),
                        Color(0xFF1E3A8A),
                      ],
                    ),
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.flight, color: Colors.white),
                title: const Text(
                  'Book',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const UserFlightBookingApp(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.manage_accounts, color: Colors.white),
                title: const Text(
                  'Manage',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const UserManagePage(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.white),
                title: const Text(
                  'Travel Info',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const UserTravelInfoPage(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.explore, color: Colors.white),
                title: const Text(
                  'Explore',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const UserExplore(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text(
                  'About',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const Userabout(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.white),
                title: const Text(
                  'My Account',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _logout();
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF000000),
                          Color(0xFF111827),
                          Color(0xFF1E3A8A),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.blue.shade100,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 30,
              left: 10,
              child: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: _buildContent(
                  fullName: fullName,
                  email: email,
                  phone: phone,
                  dob: dob,
                  gender: gender,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
