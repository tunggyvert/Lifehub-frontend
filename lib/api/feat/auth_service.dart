import '../api_service.dart';
import '../../models/user_model.dart';
import '../../core/storage/token_storage.dart';
import 'dart:convert';

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
    final response = await _client.post('/auth/login', {
      'username': username,
      'password': password,
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException(
        'Login failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final responseData = jsonDecode(response.body);
    if (responseData['success'] != true || responseData['token'] == null) {
      throw AuthException(
        responseData['message'] ?? 'Login failed - no token received',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    await TokenStorage.saveToken(responseData['token']);
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
    await TokenStorage.removeToken();
  }
}
