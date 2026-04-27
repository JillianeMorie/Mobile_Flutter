import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketing_flutter/auth/login.dart';
import 'package:ticketing_flutter/services/mqtt_service.dart';
import 'package:ticketing_flutter/services/user_service.dart';
import 'package:ticketing_flutter/public/manage/manage.dart';
import 'package:ticketing_flutter/public/travel_info.dart';
import 'package:ticketing_flutter/public/explore.dart';
import 'package:ticketing_flutter/user/userabout.dart';
import 'package:ticketing_flutter/user/user_tracker_map_page.dart';
import 'package:ticketing_flutter/public/bookpage.dart';
import 'dart:convert';

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
  double? _lastLatitude;
  double? _lastLongitude;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _mqttLocationService.disconnect();
    super.dispose();
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
    final bookedFlights = await _loadBookedFlights();
    if (mounted) {
      setState(() {
        _user = user;
        _bookedFlights = bookedFlights;
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadBookedFlights() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'user_booking_history';
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
    final service = UserService();
    await service.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _trackLuggage() async {
    final trackerId = _autoTrackerId;
    if (trackerId == null || trackerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tracker ID found for this account yet'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() {
      _isSearchingLuggage = true;
      _luggageStatus = 'Connecting to tracker...';
    });

    await _mqttLocationService.disconnect();

    await _mqttLocationService.subscribeToTracker(
      broker: '192.168.57.163',
      port: 1883,
      topic: 'jose/betonio/loc',
      useWebSocket: false,
      useTls: false,
      onStatus: (status) {
        if (!mounted) return;
        setState(() {
          _isSearchingLuggage = false;
          _luggageStatus = status;
        });
      },
      onData: (data) {
        if (!mounted) return;
        setState(() {
          if (data.latitude != null && data.longitude != null) {
            _lastLatitude = data.latitude;
            _lastLongitude = data.longitude;
            final ts = data.timestamp ?? DateTime.now().toIso8601String();
            _luggageStatus =
                'Live GPS\nLat: ${data.latitude}\nLng: ${data.longitude}\nUpdated: $ts';
          } else {
            _luggageStatus = 'MQTT payload: ${data.rawPayload}';
          }
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isSearchingLuggage = false;
          _luggageStatus = error;
        });
      },
    );
  }

  String? get _autoTrackerId {
    // Test mode: fixed tracker id to match terminal publish command.
    return 'tracker123';

    /*
    if (_bookedFlights.isNotEmpty) {
      final latest = _bookedFlights.first;
      final candidates = [
        latest['trackerId'],
        latest['luggageTrackerId'],
        latest['tagNumber'],
        latest['bookingRef'],
      ];
      for (final candidate in candidates) {
        final value = candidate?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    final userId = _readField(['UserId', 'userId', 'id']);
    if (userId != null && userId.trim().isNotEmpty) {
      return 'user_$userId';
    }
    return null;
    */
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
          Text(
            _autoTrackerId == null
                ? 'Topic: jose/betonio/loc'
                : 'Topic: jose/betonio/loc (Tracker: $_autoTrackerId)',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _luggageStatus!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
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
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 5, 23, 37),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _logout,
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              title: const Text('Book', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const FlightBookingApp(),
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
                        const ManagePage(),
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
                        const TravelInfoPage(),
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
                        const ExplorePage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
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
    );
  }
}
