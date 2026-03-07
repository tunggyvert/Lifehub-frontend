import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../components/app_colors.dart';
import '../../../components/post_card.dart';
import '../../../components/segmented_tab.dart';
import '../../../core/auth/jwt_utils.dart';
import '../../../core/storage/token_storage.dart';

import '../../../api/feat/post_api.dart';
import '../../../models/post_model.dart';
import '../../../api/feat/searchfilter_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 1; // Default to 'สำหรับคุณ'
  final PostApi _postApi = PostApi();
  final Set<int> _likingPosts = {};

  List<Post> _posts = [];
  bool _isLoading = true;
  bool _showSearchBar = false;
  String? _errorMessage;
  var returnData;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPosts();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final token = await TokenStorage.getToken();
      if (token != null) {
        final userId = JwtUtils.userIdFromToken(token);
        if (mounted && userId != null) {
          setState(() {
            _currentUserId = userId;
          });
        }
      }
    } catch (e) {
      print('Error decoding token: $e');
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = _posts.isEmpty;
      _errorMessage = null;
    });

    try {
      final posts = _selectedTabIndex == 0
          ? await _postApi.getFollowingPosts()
          : await _postApi.getPosts();

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

  Future<void> _handleEditPost(Post post) async {
    final result = await context.push<bool>('/edit-post', extra: post);
    if (result == true) {
      _loadPosts();
    }
  }

  Future<void> _handleDeletePost(Post post) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ลบโพสต์'),
          content: const Text(
            'คุณแน่ใจหรือไม่ว่าต้องการลบโพสต์นี้? การดำเนินการนี้ไม่สามารถย้อนกลับได้',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ลบ', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _postApi.deletePost(post.id);
        _loadPosts();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ลบโพสต์เรียบร้อยแล้ว')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
          );
        }
      }
    }
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
                  if (!_showSearchBar) ...[
                    SegmentedTab(
                      tabs: const ['ติดตาม', 'สำหรับคุณ'],
                      selectedIndex: _selectedTabIndex,
                      onChanged: (index) {
                        if (_selectedTabIndex != index) {
                          setState(() {
                            _selectedTabIndex = index;
                            _posts.clear();
                          });
                          _loadPosts();
                        }
                      },
                      selectedColor: Colors.white,
                      unselectedColor: const Color(0xFFE6E6E6),
                      selectedTextColor: AppColors.textPrimary,
                      unselectedTextColor: AppColors.textMuted,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showSearchBar = true;
                        });
                      },
                      icon: const Icon(Icons.search),
                      color: AppColors.textPrimary,
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showSearchBar = false;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textPrimary,
                    ),
                    _createSearchbar(),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildPostsList()),
            ],
          ),
        ),
      ),
    );
  }

  // Search bar. โปรดปรับแก้ ----------------------------------------------------------------------------------------------
  Widget _createSearchbar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              hintText: 'ค้นหาโพสต์หรือผู้ใช้',
              leading: const Icon(Icons.search),
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
            );
          },
          suggestionsBuilder:
              (BuildContext context, SearchController controller) async {
                final query = controller.text;
                if (query.isEmpty) {
                  return const [];
                }

                try {
                  final results = await SearchFilterService().matchSearch(
                    query,
                  );
                  if (results == null) return const [];

                  final posts = (results['posts'] as List<dynamic>?) ?? [];
                  final users = (results['users'] as List<dynamic>?) ?? [];

                  return [
                    ...posts.map(
                      (post) => ListTile(
                        leading: const Icon(Icons.post_add),
                        title: Text(post['caption']?.toString() ?? ''),
                        subtitle: Text(
                          'ยอดไลค์ : ${post['like_count']?.toString() ?? '0'}',
                        ),
                        onTap: () {
                          context.push('/post-detail', extra: post);
                        },
                      ),
                    ),
                    ...users.map(
                      (user) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['profile_image'] != null
                              ? NetworkImage(user['profile_image'])
                              : null,
                          child: user['profile_image'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user['username']?.toString() ?? ''),
                        subtitle: Text(
                          '${user['followers']?.toString() ?? '0'} ผู้ติดตาม',
                        ),
                        onTap: () {
                          context.push(
                            '/profile/${user['id']}',
                            extra: {
                              'username': user['username'],
                              'profileImage': user['profile_image'],
                            },
                          );
                        },
                      ),
                    ),
                  ];
                } catch (error) {
                  print('เกิดข้อผิดพลาดในการค้นหา: $error');
                  return [
                    ListTile(
                      leading: const Icon(Icons.error, color: Colors.red),
                      title: const Text('เกิดข้อผิดพลาดในการค้นหา'),
                      subtitle: Text(error.toString()),
                    ),
                  ];
                }
              },
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
            userId: post.userId,
            username: post.username,
            profileImageUrl: post.profileImage,
            likeCount: post.likeCount,
            commentCount: post.commentCount,
            isLiked: post.isLiked,
            isLiking: _likingPosts.contains(post.id),
            createdAt: post.createdAt,
            currentUserId: _currentUserId ?? 0,
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
            onEditPressed: () => _handleEditPost(post),
            onDeletePressed: () => _handleDeletePost(post),
          );
        },
      ),
    );
  }
}
