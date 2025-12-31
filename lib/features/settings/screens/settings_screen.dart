import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/widgets/custom_toggle_switch.dart';
import 'package:tickdose/core/constants/app_constants.dart';
import 'package:tickdose/features/profile/providers/settings_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: Column(
        children: [
          // Sticky glassmorphic header
          _buildHeader(context, l10n),
          // Main content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                const SizedBox(height: 8),
                // Preferences Section
                _buildSectionHeader(context, AppLocalizations.of(context)!.preferences),
                _buildPreferencesSection(context, ref, settings, l10n),
                const SizedBox(height: 16),
                // Notifications Section
                _buildSectionHeader(context, l10n.notificationsLabel),
                _buildNotificationsSection(context, ref, settings, l10n),
                const SizedBox(height: 16),
                // Privacy & Security Section
                _buildSectionHeader(context, AppLocalizations.of(context)!.privacySecurity),
                _buildPrivacySection(context, ref, settings, l10n),
                // Version footer
                _buildVersionFooter(context),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight(context),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                  color: AppColors.textPrimary(context),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
                    shape: const CircleBorder(),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.settings,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.015,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance for back button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.textSecondary(context),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Language
          _buildSettingsItem(
            context: context,
            icon: Icons.translate,
            iconColor: AppColors.infoBlue,
            title: l10n.language,
            subtitle: settings.language == 'ar' ? l10n.arabic : l10n.english,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  settings.language == 'ar' ? l10n.arabic : l10n.english,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary(context),
                  size: 20,
                ),
              ],
            ),
            onTap: () => _showLanguageBottomSheet(context, ref, l10n),
            showBorder: true,
          ),
          // Dark Mode
          _buildSettingsItem(
            context: context,
            icon: Icons.dark_mode,
            iconColor: AppColors.secondaryPurple,
            title: l10n.darkModeLabel,
            trailing: CustomToggleSwitch(
              value: settings.darkMode,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleDarkMode(value);
                // Note: Actual theme switching would need to be handled at app level
              },
            ),
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Medication Reminders
          _buildSettingsItem(
            context: context,
            icon: Icons.medication,
            iconColor: AppColors.primaryGreen,
            title: AppLocalizations.of(context)!.medicationReminders,
            trailing: CustomToggleSwitch(
              value: settings.notificationsEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleNotifications(value);
              },
            ),
            showBorder: true,
          ),
          // Refill Alerts
          _buildSettingsItem(
            context: context,
            icon: Icons.medication,
            iconColor: AppColors.warningOrange,
            title: AppLocalizations.of(context)!.refillAlerts,
            trailing: CustomToggleSwitch(
              value: settings.notificationsEnabled, // Using same for now
              onChanged: (value) {
                // Add refill alerts toggle if needed
              },
            ),
            showBorder: true,
          ),
          // Health Analysis
          _buildSettingsItem(
            context: context,
            icon: Icons.monitor_heart,
            iconColor: AppColors.primaryTeal,
            title: AppLocalizations.of(context)!.healthAnalysis,
            trailing: CustomToggleSwitch(
              value: false, // Default off
              onChanged: (value) {
                // Add health analysis toggle if needed
              },
            ),
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(
    BuildContext context,
    WidgetRef ref,
    SettingsModel settings,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Privacy Policy
          _buildSettingsItem(
            context: context,
            icon: Icons.lock,
            iconColor: AppColors.textSecondary(context),
            title: l10n.privacyPolicyTitle,
            trailing: Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary(context),
              size: 20,
            ),
            onTap: () => Navigator.pushNamed(context, Routes.privacyPolicy),
            showBorder: true,
          ),
          // Delete Account
          _buildSettingsItem(
            context: context,
            icon: Icons.delete,
            iconColor: AppColors.errorRed,
            title: l10n.deleteAccountLabel,
            titleColor: AppColors.errorRed,
            trailing: const SizedBox.shrink(),
            onTap: () {
              // Show delete account confirmation
              _showDeleteAccountDialog(context, l10n);
            },
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Text(
        'Tickdose Version ${AppConstants.appVersion} (Build 2024)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textTertiary(context),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    bool showBorder = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.borderLight(context),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Trailing widget
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectLanguage,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: Text(
                  l10n.english,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
                trailing: ref.watch(settingsProvider).language == 'en'
                    ? const Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
                title: Text(
                  l10n.arabic,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
                trailing: ref.watch(settingsProvider).language == 'ar'
                    ? const Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setLanguage('ar');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor(context),
        title: Text(
          l10n.deleteAccountLabel,
          style: TextStyle(color: AppColors.errorRed),
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteAccountConfirmation,
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelButton, style: TextStyle(color: AppColors.textPrimary(context))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle account deletion
            },
            child: Text(AppLocalizations.of(context)!.deleteButton, style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}
