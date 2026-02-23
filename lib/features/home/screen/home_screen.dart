import 'package:flutter/material.dart';

import '../../../components/app_colors.dart';
import '../../../components/category_pill_button.dart';
import '../../../components/feed_card.dart';
import '../../../components/segmented_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

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
                      setState(() {
                        _selectedTabIndex = index;
                      });
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
              Expanded(
                child: ListView.separated(
                  itemCount: 8,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return FeedCard(
                      height: 190,
                      backgroundColor: const Color(0xFF9E9E9E),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
