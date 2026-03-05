import 'package:flutter/material.dart';
import '../../../api/feat/user_service.dart';
import '../../../api/feat/post_api.dart';
import '../../../models/user_model.dart';
import '../../../models/post_model.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/auth/jwt_utils.dart';

// Components
import '../../../components/profile_stats_card.dart';
import '../../../components/profile_posts_header.dart';
import '../../../components/profile_posts_grid.dart';
import '../../../components/profile_posts_list.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String? profileImage;

  const OtherUserProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    this.profileImage,
  });

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  final UserService _userService = UserService();
  final PostApi _postApi = PostApi();
  User? _user;
  bool _isLoading = true;
  bool _isFollowLoading = false;
  String? _error;
  bool _isOwnProfile = false;
  List<Post> _userPosts = [];
  bool _isLoadingPosts = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      setState(() {
        _error = 'ไม่พบ authentication token';
        _isLoading = false;
      });
      return;
    }

    final currentUserId = JwtUtils.userIdFromToken(token);
    if (currentUserId == null) {
      setState(() {
        _error = 'ไม่พบข้อมูลผู้ใช้';
        _isLoading = false;
      });
      return;
    }

    _isOwnProfile = currentUserId == widget.userId;

    setState(() => _isLoading = true);
    try {
      final user = await _userService.getUserProfile(widget.userId);
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

  Future<void> _loadUserPosts() async {
    if (_user == null) return;

    setState(() => _isLoadingPosts = true);
    try {
      final posts = await _postApi.getPostsByUserId(widget.userId);
      setState(() {
        _userPosts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_isFollowLoading || _user == null) return;

    setState(() => _isFollowLoading = true);
    try {
      if (_user!.isFollowing == true) {
        await _userService.unfollowUser(widget.userId);
        setState(() {
          _user = _user!.copyWith(isFollowing: false);
        });
      } else {
        await _userService.followUser(widget.userId);
        setState(() {
          _user = _user!.copyWith(isFollowing: true);
        });
      }
      _loadUserProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ไม่สามารถติดตามได้: $e')));
      }
    } finally {
      setState(() => _isFollowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: Text(widget.username),
          backgroundColor: const Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
        ),
        body: Center(
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
                ),
                child: const Text('ลองใหม่'),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.username)),
        body: const Center(child: Text('ไม่พบข้อมูลผู้ใช้')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserProfile();
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildProfileInfo()),
            SliverToBoxAdapter(child: _buildFollowButton()),
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

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
      foregroundColor: Colors.white,
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
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _user!.isFollowing == true
                              ? const Color(0xFF4DA8FF)
                              : const Color(0xFFF07B3F),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: _user!.profileImage != null
                            ? NetworkImage(_user!.profileImage!)
                            : null,
                        child: _user!.profileImage == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 45,
                                color: Colors.white70,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _user!.username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (_user!.isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4DA8FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
            Text(
              _user!.bio!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 4),

          // Use extracted component
          ProfileStatsCard(
            postCount: _userPosts.length,
            followers: _user!.followers,
            following: _user!.following,
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: _isOwnProfile
          ? OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.person_outlined, size: 18),
              label: const Text('โปรไฟล์ของคุณ'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _isFollowLoading ? null : _toggleFollow,
                    icon: _isFollowLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            _user!.isFollowing == true
                                ? Icons.person_remove_outlined
                                : Icons.person_add_alt_1,
                            size: 18,
                          ),
                    label: Text(
                      _user!.isFollowing == true ? 'เลิกติดตาม' : 'ติดตาม',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _user!.isFollowing == true
                          ? Colors.grey[200]
                          : const Color(0xFF4DA8FF),
                      foregroundColor: _user!.isFollowing == true
                          ? Colors.grey[700]
                          : Colors.white,
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
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('ข้อความ'),
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

// Extension to create a copy of User with updated isFollowing
extension UserCopyWith on User {
  User copyWith({bool? isFollowing}) {
    return User(
      id: id,
      email: email,
      username: username,
      role: role,
      bio: bio,
      profileImage: profileImage,
      isVerified: isVerified,
      createdAt: createdAt,
      followers: followers,
      following: following,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
