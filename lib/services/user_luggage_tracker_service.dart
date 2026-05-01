import 'dart:convert';

import 'package:ticketing_flutter/services/api_client.dart';

/// Loads and saves luggage MQTT topic + last GPS via `UserLuggageTracker` API.
/// Auth: `Authorization: Bearer <session token>` from `/api/Auth/login`.
class UserLuggageTrackerService {
  UserLuggageTrackerService() : _api = ApiClient();

  final ApiClient _api;

  String _pickStr(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null) return v.toString();
    }
    return '';
  }

  double? _pickDouble(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is num) return v.toDouble();
      if (v != null) return double.tryParse(v.toString());
    }
    return null;
  }

  /// Normalized map: `mqttTopic`, `lastLatitude`, `lastLongitude`, `lastStatusText`, `updatedAtUtc`.
  /// `null` if offline / error / mock.
  Future<Map<String, dynamic>?> fetchMine() async {
    if (ApiClient.useMock) return null;

    final res = await _api.get('/UserLuggageTracker/me');
    if (res.statusCode != 200) return null;

    final m = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    return {
      'mqttTopic': _pickStr(m, ['MqttTopic', 'mqttTopic']),
      'lastLatitude': _pickDouble(m, ['LastLatitude', 'lastLatitude']),
      'lastLongitude': _pickDouble(m, ['LastLongitude', 'lastLongitude']),
      'lastStatusText': _pickStr(m, ['LastStatusText', 'lastStatusText']),
      'updatedAtUtc': _pickStr(m, ['UpdatedAtUtc', 'updatedAtUtc']),
    };
  }

  /// Only non-null fields are sent (server merges onto existing row).
  Future<bool> upsert({
    String? mqttTopic,
    double? lastLatitude,
    double? lastLongitude,
    String? lastStatusText,
  }) async {
    if (ApiClient.useMock) return true;

    final token = await _api.getToken();
    if (token == null || token.isEmpty) return false;

    final body = <String, dynamic>{};
    if (mqttTopic != null) body['MqttTopic'] = mqttTopic;
    if (lastLatitude != null) body['LastLatitude'] = lastLatitude;
    if (lastLongitude != null) body['LastLongitude'] = lastLongitude;
    if (lastStatusText != null) body['LastStatusText'] = lastStatusText;
    if (body.isEmpty) return true;

    final res = await _api.put('/UserLuggageTracker/me', body: body);
    return res.statusCode == 200;
  }

  /// Newest first. Each row is one persisted tracker update (topic and/or GPS).
  Future<List<Map<String, dynamic>>?> fetchHistoryMine({int limit = 500}) async {
    if (ApiClient.useMock) return null;

    final res = await _api.get('/UserLuggageTracker/history/me?limit=$limit');
    if (res.statusCode != 200) return null;

    final decoded = jsonDecode(res.body);
    if (decoded is! List) return [];

    return decoded.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return {
        'mqttTopic': _pickStr(m, ['MqttTopic', 'mqttTopic']),
        'latitude': _pickDouble(m, ['Latitude', 'latitude']),
        'longitude': _pickDouble(m, ['Longitude', 'longitude']),
        'statusText': _pickStr(m, ['StatusText', 'statusText']),
        'recordedAtUtc': _pickStr(m, ['RecordedAtUtc', 'recordedAtUtc']),
      };
    }).toList();
  }
}
