import 'package:flutter/material.dart';

/// Breathe animation widget that scales and pulses brightness
/// Scale: 1.0 → 1.05 with brightness pulse (3s infinite)
class BreatheAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const BreatheAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 3000),
    this.minScale = 1.0,
    this.maxScale = 1.05,
  });

  @override
  State<BreatheAnimation> createState() => _BreatheAnimationState();
}

class _BreatheAnimationState extends State<BreatheAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _brightnessAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _brightnessAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: _brightnessAnimation.value - 1.0),
              BlendMode.overlay,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

