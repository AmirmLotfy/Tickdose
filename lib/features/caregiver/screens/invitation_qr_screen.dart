import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tickdose/core/services/qr_code_service.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

/// Screen to display invitation QR code and sharing options
class InvitationQRScreen extends StatelessWidget {
  final String invitationToken;
  final String caregiverEmail;

  const InvitationQRScreen({
    super.key,
    required this.invitationToken,
    required this.caregiverEmail,
  });

  void _copyInvitationUrl(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.invitationLinkCopied),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _copyToken(BuildContext context, String token) {
    Clipboard.setData(ClipboardData(text: token));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.invitationCodeCopied),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  Future<void> _shareInvitation(BuildContext context, String url) async {
    try {
      // ignore: deprecated_member_use
      await Share.share(
        AppLocalizations.of(context)!.shareInvitationText(url, invitationToken),
        subject: AppLocalizations.of(context)!.shareInvitationSubject,
      );
    } catch (e) {
      Logger.error('Error sharing invitation: $e', tag: 'InvitationQR');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorSharing(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrService = QRCodeService();
    final invitationUrl = qrService.generateInvitationUrl(invitationToken);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.invitationTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Text(
            AppLocalizations.of(context)!.shareInvitationTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.shareInvitationSubtitle(caregiverEmail),
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // QR Code Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.scanQrCodeTitle,
                    style: AppTextStyles.h3(context),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: qrService.generateQRWidget(
                      token: invitationToken,
                      size: 250,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.scanQrCodeDescription,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Invitation Link Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.invitationLinkTitle,
                    style: AppTextStyles.h3(context),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            invitationUrl,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyInvitationUrl(context, invitationUrl),
                          tooltip: AppLocalizations.of(context)!.copyLinkTooltip,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Manual Token Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.invitationCodeLabel,
                    style: AppTextStyles.h3(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.ifQrNotWorking,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            invitationToken,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyToken(context, invitationToken),
                          tooltip: AppLocalizations.of(context)!.copyCodeTooltip,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Share Button
          ElevatedButton.icon(
            onPressed: () => _shareInvitation(context, invitationUrl),
            icon: const Icon(Icons.share),
            label: Text(AppLocalizations.of(context)!.shareInvitationButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),

          // Instructions
          Card(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.howToShareTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionItem(
                    context,
                    AppLocalizations.of(context)!.howToShareStep1Title,
                    AppLocalizations.of(context)!.howToShareStep1Desc,
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem(
                    context,
                    AppLocalizations.of(context)!.howToShareStep2Title,
                    AppLocalizations.of(context)!.howToShareStep2Desc,
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem(
                    context,
                    AppLocalizations.of(context)!.howToShareStep3Title,
                    AppLocalizations.of(context)!.howToShareStep3Desc,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
