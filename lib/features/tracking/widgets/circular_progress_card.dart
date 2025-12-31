import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';

/// Circular progress card showing adherence score with SVG-like circular progress
class CircularProgressCard extends StatelessWidget {
  final double adherenceScore; // 0.0 to 100.0
  final String encouragementText;

  const CircularProgressCard({
    super.key,
    required this.adherenceScore,
    this.encouragementText = 'Excellent job!',
  });

  @override
  Widget build(BuildContext context) {
    final progress = adherenceScore.clamp(0.0, 100.0) / 100.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardColor(context)
            : AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adherence Score',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${adherenceScore.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  encouragementText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Circular progress
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                CustomPaint(
                  size: const Size(96, 96),
                  painter: _CirclePainter(
                    progress: 1.0,
                    color: AppColors.borderLight(context),
                    strokeWidth: 3.5,
                  ),
                ),
                // Progress circle
                CustomPaint(
                  size: const Size(96, 96),
                  painter: _CirclePainter(
                    progress: progress,
                    color: AppColors.primaryGreen,
                    strokeWidth: 3.5,
                    hasGlow: true,
                  ),
                ),
                // Center icon
                Icon(
                  Icons.verified,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool hasGlow;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.hasGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 15.9155; // Matching design
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (hasGlow) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    }

    // Draw arc from top (-90 degrees)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.hasGlow != hasGlow;
  }
}

