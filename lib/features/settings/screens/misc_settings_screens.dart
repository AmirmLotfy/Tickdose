import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/core/services/firebase_user_service.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacySecurity, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary(context))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.privacyPolicyTitle),
            trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), autoMirror: true),
            onTap: () {
              Navigator.pushNamed(context, Routes.privacyPolicy);
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.termsOfServiceTitle),
            trailing: AppIcons.themedIcon(context, AppIcons.chevronRight(), autoMirror: true),
            onTap: () {
              Navigator.pushNamed(context, Routes.termsOfService);
            },
          ),
          const Divider(),
          Consumer(
            builder: (context, ref, child) {
              return ListTile(
                title: Text(l10n.deleteAccountLabel, style: const TextStyle(color: AppColors.errorRed)),
                subtitle: Text(l10n.deleteAccountPermanently),
                trailing: Icon(AppIcons.delete(), color: AppColors.errorRed),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.deleteAccountQuestion),
                      content: Text(l10n.deleteAccountWarning),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.dialogCancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.dialogDelete, style: const TextStyle(color: AppColors.errorRed)),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    try {
                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      final user = ref.read(authStateProvider).value;
                      if (user == null) throw Exception('No user logged in');

                      // Delete Firestore data
                      await FirebaseUserService().deleteUserProfile(user.uid);

                      // Delete Firebase Auth account
                      await user.delete();

                      // Clear local data
                      await ref.read(authProvider.notifier).signOut();

                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close loading
                        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.accountDeletedSuccess)),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.errorDeletingAccount(e)),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                      }
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary(context))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.medicine(), size: 80, color: AppColors.primaryBlue), // Already fixed
            const SizedBox(height: 16),
            Text('TICKDOSE', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.version, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
            const SizedBox(height: 32),
            Text(l10n.yourPersonalMedicationReminder, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpSupportTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary(context))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.faq, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFAQItem(context, l10n,
            l10n.howToAddMedicine,
            l10n.howToAddMedicineAnswer,
          ),
          _buildFAQItem(context, l10n,
            l10n.howToSetReminders,
            l10n.howToSetRemindersAnswer,
          ),
          _buildFAQItem(context, l10n,
            l10n.canIEditMedicines,
            l10n.canIEditMedicinesAnswer,
          ),
          const SizedBox(height: 32),
          Text(l10n.contactSupport, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
            ListTile(
            leading: Icon(AppIcons.email()),
            title: Text(l10n.emailLabel),
            subtitle: const Text('support@tickdose.app'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, AppLocalizations l10n, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(question, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context))),
          ),
        ],
      ),
    );
  }
}
