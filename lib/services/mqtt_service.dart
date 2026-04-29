import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttLocationData {
  final double? latitude;
  final double? longitude;
  final String? timestamp;
  final String rawPayload;

  const MqttLocationData({
    required this.rawPayload,
    this.latitude,
    this.longitude,
    this.timestamp,
  });
}

class MqttLocationService {
  MqttServerClient? _client;
  StreamSubscription? _updatesSub;
  int _subscriptionVersion = 0;
  bool _manualDisconnect = false;

  Future<void> subscribeToTracker({
    required String broker,
    required int port,
    String? trackerId,
    String? topic,
    bool useWebSocket = false,
    bool useTls = false,
    required void Function(String status) onStatus,
    required void Function(MqttLocationData data) onData,
    required void Function(String error) onError,
  }) async {
    final currentVersion = ++_subscriptionVersion;
    var hasConnectedOnce = false;
    final resolvedTopic =
        topic ??
        (trackerId == null ? null : 'airline/luggage/$trackerId/location');
    if (resolvedTopic == null || resolvedTopic.isEmpty) {
      onError('No MQTT topic provided.');
      return;
    }
    // MQTT 3.1.1 client id max 23 chars.
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final clientId = 'fl${stamp % 10000000000000}';
    final client = MqttServerClient(broker, clientId)
      ..port = port
      ..keepAlivePeriod = 20
      ..logging(on: false)
      ..useWebSocket = useWebSocket
      ..secure = useTls
      ..autoReconnect = true;
    client.setProtocolV311();
    client
      ..onConnected = () {
        if (currentVersion != _subscriptionVersion) return;
        hasConnectedOnce = true;
        onStatus('Connected to MQTT');
      }
      ..onDisconnected = () {
        if (currentVersion != _subscriptionVersion || _manualDisconnect) return;
        if (!hasConnectedOnce) {
          onError('Connection failed: broker disconnected during handshake.');
          return;
        }
        onStatus('Disconnected from MQTT');
      };
    if (useWebSocket) {
      client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    }
    client.onSubscribed = (subscribedTopic) {
      if (currentVersion != _subscriptionVersion) return;
      onStatus('Subscribed to $subscribedTopic');
    };
    // Do not set Will QoS without will topic + message — brokers reject that CONNECT.
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();

    try {
      onStatus(
        'Connecting to MQTT... ($broker:$port${useWebSocket ? " ws" : " tcp"}${useTls ? " tls" : ""})',
      );
      final status = await client.connect();
      if (status?.state != MqttConnectionState.connected) {
        if (currentVersion != _subscriptionVersion) return;
        onError('MQTT connection failed: ${status?.state}');
        client.disconnect();
        return;
      }

      _client = client;
      client.subscribe(resolvedTopic, MqttQos.atLeastOnce);
      onStatus('Connected. Waiting for data on $resolvedTopic');

      _updatesSub = client.updates?.listen((messages) {
        if (currentVersion != _subscriptionVersion) return;
        if (messages.isEmpty) return;
        final payloadMessage = messages.first.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          payloadMessage.payload.message,
        );

        try {
          final json = jsonDecode(payload);
          if (json is Map<String, dynamic>) {
            final lat = _toDouble(json['latitude'] ?? json['lat']);
            final lng = _toDouble(json['longitude'] ?? json['lng']);
            final ts = json['timestamp']?.toString();
            onData(
              MqttLocationData(
                rawPayload: payload,
                latitude: lat,
                longitude: lng,
                timestamp: ts,
              ),
            );
            return;
          }
        } catch (_) {
          // non-json payload fallback
        }

        onData(MqttLocationData(rawPayload: payload));
      });
    } catch (e) {
      if (currentVersion != _subscriptionVersion) return;
      onError('MQTT error: $e');
      client.disconnect();
    }
  }

  Future<void> disconnect() async {
    _manualDisconnect = true;
    await _updatesSub?.cancel();
    _updatesSub = null;
    _client?.disconnect();
    _client = null;
    _manualDisconnect = false;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
