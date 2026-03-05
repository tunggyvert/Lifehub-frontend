import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../api/feat/noti_service.dart';
import '../../../api/feat/post_api.dart';
import '../../../api/feat/user_service.dart';
import '../../../components/app_colors.dart';
import '../../../core/realtime/notification_realtime_service.dart';
import '../../../models/noti_model.dart';

class NotiScreen extends StatefulWidget {
  final VoidCallback? onUnreadChanged;

  const NotiScreen({super.key, this.onUnreadChanged});

  @override
  State<NotiScreen> createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  final NotiService _notiService = NotiService();
  final UserService _userService = UserService();
  List<NotificationItem> _items = const [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _rtSub;

  // Track which users we are following back (optimistic)
  final Set<int> _followingBack = {};
  final Set<int> _followingInProgress = {};

  @override
  void initState() {
    super.initState();
    _load();

    NotificationRealtimeService.instance.connect();
    _rtSub = NotificationRealtimeService.instance.stream.listen((_) {
      if (!mounted) return;
      _load(silent: true);
      widget.onUnreadChanged?.call();
    });
  }

  @override
  void dispose() {
    _rtSub?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final data = await _notiService.getMyNotifications();
      if (!mounted) return;
      setState(() {
        _items = data;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notiService.markAllAsRead();
      if (!mounted) return;
      setState(() {
        for (final n in _items) {
          n.isRead = true;
        }
      });
      widget.onUnreadChanged?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่สามารถอ่านทั้งหมดได้: $e')));
    }
  }

  Future<void> _markAsRead(NotificationItem item) async {
    if (item.isRead) return;
    setState(() => item.isRead = true);
    widget.onUnreadChanged?.call();

    try {
      await _notiService.markAsRead(item.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => item.isRead = false);
      widget.onUnreadChanged?.call();
    }
  }

  Future<void> _followBack(NotificationItem item) async {
    final senderId = item.senderId;
    if (_followingInProgress.contains(senderId)) return;

    setState(() {
      _followingInProgress.add(senderId);
    });

    try {
      if (_followingBack.contains(senderId)) {
        await _userService.unfollowUser(senderId);
        if (!mounted) return;
        setState(() => _followingBack.remove(senderId));
      } else {
        await _userService.followUser(senderId);
        if (!mounted) return;
        setState(() => _followingBack.add(senderId));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) {
        setState(() => _followingInProgress.remove(senderId));
      }
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return 'เมื่อสักครู่';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    if (diff.inDays < 7) return '${diff.inDays} วันที่แล้ว';
    final d = dt.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }

  String _bodyFor(NotificationItem n) {
    final sender = n.senderUsername.isEmpty ? 'ผู้ใช้' : n.senderUsername;
    switch (n.type) {
      case 'like':
        return '$sender กดถูกใจโพสต์ของคุณ';
      case 'comment':
        return '$sender แสดงความคิดเห็นในโพสต์ของคุณ';
      case 'follow':
        return '$sender เริ่มติดตามคุณแล้ว';
      default:
        return '$sender มีกิจกรรมใหม่';
    }
  }

  Color _accentFor(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return const Color(0xFF4DA8FF);
      case 'follow':
        return AppColors.primaryOrange;
      default:
        return Colors.grey;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add_alt_1_rounded;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'การแจ้งเตือน',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          if (_items.any((n) => !n.isRead))
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(
                Icons.done_all_rounded,
                size: 18,
                color: AppColors.primaryOrange,
              ),
              label: const Text(
                'อ่านทั้งหมด',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () => _load(silent: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _error ?? '',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('ลองใหม่'),
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 60,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'ยังไม่มีการแจ้งเตือน',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'เมื่อมีคนไลก์ คอมเมนต์ หรือติดตาม\nคุณจะเห็นแจ้งเตือนที่นี่',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final n = _items[index];
        return _buildNotificationTile(n);
      },
    );
  }

  Widget _buildNotificationTile(NotificationItem n) {
    final accent = _accentFor(n.type);
    final isFollowBack = _followingBack.contains(n.senderId);
    final isFollowing = _followingInProgress.contains(n.senderId);

    return InkWell(
      onTap: () async {
        await _markAsRead(n);
        if (!mounted) return;

        if (n.type == 'like' || n.type == 'comment') {
          try {
            final post = await PostApi().getPostById(n.referenceId);
            if (mounted) context.push('/post-detail', extra: post);
          } catch (_) {
            // Post deleted, ignore
          }
        } else if (n.type == 'follow') {
          context.push(
            '/profile/${n.senderId}',
            extra: {
              'username': n.senderUsername,
              'profileImage': n.senderProfileImage,
            },
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: n.isRead
            ? Colors.transparent
            : AppColors.primaryOrange.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with type badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: n.senderProfileImage != null
                        ? NetworkImage(n.senderProfileImage!)
                        : null,
                    child: n.senderProfileImage == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 26,
                            color: Colors.grey[500],
                          )
                        : null,
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _iconFor(n.type),
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: n.senderUsername,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: n.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          TextSpan(
                            text: _bodyFor(
                              n,
                            ).replaceFirst(n.senderUsername, ''),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: n.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(n.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: n.isRead ? Colors.grey[400] : accent,
                        fontWeight: n.isRead
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing: unread dot OR follow-back button
              if (n.type == 'follow')
                _buildFollowBackButton(n, isFollowBack, isFollowing)
              else if (!n.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowBackButton(
    NotificationItem n,
    bool isFollowBack,
    bool isInProgress,
  ) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: isInProgress ? null : () => _followBack(n),
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowBack
              ? Colors.grey[200]
              : AppColors.primaryOrange,
          foregroundColor: isFollowBack ? Colors.grey[700] : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        child: isInProgress
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isFollowBack ? Colors.grey[600] : Colors.white,
                ),
              )
            : Text(isFollowBack ? 'ติดตามแล้ว' : 'ติดตาม'),
      ),
    );
  }
}
