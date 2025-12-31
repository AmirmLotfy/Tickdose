import 'package:flutter/material.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Beautiful, branded permission dialog that matches app design
class PermissionDialog extends StatelessWidget {
  final String title;
  final String description;
  final String? detailedDescription;
  final IconData icon;
  final VoidCallback onGrant;
  final VoidCallback? onDeny;
  final bool showSettingsLink;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.description,
    this.detailedDescription,
    required this.icon,
    required this.onGrant,
    this.onDeny,
    this.showSettingsLink = true,
  });

  /// Show location permission dialog
  static Future<bool?> showLocationPermission(
    BuildContext context, {
    required VoidCallback onGrant,
    VoidCallback? onDeny,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: l10n.enableLocationServices,
        description: l10n.locationServicesDescription,
        detailedDescription: l10n.locationServicesDetailedDescription,
        icon: Icons.location_on_rounded,
        onGrant: onGrant,
        onDeny: onDeny,
      ),
    );
  }

  /// Show camera permission dialog
  static Future<bool?> showCameraPermission(
    BuildContext context, {
    required VoidCallback onGrant,
    VoidCallback? onDeny,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: l10n.enableCameraAccess,
        description: l10n.cameraAccessDescription,
        icon: AppIcons.camera(),
        onGrant: onGrant,
        onDeny: onDeny,
      ),
    );
  }

  /// Show microphone permission dialog
  static Future<bool?> showMicrophonePermission(
    BuildContext context, {
    required VoidCallback onGrant,
    VoidCallback? onDeny,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        title: l10n.enableMicrophoneAccess,
        description: l10n.microphoneAccessDescription,
        icon: AppIcons.mic(),
        onGrant: onGrant,
        onDeny: onDeny,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor(context),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Container(
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.lightBackground,
                  size: 40,
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: AppTextStyles.h2(context).copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                description,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontSize: 15,
                  color: AppColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Detailed description (if provided)
            if (detailedDescription != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    detailedDescription!,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Settings link (optional)
            if (showSettingsLink)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('app-settings:');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.youCanChangeAnytimeInSettings,
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.primaryGreen,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Deny button
                  if (onDeny != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          onDeny?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                      side: BorderSide(
                        color: AppColors.borderLight(context),
                      ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.notNow,
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Grant button
                  Expanded(
                    flex: onDeny != null ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        onGrant();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.darkBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.allow,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: AppColors.darkBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
