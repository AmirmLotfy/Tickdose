import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/models/reminder_model.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/reminders/providers/reminder_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TimelineItemStatus {
  taken,
  now,
  upcoming,
}

class TimelineItem {
  final ReminderModel reminder;
  final TimelineItemStatus status;
  final String displayTime;
  final DateTime? scheduledTime;

  TimelineItem({
    required this.reminder,
    required this.status,
    required this.displayTime,
    this.scheduledTime,
  });
}

// Provider to get today's timeline items with status
final timelineItemsProvider = FutureProvider<List<TimelineItem>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];

  final remindersAsync = ref.watch(todaysRemindersProvider);
  final reminders = remindersAsync.value ?? [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Get today's logs
  final logsSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('logs')
      .where('takenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
      .where('takenAt', isLessThan: Timestamp.fromDate(today.add(const Duration(days: 1))))
      .get();

  final takenMedicineIds = <String>{};
  for (var doc in logsSnapshot.docs) {
    final data = doc.data();
    final status = data['status'] as String? ?? '';
    if (status == 'taken') {
      takenMedicineIds.add(data['medicineId'] as String? ?? '');
    }
  }

  final items = <TimelineItem>[];
  
  for (var reminder in reminders) {
    // Get first time for this reminder
    final timeStr = reminder.times.isNotEmpty ? reminder.times[0] : reminder.time;
    final timeParts = timeStr.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // Format time as "8:00 AM" or "1:00 PM"
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayTime = '$displayHour:${minute.toString().padLeft(2, '0')} $period';

    // Determine status
    TimelineItemStatus status;
    if (takenMedicineIds.contains(reminder.medicineId)) {
      status = TimelineItemStatus.taken;
    } else if (scheduledTime.isBefore(now) && scheduledTime.add(const Duration(minutes: 30)).isAfter(now)) {
      status = TimelineItemStatus.now;
    } else if (scheduledTime.isBefore(now)) {
      status = TimelineItemStatus.taken; // Past but not taken = considered taken for display
    } else {
      status = TimelineItemStatus.upcoming;
    }

    items.add(TimelineItem(
      reminder: reminder,
      status: status,
      displayTime: displayTime,
      scheduledTime: scheduledTime,
    ));
  }

  // Sort by scheduled time
  items.sort((a, b) {
    if (a.scheduledTime == null || b.scheduledTime == null) return 0;
    return a.scheduledTime!.compareTo(b.scheduledTime!);
  });

  return items;
});

class MedicationTimeline extends ConsumerWidget {
  const MedicationTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(timelineItemsProvider);

    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medication Timeline',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary(context)
                    : AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            // Timeline with vertical line
            Stack(
              children: [
                // Vertical line
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.borderLight(context)
                        : AppColors.borderLight(context),
                  ),
                ),
                // Timeline items
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildTimelineItem(context, item, index == items.length - 1);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTimelineItem(BuildContext context, TimelineItem item, bool isLast) {
    final isTaken = item.status == TimelineItemStatus.taken;
    final isNow = item.status == TimelineItemStatus.now;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsetsDirectional.only(top: 4, end: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTaken
                  ? AppColors.primaryGreen
                  : isNow
                      ? AppColors.darkBackground
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurface
                          : AppColors.textTertiary(context)),
              border: Border.all(
                color: isNow
                    ? AppColors.primaryGreen
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBackground
                        : AppColors.cardColor(context)),
                width: isNow ? 2 : (isTaken ? 4 : 2),
              ),
              boxShadow: isNow
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: isTaken
                ? Icon(
                    Icons.check,
                    size: 12,
                    color: AppColors.textPrimary(context),
                  )
                : isNow
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen,
                          ),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(seconds: 1),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: 0.5 + (0.5 * (1 - value).abs()),
                                child: child,
                              );
                            },
                            onEnd: () {},
                          ),
                        ),
                      )
                    : Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.textTertiary(context)
                                : AppColors.textSecondary(context),
                          ),
                        ),
                      ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time label
                if (isNow)
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsetsDirectional.only(end: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        'NOW',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    item.displayTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondary(context)
                          : AppColors.textTertiary(context),
                    ),
                  ),
                const SizedBox(height: 8),
                // Medicine card
                Opacity(
                  opacity: isTaken ? 0.6 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isNow
                          ? AppColors.primaryGreen.withValues(alpha: 0.15)
                          : AppColors.cardColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isNow
                            ? AppColors.primaryGreen.withValues(alpha: 0.3)
                            : (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.borderLight(context)
                                : AppColors.borderLight(context)),
                      ),
                      boxShadow: isNow
                          ? [
                              BoxShadow(
                                color: AppColors.shadowColor(context),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: AppColors.shadowColorLight(context),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isNow
                                ? AppColors.primaryGreen.withValues(alpha: 0.2)
                                : (Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkSurface
                                    : AppColors.surfaceColor(context)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isTaken
                                ? Icons.medication
                                : isNow
                                    ? Icons.medication
                                    : Icons.nightlight,
                            color: isTaken
                                ? AppColors.primaryGreen.withValues(alpha: 0.5)
                                : isNow
                                    ? AppColors.primaryGreen
                                    : (Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.textSecondary(context)
                                        : AppColors.textTertiary(context)),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.reminder.medicineName,
                                style: TextStyle(
                                  fontSize: isNow ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cardColor(context),
                                  decoration: isTaken
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: AppColors.textSecondary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.reminder.dosage} • ${_getDosageText(item.reminder)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isNow
                                      ? AppColors.borderLight(context)
                                      : AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status icon or action button
                        if (isTaken)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primaryGreen,
                            size: 24,
                          )
                        else if (isNow)
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to take medicine action
                              // This would trigger the medicine tracking
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: AppColors.darkBackground,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Take',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.schedule,
                            color: AppColors.textTertiary(context),
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDosageText(ReminderModel reminder) {
    // Extract quantity from dosage if possible, otherwise return generic text
    if (reminder.dosage.toLowerCase().contains('tablet')) {
      return '1 Tablet';
    } else if (reminder.dosage.toLowerCase().contains('capsule')) {
      return '1 Capsule';
    } else if (reminder.dosage.toLowerCase().contains('mg')) {
      return reminder.dosage;
    }
    return reminder.dosage;
  }
}

