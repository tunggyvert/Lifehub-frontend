import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String imageUrl;
  final String? caption;
  final String username;
  final String? profileImageUrl;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isLiking;
  final DateTime createdAt;
  final VoidCallback? onTap;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onUserTap;

  const PostCard({
    super.key,
    required this.imageUrl,
    this.caption,
    required this.username,
    this.profileImageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    this.isLiking = false,
    required this.createdAt,
    this.onTap,
    this.onLikePressed,
    this.onCommentPressed,
    this.onUserTap,
  });

  String _formatDate() {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'เมื่อสักครู่';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    if (diff.inDays < 7) return '${diff.inDays} วันที่แล้ว';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + username + time
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onUserTap,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 20,
                              color: Colors.grey[500],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: onUserTap,
                          child: Text(
                            username,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
                ],
              ),
            ),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Actions: like + comment
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Row(
                children: [
                  _buildActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey[600]!,
                    count: likeCount,
                    onTap: isLiking ? null : onLikePressed,
                    isLoading: isLiking,
                  ),
                  const SizedBox(width: 18),
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    color: Colors.grey[600]!,
                    count: commentCount,
                    onTap: onCommentPressed,
                  ),
                ],
              ),
            ),

            // Caption
            if (caption != null && caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$username ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      TextSpan(
                        text: caption!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required int count,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Icon(icon, color: color, size: 22),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
