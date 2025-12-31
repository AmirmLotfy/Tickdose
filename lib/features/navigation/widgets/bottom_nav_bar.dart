import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickdose/core/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 24, top: 0),
      height: 64, // h-16
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16), // rounded-2xl
        border: Border.all(
          color: AppColors.borderLight(context).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 32, // shadow-[0_8px_32px_rgba(0,0,0,0.5)]
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_outlined, Icons.home),
              _buildNavItem(context, 1, Icons.notifications_outlined, Icons.notifications),
              _buildNavItem(context, 2, Icons.favorite_outline, Icons.monitor_heart), // ecg_heart equivalent
              _buildNavItem(context, 3, Icons.local_pharmacy_outlined, Icons.local_pharmacy),
              _buildNavItem(context, 4, Icons.person_outline, Icons.person),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, IconData activeIcon) {
    final bool isSelected = currentIndex == index;
    final Color activeColor = AppColors.primaryGreen;
    final Color inactiveColor = AppColors.textSecondary(context);

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.selectionClick();
          onTap(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 56, // w-14 equivalent
        height: double.infinity,
        alignment: Alignment.center,
        child: isSelected
            ? Container(
                padding: const EdgeInsets.all(6), // p-1.5 (6px)
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1), // bg-primary/10
                  borderRadius: BorderRadius.circular(12), // rounded-xl
                ),
                child: Icon(
                  activeIcon,
                  color: activeColor,
                  size: 24,
                ),
              )
            : Icon(
                icon,
                color: inactiveColor,
                size: 24,
              ),
      ),
    );
  }
}

