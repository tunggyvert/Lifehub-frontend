import 'package:flutter/material.dart';

import 'dart:async';

import '../features/home/screen/home_screen.dart';
import '../features/noti/screen/noti_screen.dart';
import '../features/profile/screen/profile_screen.dart';
import '../features/post/screen/create_post_screen.dart';
import '../api/feat/noti_service.dart';
import '../core/realtime/notification_realtime_service.dart';
import 'app_colors.dart';
import 'lifehub_bottom_navbar.dart';

class BottomNavbarPage extends StatefulWidget {
  const BottomNavbarPage({super.key});

  @override
  State<BottomNavbarPage> createState() => _BottomNavbarPageState();
}

class _BottomNavbarPageState extends State<BottomNavbarPage> {
  int _currentIndex = 0;
  int _unreadCount = 0;
  final NotiService _notiService = NotiService();
  StreamSubscription? _rtSub;

  @override
  void initState() {
    super.initState();
    _refreshUnreadCount();
    NotificationRealtimeService.instance.connect();
    _rtSub = NotificationRealtimeService.instance.stream.listen((_) {
      if (!mounted) return;
      _refreshUnreadCount();
    });
  }

  @override
  void dispose() {
    _rtSub?.cancel();
    super.dispose();
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final count = await _notiService.getUnreadCount();
      if (!mounted) return;
      setState(() {
        _unreadCount = count;
      });
    } catch (_) {
      // ignore
    }
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatePostScreen()),
      );

      if (result == true) {
        setState(() {
          _currentIndex = 0; // กลับหน้า Home
        });
      }
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    if (index == 2) {
      _refreshUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const SizedBox(),
      NotiScreen(onUnreadChanged: _refreshUnreadCount),
      const ProfileScreen(),
    ];

    return Scaffold(
      // 2. ใช้ IndexedStack เพื่อเก็บสถานะของแต่ละหน้าไว้ในหน่วยความจำ
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: LifehubBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        unreadNotificationCount: _unreadCount,
        backgroundColor: AppColors.primaryOrange,
        selectedColor: Colors.blue,
        unselectedColor: Colors.black,
      ),
    );
  }
}
