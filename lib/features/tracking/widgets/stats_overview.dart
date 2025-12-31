import 'package:flutter/material.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';

class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'Taken',
            value: '12',
            color: AppColors.successGreen,
            icon: AppIcons.check(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            label: 'Skipped',
            value: '2',
            color: AppColors.errorRed,
            icon: AppIcons.close(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem(
            label: 'Adherence',
            value: '85%',
            color: AppColors.primaryGreen,
            icon: AppIcons.pieChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
