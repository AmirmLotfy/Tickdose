import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/icons/app_icons.dart';
import '../../../l10n/generated/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.privacyPolicyTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(AppIcons.share()),
            onPressed: () async {
              // Using Share.share (deprecated but working)
              final box = context.findRenderObject() as RenderBox?;
              // ignore: deprecated_member_use
              await Share.share(
                 l10n.sharePrivacyPolicyText,
                 subject: l10n.sharePrivacyPolicySubject,
                 sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l10n),
            const SizedBox(height: 24),
            _buildSection(
              l10n.whatDataWeCollect,
              l10n.whatDataWeCollectContent,
            ),
            _buildSection(
              l10n.howWeUseYourData,
              l10n.howWeUseYourDataContent,
            ),
            _buildSection(
              l10n.dataStorageSecurity,
              l10n.dataStorageSecurityContent,
            ),
            _buildSection(
              l10n.yourRights,
              l10n.yourRightsContent,
            ),
            _buildSection(
              l10n.thirdPartyServices,
              l10n.thirdPartyServicesContent,
            ),
            _buildSection(
              l10n.contactUsPrivacy,
              l10n.contactUsPrivacyContent,
            ),
            _buildSection(
              l10n.policyChanges,
              l10n.policyChangesContent,
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                l10n.lastUpdated,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          AppIcons.privacy(),
          size: 48,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.yourPrivacyMatters,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.privacyPolicyIntro,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary(context),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
