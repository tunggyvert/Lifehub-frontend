import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../api/feat/auth_service.dart';
import '../../../api/feat/post_api.dart';
import '../../../models/user_model.dart';
import '../../../models/post_model.dart';
import '../../../core/storage/token_storage.dart';
import 'edit_profile_screen.dart';

// Components
import '../../../components/profile_stats_card.dart';
import '../../../components/profile_posts_header.dart';
import '../../../components/profile_posts_grid.dart';
import '../../../components/profile_posts_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final PostApi _postApi = PostApi();
  User? _user;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  bool _isLoadingPosts = false;
  String? _error;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserPosts() async {
    if (_user == null) return;

    setState(() => _isLoadingPosts = true);

    try {
      final posts = await _postApi.getPostsByUserId(_user!.id);
      if (posts.isEmpty) {
        try {
          final allPosts = await _postApi.getPosts();
          final userPosts = allPosts
              .where((post) => post.userId == _user!.id)
              .toList();
          setState(() {
            _userPosts = userPosts;
            _isLoadingPosts = false;
          });
          return;
        } catch (_) {}
      }

      setState(() {
        _userPosts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        setState(() {
          _error = 'ไม่พบ authentication token';
          _isLoading = false;
        });
        return;
      }

      final user = await _authService.profile(token);
      setState(() {
        _user = user;
        _isLoading = false;
      });
      _loadUserPosts();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToEditProfile() async {
    if (_user == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(user: _user!)),
    );

    if (result == true) {
      _loadUserProfile();
      _loadUserPosts();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('ออกจากระบบ'),
          content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ยกเลิก', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              child: const Text(
                'ออกจากระบบ',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถออกจากระบบได้: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
          : RefreshIndicator(
              onRefresh: () async {
                await _loadUserProfile();
              },
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(child: _buildProfileInfo()),
                  SliverToBoxAdapter(child: _buildActionButtons()),
                  SliverToBoxAdapter(
                    child: ProfilePostsHeader(
                      postCount: _userPosts.length,
                      isGridView: _isGridView,
                      onViewChanged: (isGrid) {
                        setState(() => _isGridView = isGrid);
                      },
                    ),
                  ),
                  _buildPostsSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'เกิดข้อผิดพลาด',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadUserProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF07B3F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF07B3F),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: _user?.profileImage != null
                            ? NetworkImage(_user!.profileImage!)
                            : null,
                        child: _user?.profileImage == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 45,
                                color: Colors.white70,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'logout') {
              _showLogoutDialog();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _user?.username ?? 'user',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              if (_user?.isVerified == true) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4DA8FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          if (_user?.bio != null && _user!.bio!.isNotEmpty) ...[
            Text(
              _user!.bio!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 12),

          // Use extracted component
          ProfileStatsCard(
            postCount: _userPosts.length,
            followers: _user?.followers ?? 0,
            following: _user?.following ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('แก้ไขโปรไฟล์'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined, size: 18),
              label: const Text('แชร์โปรไฟล์'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    if (_isLoadingPosts) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_isGridView) {
      return ProfilePostsGrid(posts: _userPosts, onPostUpdated: _loadUserPosts);
    } else {
      return ProfilePostsList(posts: _userPosts, onPostUpdated: _loadUserPosts);
    }
  }
}
