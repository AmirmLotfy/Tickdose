import 'package:flutter/material.dart';

/// Text widget with gradient color effect
/// Implements 2025 design trend of gradient typography
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  const GradientText({
    super.key,
    required this.text,
    required this.gradient,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style?.copyWith(color: Colors.white) ?? 
               const TextStyle(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}
