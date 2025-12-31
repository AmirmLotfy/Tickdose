import 'package:flutter/material.dart';
import 'package:tickdose/core/models/reminder_model.dart';
import 'package:tickdose/core/utils/reminder_helpers.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';

class FrequencyCard extends StatelessWidget {
  final ReminderFrequency frequency;
  final bool isSelected;
  final VoidCallback onTap;

  const FrequencyCard({
    super.key,
    required this.frequency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = _getTitle();
    final String subtitle = FrequencyHelpers.getDescription(frequency);
    final IconData icon = FrequencyHelpers.getIcon(frequency);
    final Color color = _getColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.check(),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (frequency) {
      case ReminderFrequency.onceDaily:
        return 'Once Daily';
      case ReminderFrequency.twiceDaily:
        return 'Twice Daily';
      case ReminderFrequency.threeTimes:
        return '3x Daily';
      case ReminderFrequency.fourTimes:
        return '4x Daily';
      case ReminderFrequency.every8Hours:
        return 'Every 8 Hours';
      case ReminderFrequency.every12Hours:
        return 'Every 12 Hours';
      case ReminderFrequency.withMeals:
        return 'With Meals';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }

  Color _getColor() {
    switch (frequency) {
      case ReminderFrequency.onceDaily:
        return const Color(0xFF4E73DF); // Blue
      case ReminderFrequency.twiceDaily:
        return const Color(0xFF1CC88A); // Green
      case ReminderFrequency.threeTimes:
        return const Color(0xFFF6C23E); // Yellow/Gold
      case ReminderFrequency.fourTimes:
        return const Color(0xFFE74A3B); // Red
      case ReminderFrequency.every8Hours:
        return const Color(0xFF858796); // Gray
      case ReminderFrequency.every12Hours:
        return const Color(0xFF5A5C69); // Dark Gray
      case ReminderFrequency.withMeals:
        return const Color(0xFFFF6B6B); // Light Red
      case ReminderFrequency.custom:
        return const Color(0xFF36B9CC); // Teal
    }
  }
}
