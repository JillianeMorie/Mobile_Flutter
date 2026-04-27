import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // When true the client will simulate backend responses in-memory.
  // Set to false to use a real backend via `baseUrl`.
  static bool useMock = false;

  // In-memory mock storage for users (only used when `useMock == true`).
  final Map<int, Map<String, dynamic>> _mockUsers = {};
  int _nextMockUserId = 1;

  // TODO: Update this with your actual backend URL
  // For local development, use: http://10.0.2.2:5241 (Android emulator -> host)
  // For physical device, use your computer's IP: http://192.168.x.x:5241
  static const String baseUrl = "http://10.0.20.237:5241/api";

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // Get stored authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save authentication token
  Future<void> saveToken(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
  }

  // Clear authentication token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  // Get current user ID
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Make authenticated GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    // Mock mode: support fetching user details.
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (endpoint.startsWith('/users/')) {
        final idStr = endpoint.substring('/users/'.length);
        final id = int.tryParse(idStr);
        if (id == null) {
          return http.Response(
            jsonEncode({'error': 'Invalid user id'}),
            400,
            headers: {'content-type': 'application/json'},
          );
        }
        final user = _mockUsers[id];
        if (user == null) {
          return http.Response(
            jsonEncode({'error': 'User not found'}),
            404,
            headers: {'content-type': 'application/json'},
          );
        }
        final safeUser = Map<String, dynamic>.from(user)..remove('Password');
        return http.Response(
          jsonEncode(safeUser),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response(
        jsonEncode({'error': 'Mock: endpoint not implemented'}),
        404,
        headers: {'content-type': 'application/json'},
      );
    }

    final token = await getToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: defaultHeaders,
    );
  }

  // Make authenticated POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await getToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // Make authenticated PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final token = await getToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  // Make authenticated DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final token = await getToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: defaultHeaders,
    );
  }

  // Make unauthenticated POST request (for login/register)
  Future<http.Response> postUnauthenticated(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    // Mock mode: simulate register/login endpoints without a backend.
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 700));
      // Register endpoint
      if (endpoint == '/users/register') {
        final email = (body?['Email'] ?? body?['email'])?.toString() ?? '';
        // Check if email already exists
        final exists = _mockUsers.values.any(
          (u) =>
              (u['Email'] ?? '').toString().toLowerCase() ==
              email.toLowerCase(),
        );
        if (exists) {
          return http.Response(
            jsonEncode({'error': 'Email already registered'}),
            400,
            headers: {'content-type': 'application/json'},
          );
        }
        final id = _nextMockUserId++;
        _mockUsers[id] = {
          'userId': id,
          'FirstName': body?['FirstName'] ?? '',
          'MiddleName': body?['MiddleName'] ?? '',
          'LastName': body?['LastName'] ?? '',
          'Email': email,
          'PhoneNumber': body?['PhoneNumber'] ?? '',
          'DateOfBirth': body?['DateOfBirth'] ?? '',
          'Gender': body?['Gender'] ?? '',
          'Password': body?['Password'] ?? '',
        };
        return http.Response('', 201);
      }

      // Login endpoint
      if (endpoint == '/auth/login') {
        final email = (body?['Email'] ?? body?['email'])?.toString() ?? '';
        final password =
            (body?['Password'] ?? body?['password'])?.toString() ?? '';
        int? foundId;
        for (final entry in _mockUsers.entries) {
          final stored = entry.value;
          if ((stored['Email'] ?? '').toString().toLowerCase() ==
                  email.toLowerCase() &&
              (stored['Password'] ?? '') == password) {
            foundId = entry.key;
            break;
          }
        }
        if (foundId != null) {
          final token = 'mock-token-$foundId';
          return http.Response(
            jsonEncode({'token': token, 'userId': foundId}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({'error': 'Invalid credentials'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }

      // Not implemented in mock
      return http.Response(
        jsonEncode({'error': 'Mock: endpoint not implemented'}),
        404,
        headers: {'content-type': 'application/json'},
      );
    }
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
  }
}
