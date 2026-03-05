import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../components/app_colors.dart';
import '../../../components/category_pill_button.dart';
import '../../../components/post_card.dart';
import '../../../components/segmented_tab.dart';

import '../../../api/feat/post_api.dart';
import '../../../models/post_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final PostApi _postApi = PostApi();
  final Set<int> _likingPosts = {};

  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = _posts.isEmpty;
      _errorMessage = null;
    });

    try {
      final posts = await _postApi.getPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLike(Post post) async {
    if (_likingPosts.contains(post.id)) return;

    final originalIsLiked = post.isLiked;
    final originalLikeCount = post.likeCount;

    _likingPosts.add(post.id);

    // Optimistic update
    setState(() {
      post.isLiked = !post.isLiked;
      post.likeCount += post.isLiked ? 1 : -1;
    });

    try {
      final result = await _postApi.toggleLike(post.id);

      if (mounted) {
        setState(() {
          post.isLiked = result;
          if (result != !originalIsLiked) {
            post.likeCount = originalLikeCount;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          post.isLiked = originalIsLiked;
          post.likeCount = originalLikeCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถกดไลก์ได้ในขณะนี้')),
        );
      }
    } finally {
      _likingPosts.remove(post.id);
    }
  }

  void _showUserProfile(int userId, String username, String? profileImage) {
    context.push(
      '/profile/$userId',
      extra: {'username': username, 'profileImage': profileImage},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  SegmentedTab(
                    tabs: const ['ติดตาม', 'สำหรับคุณ'],
                    selectedIndex: _selectedTabIndex,
                    onChanged: (index) {
                      setState(() => _selectedTabIndex = index);
                    },
                    selectedColor: Colors.white,
                    unselectedColor: const Color(0xFFE6E6E6),
                    selectedTextColor: AppColors.textPrimary,
                    unselectedTextColor: AppColors.textMuted,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CategoryPillButton(
                label: 'เลือกหมวดหมู่',
                onPressed: () {},
                backgroundColor: const Color(0xFFE0E0E0),
                textColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildPostsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('ข้อผิดพลาด: $_errorMessage'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadPosts, child: const Text('ลองใหม่')),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.post_add, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'ยังไม่มีโพสต์',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'ลองสร้างโพสต์แรกของคุณ',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostCard(
            imageUrl: post.imageUrl,
            caption: post.caption,
            username: post.username,
            profileImageUrl: post.profileImage,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            isLiked: post.isLiked,
            isLiking: _likingPosts.contains(post.id),
            createdAt: post.createdAt,
            onTap: () {
              context.push('/post-detail', extra: post).then((_) {
                _loadPosts();
              });
            },
            onLikePressed: () => _handleLike(post),
            onCommentPressed: () {
              context.push('/post-detail', extra: post).then((_) {
                _loadPosts();
              });
            },
            onUserTap: () =>
                _showUserProfile(post.userId, post.username, post.profileImage),
          );
        },
      ),
    );
  }
}
