import 'package:flutter/material.dart';

/// Float animation widget that translates vertically
/// TranslateY: 0 → -10px (6s infinite)
class FloatAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOffset;
  final double maxOffset;

  const FloatAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 6000),
    this.minOffset = 0.0,
    this.maxOffset = -10.0,
  });

  @override
  State<FloatAnimation> createState() => _FloatAnimationState();
}

class _FloatAnimationState extends State<FloatAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<double>(
      begin: widget.minOffset,
      end: widget.maxOffset,
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
        return Transform.translate(
          offset: Offset(0, _offsetAnimation.value),
          child: widget.child,
        );
      },
    );
  }
}

