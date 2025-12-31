import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/services/accessibility_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';

final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  return AccessibilityService();
});

class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends ConsumerState<AccessibilitySettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize accessibility service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accessibilityServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(accessibilityServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Accessibility Settings',
            style: AppTextStyles.h2(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize the app to make it easier to use',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Large Text Mode
          Card(
            child: SwitchListTile(
              title: const Text('Large Text Mode'),
              subtitle: const Text('Increase text size to 48pt minimum'),
              value: service.isLargeTextEnabled(),
              onChanged: (value) async {
                await service.setLargeTextEnabled(value);
                setState(() {}); // Rebuild to show changes
              },
              activeThumbColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Text Size Slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Text Size',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${(service.getTextSizeMultiplier() * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: service.getTextSizeMultiplier(),
                    min: 1.0,
                    max: 3.0,
                    divisions: 20,
                    label: '${(service.getTextSizeMultiplier() * 100).toInt()}%',
                    onChanged: (value) async {
                      await service.setTextSizeMultiplier(value);
                      setState(() {});
                    },
                  ),
                  Text(
                    'Adjust text size from 100% to 300%',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // High Contrast
          Card(
            child: SwitchListTile(
              title: const Text('High Contrast Mode'),
              subtitle: const Text('WCAG AAA compliant (7:1 contrast ratio)'),
              value: service.isHighContrastEnabled(),
              onChanged: (value) async {
                await service.setHighContrastEnabled(value);
                setState(() {});
              },
              activeThumbColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Simplified Mode
          Card(
            child: SwitchListTile(
              title: const Text('Simplified Mode'),
              subtitle: const Text('Hide advanced features, larger buttons'),
              value: service.isSimplifiedModeEnabled(),
              onChanged: (value) async {
                await service.setSimplifiedModeEnabled(value);
                setState(() {});
              },
              activeThumbColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Voice Navigation
          Card(
            child: SwitchListTile(
              title: const Text('Voice Navigation'),
              subtitle: const Text('Navigate the app using voice commands'),
              value: service.isVoiceNavigationEnabled(),
              onChanged: (value) async {
                await service.setVoiceNavigationEnabled(value);
                setState(() {});
              },
              activeThumbColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Haptic Feedback
          Card(
            child: SwitchListTile(
              title: const Text('Haptic Feedback'),
              subtitle: const Text('Vibration feedback on button presses'),
              value: service.isHapticFeedbackEnabled(),
              onChanged: (value) async {
                await service.setHapticFeedbackEnabled(value);
                setState(() {});
                // Test haptic feedback
                if (value) {
                  HapticFeedback.mediumImpact();
                }
              },
              activeThumbColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Voice Confirmations
          Card(
            child: SwitchListTile(
              title: const Text('Voice Confirmations'),
              subtitle: const Text('Announce actions via voice'),
              value: service.isVoiceConfirmationsEnabled(),
              onChanged: (value) async {
                await service.setVoiceConfirmationsEnabled(value);
                setState(() {});
              },
              activeThumbColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),

          // Test button
          ElevatedButton.icon(
            onPressed: () {
              // Test all accessibility features
              if (service.isHapticFeedbackEnabled()) {
                HapticFeedback.mediumImpact();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Accessibility features active')),
              );
            },
            icon: const Icon(Icons.accessibility_new),
            label: const Text('Test Accessibility'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
