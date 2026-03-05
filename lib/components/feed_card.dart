import 'package:flutter/material.dart';

class FeedCard extends StatelessWidget {
  final double height;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Widget? child;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final bool isLiking;
  final String? username;
  final String? profileImageUrl;
  final int? userId;
  final VoidCallback? onUserTap;

  const FeedCard({
    super.key,
    this.height = 180,
    required this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.child,
    this.isLiked = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.onLikePressed,
    this.onCommentPressed,
    this.isLiking = false,
    this.username,
    this.profileImageUrl,
    this.userId,
    this.onUserTap,
  });
  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: child,
        ),

        // รูปโปรไฟล์มุมซ้ายล่าง (ของเดิม)
        Positioned(
          left: 6,
          bottom: 4,
          child: GestureDetector(
            onTap: onUserTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: profileImageUrl != null
                    ? Image.network(
                        profileImageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.black54,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.black54,
                        ),
                      ),
              ),
            ),
          ),
        ),

        // ปุ่ม Like และ Comment มุมขวาล่าง (ของใหม่)
        Positioned(
          right: 12,
          bottom: 12,
          child: Row(
            children: [
              _buildActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white,
                count: likeCount,
                onTap: isLiking ? null : onLikePressed,
                isLoading: isLiking,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                color: Colors.white,
                count: commentCount,
                onTap: onCommentPressed,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // วิดเจ็ตย่อยสำหรับสร้างปุ่มกด
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required int count,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading
              ? SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Icon(icon, color: color, size: 28),
          const SizedBox(height: 2),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 2, color: Colors.black45)],
            ),
          ),
        ],
      ),
    );
  }
}
