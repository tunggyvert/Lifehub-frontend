import 'package:flutter/material.dart';
import '../api/feat/user_service.dart';
import '../models/user_model.dart';

class UserProfileDialog extends StatefulWidget {
  final int userId;
  final String username;
  final String? profileImage;
  final int? currentUserId;

  const UserProfileDialog({
    super.key,
    required this.userId,
    required this.username,
    this.profileImage,
    this.currentUserId,
  });

  @override
  State<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  final UserService _userService = UserService();
  bool _isFollowing = false;
  bool _isLoading = false;
  bool _isFollowLoading = false;
  User? _user; // Store the full user data from API

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (widget.currentUserId == null || widget.currentUserId == widget.userId) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _userService.getUserProfile(widget.userId);
      setState(() {
        _user = user;
        _isFollowing = user.isFollowing ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  Future<void> _toggleFollow() async {
    if (_isFollowLoading) return;

    setState(() => _isFollowLoading = true);
    try {
      if (_isFollowing) {
        await _userService.unfollowUser(widget.userId);
        setState(() {
          _isFollowing = false;
        });
      } else {
        await _userService.followUser(widget.userId);
        setState(() {
          _isFollowing = true;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFollowing ? 'ติดตามแล้ว' : 'เลิกติดตามแล้ว'),
          ),
        );
      }
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
    final isOwnProfile = widget.currentUserId == widget.userId;
    // Use data from API if available, otherwise use the basic info passed in
    final displayUser = _user;
    final username = displayUser?.username ?? widget.username;
    final profileImage = displayUser?.profileImage ?? widget.profileImage;
    final followers = displayUser?.followers ?? 0;
    final following = displayUser?.following ?? 0;
    final bio = displayUser?.bio;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'โปรไฟล์ผู้ใช้',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User info
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      profileImage != null && profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage == null || profileImage.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (bio != null && bio.isNotEmpty)
                        Text(
                          bio!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Follow stats
                      Row(
                        children: [
                          Text(
                            '$followers',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(' ผู้ติดตาม'),
                          const SizedBox(width: 16),
                          Text(
                            '$following',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(' กำลังติดตาม'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Follow button (only show if not own profile)
            if (!isOwnProfile)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing ? Colors.grey : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isFollowLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(_isFollowing ? 'เลิกติดตาม' : 'ติดตาม'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
