import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/features/tracking/providers/tracking_provider.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class HistoryList extends ConsumerWidget {
  const HistoryList({super.key});

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref, MedicineLogModel log) async {
    String selectedStatus = log.status;
    String notes = log.notes ?? '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Log'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Medicine: ${log.medicineName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'taken', child: Text('Taken')),
                  DropdownMenuItem(value: 'skipped', child: Text('Skipped')),
                  DropdownMenuItem(value: 'missed', child: Text('Missed')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
                controller: TextEditingController(text: notes),
                onChanged: (value) => notes = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final updatedLog = MedicineLogModel(
        id: log.id,
        userId: log.userId,
        medicineId: log.medicineId,
        medicineName: log.medicineName,
        takenAt: log.takenAt,
        status: selectedStatus,
        notes: notes.isEmpty ? null : notes,
      );

      await ref.read(trackingControllerProvider.notifier).updateLog(updatedLog);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log updated successfully')),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, MedicineLogModel log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log?'),
        content: Text('Delete ${log.medicineName} log from ${DateFormat('MMM d, h:mm a').format(log.takenAt)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(trackingControllerProvider.notifier).deleteLog(log.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsForSelectedDateProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                AppLocalizations.of(context)!.noLogsForThisDay,
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final isTaken = log.status == 'taken';
            
            return Dismissible(
              key: Key(log.id),
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                child: Icon(AppIcons.edit(), color: Colors.white),
              ),
              secondaryBackground: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.errorRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                child: Icon(AppIcons.delete(), color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  await _showEditDialog(context, ref, log);
                  return false;
                } else {
                  await _showDeleteDialog(context, ref, log);
                  return false;
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTaken ? AppColors.successGreen.withValues(alpha: 0.3) : AppColors.errorRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isTaken ? AppIcons.check() : AppIcons.close(),
                      color: isTaken ? AppColors.successGreen : AppColors.errorRed,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.medicineName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                DateFormat('hh:mm a', Localizations.localeOf(context).toString()).format(log.takenAt),
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 14,
                                ),
                              ),
                              if (log.notes != null && log.notes!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Icon(AppIcons.note(), size: 16, color: AppColors.textSecondary(context)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(AppIcons.swipe(), size: 16, color: AppColors.textTertiary(context)),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
