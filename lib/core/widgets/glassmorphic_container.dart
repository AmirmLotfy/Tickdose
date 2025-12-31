import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable glassmorphic container with frosted glass effect
/// Implements 2025 design trend of glassmorphism with backdrop blur
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;
  final Gradient? gradient;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.blur = 10,
    this.opacity = 0.7,
    this.gradient,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.glassBackground(context),
        AppColors.glassBackground(context).withValues(alpha: opacity * 0.8),
      ],
    );

    final defaultBorder = Border.all(
      color: AppColors.glassBorder(context),
      width: 1.5,
    );

    final defaultShadow = [
      BoxShadow(
        color: AppColors.shadowColorLight(context),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: AppColors.shadowColorSoft(context),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ?? defaultGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? defaultBorder,
            boxShadow: boxShadow ?? defaultShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
