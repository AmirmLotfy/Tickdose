import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/icons/app_icons.dart';

/// Standardized error widget with retry button and localized messages
class StandardErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? title;
  final String? subtitle;

  const StandardErrorWidget({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.icon,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 64,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 24),
            Text(
              title ?? l10n?.somethingWentWrong ?? 'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (subtitle != null || errorMessage != null)
              Text(
                subtitle ?? errorMessage ?? l10n?.errorOccurredMessage ?? 'An error occurred',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n?.tryAgain ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.backgroundColor(context),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper widget for StreamBuilder error handling
class StreamErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const StreamErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return StandardErrorWidget(
      errorMessage: error.toString(),
      onRetry: onRetry,
    );
  }
}

/// Helper widget for FutureBuilder error handling
class FutureErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const FutureErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return StandardErrorWidget(
      errorMessage: error.toString(),
      onRetry: onRetry,
    );
  }
}

