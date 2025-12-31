import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/services/biometric_auth_service.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';

// Privacy Settings Providers
// Privacy Settings Providers
final biometricEnabledProvider = NotifierProvider<BiometricSettingNotifier, bool>(BiometricSettingNotifier.new);

class BiometricSettingNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('biometric_enabled') ?? false;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
    
    // Clear stored credentials if biometric is disabled
    if (!value) {
      try {
        final biometricService = BiometricAuthService();
        await biometricService.clearStoredCredentials();
      } catch (e) {
        // Log error but don't block the toggle
        Logger.error('Error clearing biometric credentials: $e');
      }
    }
  }
}

final healthDataSharingProvider = NotifierProvider<HealthDataSharingNotifier, bool>(HealthDataSharingNotifier.new);

class HealthDataSharingNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('health_data_sharing') ?? false;
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('health_data_sharing', value);
  }
}

final aiFeaturesEnabledProvider = NotifierProvider<AIFeaturesNotifier, bool>(AIFeaturesNotifier.new);

class AIFeaturesNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true; // Default enabled
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('ai_features_enabled') ?? true; // Default to enabled
  }

  Future<void> toggle(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_features_enabled', value);
  }
}

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final healthDataSharing = ref.watch(healthDataSharingProvider);
    final aiFeaturesEnabled = ref.watch(aiFeaturesEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Privacy Settings',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Privacy & Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Control how your data is used and shared',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 24),
          
          // AI Features Toggle
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight(context),
                width: 1,
              ),
            ),
            child: SwitchListTile(
              title: Text(
                'Enable AI Features',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Use Google Generative AI (Gemini) for symptom analysis and medication information enrichment. You can disable this at any time.',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              value: aiFeaturesEnabled,
              onChanged: (value) {
                ref.read(aiFeaturesEnabledProvider.notifier).toggle(value);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value 
                          ? 'AI features enabled. Your conversations will be processed by Google Gemini.'
                          : 'AI features disabled. Symptom analysis will be limited.',
                    ),
                    duration: const Duration(seconds: 3),
                    backgroundColor: value ? AppColors.successGreen : AppColors.warningOrange,
                  ),
                );
              },
              activeTrackColor: AppColors.primaryGreen,
              activeColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          
          // Biometric Login
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight(context),
                width: 1,
              ),
            ),
            child: SwitchListTile(
              title: Text(
                'Enable Biometric Login',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Use fingerprint or face ID to login',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              value: biometricEnabled,
              onChanged: (value) async {
                await ref.read(biometricEnabledProvider.notifier).toggle(value);
                if (!context.mounted) return;
                if (!value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Biometric login disabled. Credentials cleared for security.'),
                      backgroundColor: AppColors.warningOrange,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              activeTrackColor: AppColors.primaryGreen,
              activeColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          
          // Health Data Sharing
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight(context),
                width: 1,
              ),
            ),
            child: SwitchListTile(
              title: Text(
                'Share Health Data',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Allow app to share health insights',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              value: healthDataSharing,
              onChanged: (value) {
                ref.read(healthDataSharingProvider.notifier).toggle(value);
              },
              activeTrackColor: AppColors.primaryGreen,
              activeColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          
          // Location Services (Read-only)
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight(context),
                width: 1,
              ),
            ),
            child: SwitchListTile(
              title: Text(
                'Location Services',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Find nearby pharmacies',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Location permission managed in system settings'),
                    backgroundColor: AppColors.infoBlue,
                  ),
                );
              },
              activeTrackColor: AppColors.primaryGreen,
              activeColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          
          // Privacy Policy Link
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderLight(context),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.privacy_tip_rounded,
                color: AppColors.primaryGreen,
              ),
              title: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Read our privacy policy and data handling practices',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary(context),
              ),
              onTap: () {
                Navigator.pushNamed(context, Routes.privacyPolicy);
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Delete All Data
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.errorRed.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.delete_forever_rounded,
                color: AppColors.errorRed,
              ),
              title: Text(
                'Delete All Data',
                style: TextStyle(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Permanently delete your account and data',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.errorRed,
              ),
              onTap: () {
                Navigator.pushNamed(context, Routes.settings);
              },
            ),
          ),
        ],
      ),
    );
  }
}
