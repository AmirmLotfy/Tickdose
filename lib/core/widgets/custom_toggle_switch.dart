import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom toggle switch matching the design specifications
/// Height: 31px, Width: 51px with green primary when checked
class CustomToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.primaryGreen;
    final inactive = inactiveColor ?? Colors.black.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 31,
        width: 51,
        decoration: BoxDecoration(
          color: value ? active : inactive,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: Colors.transparent,
            width: 0,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 20 : 2,
              top: 2,
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

