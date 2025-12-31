import 'package:flutter/material.dart';

/// Pulse glow widget that creates a pulsing shadow/glow effect
/// Useful for creating glowing effects behind logos or important elements
class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;
  final double blurRadius;
  final double spreadRadius;

  const PulseGlow({
    super.key,
    required this.child,
    required this.glowColor,
    this.duration = const Duration(milliseconds: 2000),
    this.minOpacity = 0.1,
    this.maxOpacity = 0.3,
    this.blurRadius = 60.0,
    this.spreadRadius = 20.0,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
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
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: _opacityAnimation.value),
                blurRadius: widget.blurRadius,
                spreadRadius: widget.spreadRadius,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

