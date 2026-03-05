import 'dart:convert';

import '../../core/storage/token_storage.dart';
import '../../models/noti_model.dart';
import '../api_service.dart';

class NotiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  NotiException(this.message, {this.statusCode, this.body});

  @override
  String toString() {
    final code = statusCode == null ? '' : ' statusCode=$statusCode';
    final b = body == null ? '' : ' body=$body';
    return 'NotiException($message$code$b)';
  }
}

class NotiService {
  final ApiService _client = ApiService();

  Future<List<NotificationItem>> getMyNotifications({
    int limit = 20,
    int page = 1,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw NotiException('User not logged in');
    }

    final response = await _client.get(
      '/api/notifications?limit=$limit&page=$page',
      token: token,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotiException(
        'Failed to load notifications',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final decoded = jsonDecode(response.body);
    final List data = decoded is List ? decoded : (decoded['data'] ?? []);
    return data
        .whereType<Map>()
        .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw NotiException('User not logged in');
    }

    final response = await _client.get(
      '/api/notifications/unread-count',
      token: token,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotiException(
        'Failed to load unread count',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final value = decoded['unread_count'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> markAsRead(int id) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw NotiException('User not logged in');
    }

    final response = await _client.put(
      '/api/notifications/$id/read',
      {},
      token: token,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotiException(
        'Failed to mark notification as read',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }

  Future<void> markAllAsRead() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw NotiException('User not logged in');
    }

    final response = await _client.put(
      '/api/notifications/read-all',
      {},
      token: token,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotiException(
        'Failed to mark all notifications as read',
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }
}
