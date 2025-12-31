import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Weekly/Monthly view toggle matching the design
class ViewToggle extends StatelessWidget {
  final String selectedView; // 'Weekly' or 'Monthly'
  final ValueChanged<String> onChanged;

  const ViewToggle({
    super.key,
    required this.selectedView,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              context,
              label: 'Weekly',
              isSelected: selectedView == 'Weekly',
              onTap: () => onChanged('Weekly'),
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              context,
              label: 'Monthly',
              isSelected: selectedView == 'Monthly',
              onTap: () => onChanged('Monthly'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cardColor(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadowColor(context),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? AppColors.textPrimary(context)
                  : AppColors.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}

