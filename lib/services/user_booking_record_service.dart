import 'dart:convert';

import 'package:ticketing_flutter/services/api_client.dart';

/// Persists and loads mobile booking snapshots via `UserBookingRecords` API.
/// Auth: `Authorization: Bearer <session token>` from `/api/Auth/login`.
class UserBookingRecordService {
  UserBookingRecordService() : _api = ApiClient();

  final ApiClient _api;

  /// Maps the local SharedPreferences-style entry to API PascalCase JSON.
  Map<String, dynamic> pascalRequestFromLocalEntry(Map<String, dynamic> e) {
    final guests = e['guestsCount'];
    final guestsCount = guests is int
        ? guests
        : int.tryParse('$guests') ?? 0;
    final total = e['total'];
    final totalAmount = total is num
        ? total.toDouble()
        : double.tryParse('$total') ?? 0.0;

    return {
      'BookingRef': e['bookingRef']?.toString() ?? '',
      'FromDisplay': e['from']?.toString() ?? '',
      'ToDisplay': e['to']?.toString() ?? '',
      'FlightNumber': e['flightNumber']?.toString() ?? '',
      'DateDisplay': e['date']?.toString() ?? '',
      'TimeDisplay': e['time']?.toString() ?? '',
      'Airline': e['airline']?.toString() ?? '',
      'TravelClass': e['travelClass']?.toString() ?? '',
      'BundleName': e['bundle']?.toString() ?? '',
      'GuestsCount': guestsCount,
      'TotalAmount': totalAmount,
      'PaymentMethod': e['paymentMethod']?.toString() ?? '',
      'DetailsJson': jsonEncode(e),
    };
  }

  /// Returns rows in the same shape as local prefs (`from`, `to`, `bookingRef`, …).
  Map<String, dynamic> normalizeApiRow(Map<String, dynamic> r) {
    String pickStr(List<String> keys) {
      for (final k in keys) {
        final v = r[k];
        if (v != null) return v.toString();
      }
      return '';
    }

    num pickNum(List<String> keys) {
      for (final k in keys) {
        final v = r[k];
        if (v is num) return v;
        if (v != null) return num.tryParse(v.toString()) ?? 0;
      }
      return 0;
    }

    int pickInt(List<String> keys) {
      final n = pickNum(keys);
      return n.round();
    }

    return {
      'bookingRef': pickStr(['BookingRef', 'bookingRef']),
      'from': pickStr(['FromDisplay', 'fromDisplay']),
      'to': pickStr(['ToDisplay', 'toDisplay']),
      'flightNumber': pickStr(['FlightNumber', 'flightNumber']),
      'date': pickStr(['DateDisplay', 'dateDisplay']),
      'time': pickStr(['TimeDisplay', 'timeDisplay']),
      'airline': pickStr(['Airline', 'airline']),
      'travelClass': pickStr(['TravelClass', 'travelClass']),
      'bundle': pickStr(['BundleName', 'bundleName']),
      'guestsCount': pickInt(['GuestsCount', 'guestsCount']),
      'total': pickNum(['TotalAmount', 'totalAmount']),
      'paymentMethod': pickStr(['PaymentMethod', 'paymentMethod']),
      'bookedAt': pickStr(['CreatedAtUtc', 'createdAtUtc']),
    };
  }

  /// `null` = offline / error (caller may fall back to local prefs). `[]` = no rows in DB.
  Future<List<Map<String, dynamic>>?> fetchMineNormalized() async {
    if (ApiClient.useMock) return null;

    final res = await _api.get('/UserBookingRecords/me');
    if (res.statusCode != 200) return null;

    final decoded = jsonDecode(res.body);
    if (decoded is! List) return [];

    return decoded
        .map(
          (e) => normalizeApiRow(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<bool> createFromLocalEntry(Map<String, dynamic> localEntry) async {
    if (ApiClient.useMock) return true;

    final token = await _api.getToken();
    if (token == null || token.isEmpty) return false;

    final body = pascalRequestFromLocalEntry(localEntry);
    final res = await _api.post('/UserBookingRecords', body: body);
    return res.statusCode == 200 || res.statusCode == 201;
  }
}
