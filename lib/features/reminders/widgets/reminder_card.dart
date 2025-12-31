import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/models/reminder_model.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/reminders/providers/reminder_provider.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class ReminderCard extends ConsumerWidget {
  final ReminderModel reminder;

  const ReminderCard({super.key, required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              AppIcons.alarm(),
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.medicineName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.time, // Already in "HH:mm" format
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.enabled,
            activeTrackColor: AppColors.primaryBlue,
            onChanged: (value) {
              ref.read(reminderControllerProvider.notifier).updateReminder(
                reminder.copyWith(enabled: value),
              );
            },
          ),
            IconButton(
              icon: Icon(AppIcons.delete(), color: AppColors.errorRed),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Reminder'),
                    content: const Text('Are you sure you want to delete this reminder?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: AppColors.errorRed)),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true && context.mounted) {
                  await ref.read(reminderControllerProvider.notifier).deleteReminder(
                    reminder.id,
                    reminder,  // Pass the full reminder model
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
