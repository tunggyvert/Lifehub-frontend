import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import 'package:go_router/go_router.dart';

class ProfilePostsGrid extends StatelessWidget {
  final List<Post> posts;
  final VoidCallback onPostUpdated;

  const ProfilePostsGrid({
    super.key,
    required this.posts,
    required this.onPostUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyPosts());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final post = posts[index];
          return GestureDetector(
            onTap: () {
              context.push('/post-detail', extra: post).then((_) {
                onPostUpdated();
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                index == 0
                    ? 12
                    : index == 2
                    ? 12
                    : index == posts.length - 1
                    ? 12
                    : 4,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: Colors.grey[400],
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
                  // Hover overlay with like/comment counts
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${post.likeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chat_bubble,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${post.commentCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: posts.length),
      ),
    );
  }

  Widget _buildEmptyPosts() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF07B3F).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 40,
              color: Color(0xFFF07B3F),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีโพสต์',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'เริ่มแชร์ช่วงเวลาของคุณ',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
