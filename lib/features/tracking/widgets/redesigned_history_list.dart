import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/tracking/providers/tracking_provider.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

/// Redesigned history list with left border indicators matching the design
class RedesignedHistoryList extends ConsumerWidget {
  const RedesignedHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsForSelectedDateProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.noActivityForThisDate,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        // Sort by time, most recent first
        final sortedLogs = List<MedicineLogModel>.from(logs)
          ..sort((a, b) => b.takenAt.compareTo(a.takenAt));

        return Column(
          children: sortedLogs.take(10).map((log) => _buildHistoryItem(context, log)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => FutureErrorWidget(
        error: e,
        onRetry: () => ref.invalidate(logsForSelectedDateProvider),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, MedicineLogModel log) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final logDate = DateTime(log.takenAt.year, log.takenAt.month, log.takenAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String dayLabel;
    final locale = Localizations.localeOf(context);
    if (logDate == today) {
      dayLabel = l10n.today;
    } else if (logDate == yesterday) {
      dayLabel = l10n.yesterday;
    } else {
      dayLabel = DateFormat('MMM dd', locale.toString()).format(logDate);
    }

    final timeStr = DateFormat('h:mm a', locale.toString()).format(log.takenAt);

    // Determine status color and icon
    Color borderColor;
    Color iconBgColor;
    Color iconColor;
    IconData icon;

    if (log.status == 'taken') {
      borderColor = AppColors.primaryGreen;
      iconBgColor = AppColors.primaryGreen.withValues(alpha: 0.1);
      iconColor = AppColors.primaryGreen;
      icon = Icons.check_circle;
    } else if (log.status == 'missed') {
      borderColor = AppColors.errorRed;
      iconBgColor = AppColors.errorRed.withValues(alpha: 0.1);
      iconColor = AppColors.errorRed;
      icon = Icons.error;
    } else {
      borderColor = AppColors.textSecondary(context);
      iconBgColor = AppColors.textSecondary(context).withValues(alpha: 0.1);
      iconColor = AppColors.textSecondary(context);
      icon = Icons.do_not_disturb_on;
    }

    final isPast = logDate.isBefore(today);
    final opacity = isPast ? 0.8 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardColor(context)
              : AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.borderLight(context)
                : AppColors.borderLight(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor(context),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Start border indicator
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(12),
                    bottomStart: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Time column
                  SizedBox(
                    width: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          dayLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary(context),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Medicine info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.medicineName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log.notes ?? log.medicineName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
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

