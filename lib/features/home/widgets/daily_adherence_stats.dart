import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/reminders/providers/reminder_provider.dart';
import 'package:tickdose/core/utils/adherence_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider for today's stats
final todayStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return {
      'taken': 0,
      'missed': 0,
      'remaining': 0,
      'adherence': 0.0,
    };
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final endOfDay = today.add(const Duration(days: 1));

  // Get today's logs
  final logsSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('logs')
      .where('takenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
      .where('takenAt', isLessThan: Timestamp.fromDate(endOfDay))
      .get();

  int taken = 0;
  int missed = 0;

  for (var doc in logsSnapshot.docs) {
    final data = doc.data();
    final status = data['status'] as String? ?? '';
    if (status == 'taken') {
      taken++;
    } else if (status == 'missed') {
      missed++;
    }
  }

  // Get today's reminders count
  final remindersAsync = ref.watch(todaysRemindersProvider);
  final reminders = remindersAsync.value ?? [];
  final totalReminders = reminders.length;
  final remaining = totalReminders - taken - missed;

  // Calculate adherence
  final adherence = totalReminders > 0
      ? AdherenceCalculator.calculateAdherence(taken, totalReminders)
      : 0.0;

  return {
    'taken': taken,
    'missed': missed,
    'remaining': remaining.clamp(0, totalReminders),
    'adherence': adherence,
  };
});

class DailyAdherenceStats extends ConsumerWidget {
  const DailyAdherenceStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(todayStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final taken = stats['taken'] as int;
        final missed = stats['missed'] as int;
        final remaining = stats['remaining'] as int;
        final adherence = stats['adherence'] as double;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with percentage badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Adherence',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondary(context)
                        : AppColors.textPrimary(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${adherence.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : AppColors.borderLight(context),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: adherence / 100.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 3-column stat grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'Taken',
                    value: taken.toString(),
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'Missed',
                    value: missed.toString(),
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'Remaining',
                    value: remaining.toString(),
                    color: AppColors.cardColor(context),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderLight(context)
              : AppColors.borderLight(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColorLight(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondary(context)
                  : AppColors.textTertiary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

