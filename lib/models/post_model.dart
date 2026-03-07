class Post {
  final int id;
  final int userId;
  final String? caption;
  final String imageUrl;
  final String username;
  final String? profileImage;
  final DateTime createdAt;
  int likeCount;
  int commentCount;
  bool isLiked;

  Post({
    required this.id,
    required this.userId,
    this.caption,
    required this.imageUrl,
    required this.username,
    this.profileImage,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  int parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: parseIntStatic(json['id']),
      userId: parseIntStatic(json['user_id']),
      caption: json['caption'],
      imageUrl: json['image_url'] ?? '',
      username: (json['username'] ?? '').toString(),
      profileImage: json['profile_image'],
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      likeCount: parseIntStatic(json['like_count']),
      commentCount: parseIntStatic(json['comment_count']),
      isLiked: json['is_liked'] == true || json['is_liked'] == 1,
    );
  }

  static int parseIntStatic(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
