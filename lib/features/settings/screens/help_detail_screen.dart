import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HelpDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const HelpDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }
}
