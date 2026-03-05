import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final int postCount;
  final int followers;
  final int following;

  const ProfileStatsCard({
    super.key,
    required this.postCount,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.04,
            ), // Or .withValues() for newer flutter
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('$postCount', 'โพสต์', const Color(0xFFF07B3F)),
          _buildDivider(),
          _buildStatItem('$followers', 'ผู้ติดตาม', const Color(0xFF4DA8FF)),
          _buildDivider(),
          _buildStatItem('$following', 'กำลังติดตาม', const Color(0xFF7C4DFF)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, Color accentColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[200]);
  }
}
