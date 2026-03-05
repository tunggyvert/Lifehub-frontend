import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as sio;

import '../../api/api_service.dart';
import '../auth/jwt_utils.dart';
import '../storage/token_storage.dart';

class NotificationRealtimeService {
  NotificationRealtimeService._();

  static final NotificationRealtimeService instance =
      NotificationRealtimeService._();

  sio.Socket? _socket;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  bool get isConnected => _socket?.connected == true;

  void connect() {
    if (_socket != null) return;

    final socket = sio.io(ApiService.baseURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('notificationCreated', (data) async {
      final token = await TokenStorage.getToken();
      if (token == null) return;

      final myId = JwtUtils.userIdFromToken(token);
      if (myId == null) return;

      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final userId = map['userId'];
        final int? targetId = userId is int
            ? userId
            : userId is num
            ? userId.toInt()
            : userId is String
            ? int.tryParse(userId)
            : null;

        if (targetId == myId) {
          _controller.add(map);
        }
        return;
      }
    });

    _socket = socket;
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
