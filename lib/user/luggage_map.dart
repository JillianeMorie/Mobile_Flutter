import 'package:flutter/material.dart';
import 'package:ticketing_flutter/widgets/disable_route_pop.dart';
import 'package:ticketing_flutter/services/mqtt_service.dart';

class LuggageMapPage extends StatefulWidget {
  final String? initialTrackerId;

  const LuggageMapPage({super.key, this.initialTrackerId});

  @override
  State<LuggageMapPage> createState() => _LuggageMapPageState();
}

class _LuggageMapPageState extends State<LuggageMapPage> {
  late final TextEditingController _trackerIdController = TextEditingController(
    text: widget.initialTrackerId ?? '',
  );
  final _brokerController = TextEditingController(text: 'broker.hivemq.com');
  final _portController = TextEditingController(text: '1883');
  final MqttLocationService _mqttService = MqttLocationService();

  bool _isTracking = false;
  String _status = 'Enter a tracker device ID and tap Track.';
  MqttLocationData? _lastData;

  @override
  void dispose() {
    _trackerIdController.dispose();
    _brokerController.dispose();
    _portController.dispose();
    _mqttService.disconnect();
    super.dispose();
  }

  Future<void> _startTracking() async {
    final trackerId = _trackerIdController.text.trim();
    final broker = _brokerController.text.trim();
    final port = int.tryParse(_portController.text.trim());

    if (trackerId.isEmpty) {
      _showMessage('Please enter a tracker device ID/number.');
      return;
    }
    if (broker.isEmpty || port == null) {
      _showMessage('Please enter a valid MQTT broker and port.');
      return;
    }

    setState(() {
      _isTracking = true;
      _status = 'Connecting...';
      _lastData = null;
    });

    await _mqttService.subscribeToTracker(
      broker: broker,
      port: port,
      trackerId: trackerId,
      onStatus: (message) {
        if (!mounted) return;
        setState(() => _status = message);
      },
      onData: (data) {
        if (!mounted) return;
        setState(() {
          _lastData = data;
          _status = 'Live update received';
        });
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _isTracking = false;
          _status = message;
        });
      },
    );
  }

  Future<void> _stopTracking() async {
    await _mqttService.disconnect();
    if (!mounted) return;
    setState(() {
      _isTracking = false;
      _status = 'Tracking stopped.';
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final latText = _lastData?.latitude?.toStringAsFixed(6) ?? '-';
    final lngText = _lastData?.longitude?.toStringAsFixed(6) ?? '-';
    final tsText = _lastData?.timestamp ?? '-';

    return DisableRoutePop(child: Scaffold(
      appBar: AppBar(title: const Text('Luggage Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _trackerIdController,
              decoration: const InputDecoration(
                labelText: 'Device ID / Tracker Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _brokerController,
                    decoration: const InputDecoration(
                      labelText: 'MQTT Broker',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isTracking ? _stopTracking : _startTracking,
              child: Text(_isTracking ? 'Stop Tracking' : 'Track'),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latitude: $latText'),
                    Text('Longitude: $lngText'),
                    Text('Timestamp: $tsText'),
                    const SizedBox(height: 8),
                    Text('Raw payload: ${_lastData?.rawPayload ?? '-'}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
