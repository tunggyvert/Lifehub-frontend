// CREATE TABLE notifications (
//   id INT AUTO_INCREMENT PRIMARY KEY,

//   user_id INT NOT NULL,      -- คนที่ได้รับแจ้งเตือน
//   sender_id INT NOT NULL,    -- คนที่ทำ action

//   type ENUM('like','comment','follow') NOT NULL,
//   reference_id INT NOT NULL, -- post_id หรือ comment_id

//   is_read BOOLEAN DEFAULT FALSE,
//   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

//   INDEX idx_user (user_id),
//   INDEX idx_sender (sender_id),

//   FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
//   FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
// );

class NotificationItem {
  final int id;
  final int userId;
  final int senderId;
  final String type;
  final int referenceId;
  bool isRead;
  final DateTime createdAt;
  final String senderUsername;
  final String? senderProfileImage;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.senderId,
    required this.type,
    required this.referenceId,
    required this.isRead,
    required this.createdAt,
    required this.senderUsername,
    required this.senderProfileImage,
  });

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == 'true' || v == '1') return true;
      if (v == 'false' || v == '0') return false;
    }
    return false;
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      senderId: _parseInt(json['sender_id']),
      type: (json['type'] ?? '').toString(),
      referenceId: _parseInt(json['reference_id']),
      isRead: _parseBool(json['is_read']),
      createdAt: DateTime.parse((json['created_at'] ?? '').toString()),
      senderUsername: (json['sender_username'] ?? '').toString(),
      senderProfileImage: json['sender_profile_image']?.toString(),
    );
  }
}
