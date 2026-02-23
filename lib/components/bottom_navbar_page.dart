import 'package:flutter/material.dart';

import '../features/home/screen/home_screen.dart';
import '../features/profile/screen/profile_screen.dart';
import 'app_colors.dart';
import 'lifehub_bottom_navbar.dart';

class BottomNavbarPage extends StatefulWidget {
  const BottomNavbarPage({super.key});

  @override
  State<BottomNavbarPage> createState() => _BottomNavbarPageState();
}

class _BottomNavbarPageState extends State<BottomNavbarPage> {
  int _currentIndex = 0;

  static const List<Widget> _widgetPages = [
    HomeScreen(),
    _PlaceholderPage(title: 'Add'),
    _PlaceholderPage(title: 'Notifications'),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetPages.elementAt(_currentIndex),
      bottomNavigationBar: LifehubBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.primaryOrange,
        selectedColor: Colors.blue,
        unselectedColor: Colors.black,
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
