import 'package:flutter/material.dart';
import 'package:ticketing_flutter/services/mqtt_service.dart';
import 'package:ticketing_flutter/services/user_service.dart';
import 'package:ticketing_flutter/user/user_tracker_map_page.dart';

class MyAccountDetailsPage extends StatefulWidget {
  const MyAccountDetailsPage({super.key});

  @override
  State<MyAccountDetailsPage> createState() => _MyAccountDetailsPageState();
}

class _MyAccountDetailsPageState extends State<MyAccountDetailsPage> {
  late final Future<Map<String, dynamic>?> _userFuture =
      UserService().getCurrentUser();

  final _trackerIdController = TextEditingController();
  final _topicController = TextEditingController();
  final _brokerController = TextEditingController(text: 'broker.hivemq.com');
  final _portController = TextEditingController(text: '1883');
  final MqttLocationService _mqttLocationService = MqttLocationService();

  bool _isSearchingLuggage = false;
  String? _luggageStatus;
  double? _lastLatitude;
  double? _lastLongitude;

  @override
  void dispose() {
    _trackerIdController.dispose();
    _topicController.dispose();
    _brokerController.dispose();
    _portController.dispose();
    _mqttLocationService.disconnect();
    super.dispose();
  }

  String? _readField(Map<String, dynamic>? m, List<String> keys) {
    if (m == null) return null;
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return null;
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
    );
  }

  Future<void> _trackLuggage() async {
    final trackerId = _trackerIdController.text.trim();
    final topicOverride = _topicController.text.trim();
    final broker = _brokerController.text.trim();
    final port = int.tryParse(_portController.text.trim());

    if (trackerId.isEmpty && topicOverride.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a luggage tracker device ID, or fill MQTT topic (optional field).',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (broker.isEmpty || port == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid MQTT broker and port.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSearchingLuggage = true;
      _luggageStatus = 'Connecting to MQTT...';
      _lastLatitude = null;
      _lastLongitude = null;
    });

    await _mqttLocationService.disconnect();

    await _mqttLocationService.subscribeToTracker(
      broker: broker,
      port: port,
      trackerId: topicOverride.isEmpty ? trackerId : null,
      topic: topicOverride.isEmpty ? null : topicOverride,
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

  Future<void> _stopLuggage() async {
    await _mqttLocationService.disconnect();
    if (!mounted) return;
    setState(() {
      _isSearchingLuggage = false;
      _luggageStatus = 'Tracking stopped.';
    });
  }

  Widget _buildLuggageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(color: Colors.white24, height: 32),
        const Text(
          'Luggage Tracker',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your device ID, then tap Track. If your hardware uses a fixed MQTT topic, fill that instead and leave device ID empty.',
          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _trackerIdController,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(
            'Device ID / Tracker number',
            hint: 'e.g. ABC123',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _topicController,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(
            'MQTT topic (optional)',
            hint: 'Leave empty → airline/luggage/<id>/location',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _brokerController,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('MQTT broker'),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDecoration('Port'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSearchingLuggage ? null : _trackLuggage,
                child: _isSearchingLuggage
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black87,
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
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _stopLuggage,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              child: const Text('Stop'),
            ),
          ],
        ),
        if (_luggageStatus != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              _luggageStatus!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
        if (_lastLatitude != null && _lastLongitude != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
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
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyanAccent,
              side: const BorderSide(color: Colors.cyanAccent),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.map),
            label: const Text('Open map'),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Account Details'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000000), Color(0xFF111827), Color(0xFF1E3A8A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Failed to load account details.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final user = snapshot.data;
                if (user == null) {
                  return const Center(
                    child: Text(
                      'No user details found. Please login again.',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final firstName =
                    _readField(user, ['FirstName', 'firstName', 'firstname']);
                final middleName =
                    _readField(user, ['MiddleName', 'middleName', 'middlename']);
                final lastName =
                    _readField(user, ['LastName', 'lastName', 'lastname']);
                final email = _readField(user, ['Email', 'email']);
                final phone = _readField(user, [
                  'PhoneNumber',
                  'phoneNumber',
                  'contactNumber',
                  'phone',
                ]);
                final dob = _readField(user, [
                  'DateOfBirth',
                  'dateOfBirth',
                  'birthdate',
                  'dob',
                ]);
                final gender = _readField(user, ['Gender', 'gender']);

                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _row('First name', firstName),
                        _row('Middle name', middleName),
                        _row('Last name', lastName),
                        _row('Email', email),
                        _row('Contact number', phone),
                        _row('Birthdate', dob),
                        _row('Gender', gender),
                        _buildLuggageSection(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
