import 'package:flutter/material.dart';

class LifehubBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;

  const LifehubBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.backgroundColor,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.home,
            index: 0,
            currentIndex: currentIndex,
            onTap: onTap,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
          _NavItem(
            icon: Icons.add_circle_outline,
            index: 1,
            currentIndex: currentIndex,
            onTap: onTap,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
          _NavItem(
            icon: Icons.notifications_none,
            index: 2,
            currentIndex: currentIndex,
            onTap: onTap,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
          _NavItem(
            icon: Icons.person_outline,
            index: 3,
            currentIndex: currentIndex,
            onTap: onTap,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          icon,
          color: isSelected ? selectedColor : unselectedColor,
          size: 26,
        ),
      ),
    );
  }
}
