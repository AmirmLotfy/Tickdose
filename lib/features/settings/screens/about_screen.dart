import 'package:flutter/material.dart';
import 'package:tickdose/core/constants/app_constants.dart';
import 'package:tickdose/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/tickdose-logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            const SizedBox(height: 32),
            const Text(
              'TICKDOSE helps you manage your medications and never miss a dose.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Text(
              '© 2024 TICKDOSE. All rights reserved.',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ],
        ),
      ),
    );
  }
}
