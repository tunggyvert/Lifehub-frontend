import 'dart:convert';
import '../../core/storage/token_storage.dart';
import '../api_service.dart';
import '../../models/user_model.dart';

class UserException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  UserException(this.message, {this.statusCode, this.body});

  @override
  String toString() {
    final code = statusCode == null ? '' : ' statusCode=$statusCode';
    final b = body == null ? '' : ' body=$body';
    return 'UserException($message$code$b)';
  }
}

class UserService {
  final ApiService _client = ApiService();

  Future<User> getUserProfile(int userId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw UserException('User not logged in');
    }

    final response = await _client.get('/api/users/$userId', token: token);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UserException(
        'Failed to load user profile',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map && decoded.containsKey('data')) {
      return User.fromJson(Map<String, dynamic>.from(decoded['data']));
    }
    return User.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> followUser(int userId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw UserException('User not logged in');
    }

    final response = await _client.post('/api/users/$userId/follow', {}, token: token);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UserException(
        'Failed to follow user',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }

  Future<void> unfollowUser(int userId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw UserException('User not logged in');
    }

    final response = await _client.delete('/api/users/$userId/follow', token: token);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UserException(
        'Failed to unfollow user',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }
}
