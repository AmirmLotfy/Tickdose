import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/icons/app_icons.dart';
import '../../../l10n/generated/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.termsOfServiceTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l10n),
            const SizedBox(height: 24),
            _buildSection(
              l10n.licenseToUse,
              l10n.licenseToUseContent,
            ),
            _buildSection(
              l10n.restrictions,
              l10n.restrictionsContent,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.warningOrange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.warning(), color: AppColors.warningOrange),
                      const SizedBox(width: 8),
                      Text(
                        l10n.medicalDisclaimer,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warningOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.medicalDisclaimerContent,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              l10n.userResponsibilities,
              l10n.userResponsibilitiesContent,
            ),
            _buildSection(
              l10n.limitationOfLiability,
              l10n.limitationOfLiabilityContent,
            ),
            _buildSection(
              l10n.termination,
              l10n.terminationContent,
            ),
            _buildSection(
              l10n.changesToTerms,
              l10n.changesToTermsContent,
            ),
            _buildSection(
              l10n.contactUsTerms,
              l10n.contactUsTermsContent,
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
          AppIcons.gavel(),
          size: 48,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.termsOfServiceTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.termsOfServiceIntro,
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
