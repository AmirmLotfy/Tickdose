import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/reminders/providers/reminder_provider.dart';
import 'package:tickdose/features/reminders/widgets/reminder_card.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:tickdose/core/widgets/standard_error_widget.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.reminders,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.alarm(), size: 64, color: AppColors.textTertiary(context)),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noRemindersSet,
                    style: TextStyle(color: AppColors.textSecondary(context), fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              return ReminderCard(reminder: reminders[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => StandardErrorWidget(
          errorMessage: err.toString(),
          onRetry: () => ref.invalidate(remindersStreamProvider),
        ),
      ),
    );
  }
}
