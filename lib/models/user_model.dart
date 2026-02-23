class User {
  final int id;
  final String email;
  final String username;
  final String role;
  final String? bio;
  final String? profileImage;
  final bool isVerified;
  final DateTime createdAt;
  final int followers;
  final int following;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    this.bio,
    this.profileImage,
    required this.isVerified,
    required this.createdAt,
    required this.followers,
    required this.following,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final v = value.toLowerCase().trim();
        if (v == 'true' || v == '1') return true;
        if (v == 'false' || v == '0') return false;
      }
      return false;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return User(
      id: parseInt(json['id']),
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      bio: json['bio'],
      profileImage: json['profile_image'],
      isVerified: parseBool(json['is_verified']),
      createdAt: DateTime.parse((json['created_at'] ?? '').toString()),
      followers: parseInt(json['followers']),
      following: parseInt(json['following']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'bio': bio,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'followers': followers,
      'following': following,
    };
  }
}
