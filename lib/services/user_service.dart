import 'dart:convert';
import 'package:ticketing_flutter/services/api_client.dart';

class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const AuthResult({required this.success, required this.message, this.data});
}

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Register a new user
  Future<AuthResult> registerUser(Map<String, dynamic> userData) async {
    try {
      // Map Flutter app fields to backend DTO
      final requestBody = {
        "FirstName": userData["firstName"],
        "MiddleName": userData["middleName"],
        "LastName": userData["lastName"],
        "Email": userData["email"],
        "PhoneNumber": userData["contactNumber"],
        "Password": userData["password"],
        "DateOfBirth": userData["birthdate"], // Format: "YYYY-MM-DD"
        "Gender": userData["gender"],
      };

      final response = await _apiClient.postUnauthenticated(
        '/users/register',
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const AuthResult(
          success: true,
          message: 'Account registered successfully.',
        );
      } else {
        final message = _extractErrorMessage(
          response.body,
          fallback: 'Registration failed. Please try again.',
        );
        return AuthResult(success: false, message: message);
      }
    } catch (e) {
      return const AuthResult(
        success: false,
        message: 'Unable to reach the server. Please check your connection.',
      );
    }
  }

  /// Login user
  Future<AuthResult> loginUser(String email, String password) async {
    try {
      final requestBody = {"Email": email, "Password": password};

      final response = await _apiClient.postUnauthenticated(
        '/auth/login',
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final token =
            (responseData['Token'] ??
                    responseData['token'] ??
                    responseData['SessionToken'] ??
                    responseData['sessionToken'])
                ?.toString();
        final dynamic rawId = responseData['UserId'] ?? responseData['userId'];
        final int? userId = rawId is int
            ? rawId
            : rawId is num
                ? rawId.toInt()
                : int.tryParse(rawId?.toString() ?? '');

        // Save token and user ID (Auth API returns SessionToken, not JWT.)
        if (token != null && token.isNotEmpty && userId != null) {
          await _apiClient.saveToken(token, userId);
        }

        return AuthResult(
          success: true,
          message: 'Login successful.',
          data: responseData,
        );
      } else {
        final message = _extractErrorMessage(
          response.body,
          fallback: 'Invalid email or password.',
        );
        return AuthResult(success: false, message: message);
      }
    } catch (e) {
      return const AuthResult(
        success: false,
        message: 'Unable to reach the server. Please check your connection.',
      );
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _apiClient.clearToken();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _apiClient.isLoggedIn();
  }

  /// Get current user information
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userId = await _apiClient.getUserId();
      if (userId == null) return null;

      final response = await _apiClient.get('/users/$userId');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(String responseBody, {required String fallback}) {
    if (responseBody.isEmpty) return fallback;

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is String && decoded.isNotEmpty) {
        return decoded;
      }
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        final message = decoded['message'];
        if (error is String && error.isNotEmpty) return error;
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {
      // Fall back to plain response text below.
    }

    return responseBody;
  }
}
