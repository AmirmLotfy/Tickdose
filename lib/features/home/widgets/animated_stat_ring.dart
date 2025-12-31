import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated circular progress ring that wraps around content
/// Implements 2025 design trend of animated progress indicators
class AnimatedStatRing extends StatefulWidget {
  final Widget child;
  final double progress; // 0.0 to 1.0
  final Color color;
  final Color? secondaryColor;
  final double strokeWidth;
  final double size;
  final bool animate;

  const AnimatedStatRing({
    super.key,
    required this.child,
    required this.progress,
    required this.color,
    this.secondaryColor,
    this.strokeWidth = 3.0,
    this.size = 80,
    this.animate = true,
  });

  @override
  State<AnimatedStatRing> createState() => _AnimatedStatRingState();
}

class _AnimatedStatRingState extends State<AnimatedStatRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedStatRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RingPainter(
              progress: 1.0,
              color: (widget.secondaryColor ?? widget.color).withValues(alpha: 0.1),
              strokeWidth: widget.strokeWidth,
            ),
          ),
          // Animated progress ring
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: widget.animate ? _animation.value : widget.progress,
                  color: widget.color,
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),
          // Child content in center
          widget.child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Start from top (-90 degrees) and draw clockwise
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
