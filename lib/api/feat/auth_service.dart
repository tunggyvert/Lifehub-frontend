import '../api_service.dart';
import '../../models/user_model.dart';
import '../../core/storage/token_storage.dart';
import '../../core/storage/auth_prefs.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  AuthException(this.message, {this.statusCode, this.body});

  @override
  String toString() {
    final code = statusCode == null ? '' : ' statusCode=$statusCode';
    final b = body == null ? '' : ' body=$body';
    return 'AuthException($message$code$b)';
  }
}

class AuthService {
  final ApiService _client = ApiService();

  Future<void> login(String username, String password) async {
    debugPrint('[AuthService] Starting login for user: $username');

    if (username.isEmpty || password.isEmpty) {
      debugPrint('[AuthService] Empty username or password');
      throw AuthException('Username and password are required');
    }

    try {
      final response = await _client.post('/auth/login', {
        'username': username,
        'password': password,
      });

      debugPrint('[AuthService] Login response status: ${response.statusCode}');
      debugPrint('[AuthService] Login response body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          '[AuthService] Login failed with status: ${response.statusCode}',
        );
        throw AuthException(
          'Login failed',
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      final responseData = jsonDecode(response.body);
      debugPrint('[AuthService] Parsed response data: $responseData');

      if (responseData['success'] != true || responseData['token'] == null) {
        debugPrint(
          '[AuthService] Invalid response format: success=${responseData['success']}, token=${responseData['token']}',
        );
        throw AuthException(
          responseData['message'] ?? 'Login failed - no token received',
          statusCode: response.statusCode,
          body: response.body,
        );
      }

      await TokenStorage.saveToken(responseData['token']);
      await AuthPrefs.setLoggedIn(true);
      debugPrint('[AuthService] Token saved successfully');
    } catch (e) {
      debugPrint('[AuthService] Login error: $e');
      if (e is AuthException) rethrow;

      // Handle specific error types
      if (e.toString().contains('MissingPluginException')) {
        throw AuthException(
          'Secure storage not available - please restart the app',
        );
      } else if (e.toString().contains('Connection') ||
          e.toString().contains('Network')) {
        throw AuthException('Network connection failed');
      } else if (e.toString().contains('Timeout')) {
        throw AuthException('Request timeout - please try again');
      } else {
        throw AuthException('Login failed: $e');
      }
    }
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String confirmpassword,
  ) async {
    final response = await _client.post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
      'confirmpassword': confirmpassword,
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException(
        'Register failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final responseData = jsonDecode(response.body);
    if (responseData['success'] != true || responseData['token'] == null) {
      throw AuthException(
        responseData['message'] ?? 'Register failed - no token received',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    await TokenStorage.saveToken(responseData['token']);
    await AuthPrefs.setLoggedIn(true);
  }

  Future<User> profile(String token) async {
    final response = await _client.get('/auth/me', token: token);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException(
        'Cant GET Data',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final responseData = jsonDecode(response.body);
    if (responseData['success'] != true) {
      throw AuthException(
        responseData['message'] ?? 'Failed to get user data',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    return User.fromJson(responseData['data']);
  }

  Future<void> logout() async {
    try {
      final token = await TokenStorage.getToken();
      if (token != null) {
        await _client.post('/auth/logout', {}, token: token);
      }
    } catch (e) {
      // Continue with token removal even if API call fails
    } finally {
      await TokenStorage.removeToken();
      await AuthPrefs.clear();
    }
  }

  Future<void> editProfile({
    String? username,
    String? bio,
    String? profileImage,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw AuthException('No authentication token found');
    }

    final Map<String, dynamic> body = {};
    if (username != null) body['username'] = username;
    if (bio != null) body['bio'] = bio;
    if (profileImage != null) body['profile_image'] = profileImage;

    final response = await _client.put(
      '/auth/edit-profile',
      body,
      token: token,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final responseData = jsonDecode(response.body);
      throw AuthException(
        responseData['message'] ?? 'Failed to update profile',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final responseData = jsonDecode(response.body);
    if (responseData['success'] != true) {
      throw AuthException(
        responseData['message'] ?? 'Failed to update profile',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }
}
