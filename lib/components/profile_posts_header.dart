import 'package:flutter/material.dart';

class ProfilePostsHeader extends StatelessWidget {
  final int postCount;
  final bool isGridView;
  final ValueChanged<bool> onViewChanged;

  const ProfilePostsHeader({
    super.key,
    required this.postCount,
    required this.isGridView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          const Text(
            'โพสต์',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 8),
          if (postCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF07B3F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$postCount',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF07B3F),
                ),
              ),
            ),
          const Spacer(),
          // Toggle grid / list view
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewToggle(Icons.grid_view_rounded, true),
                _buildViewToggle(Icons.view_list_rounded, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, bool isGrid) {
    final isSelected = isGridView == isGrid;
    return GestureDetector(
      onTap: () => onViewChanged(isGrid),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey[500],
        ),
      ),
    );
  }
}
