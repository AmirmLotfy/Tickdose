import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/tracking/providers/tracking_provider.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';

/// Redesigned calendar widget matching the design with status dots
class RedesignedCalendarWidget extends ConsumerStatefulWidget {
  const RedesignedCalendarWidget({super.key});

  @override
  ConsumerState<RedesignedCalendarWidget> createState() => _RedesignedCalendarWidgetState();
}

class _RedesignedCalendarWidgetState extends ConsumerState<RedesignedCalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final user = ref.watch(authStateProvider).value;
    
    // Get logs for the month to show status dots
    final logsAsync = user != null
        ? ref.watch(logsForCurrentMonthProvider)
        : const AsyncValue.data(<MedicineLogModel>[]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardColor(context)
            : AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight(context),
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
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: AppColors.textSecondary(context),
                ),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary(context),
                ),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Days of week header
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary(context),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          logsAsync.when(
            data: (logs) => _buildCalendarGrid(context, selectedDate, logs),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, DateTime selectedDate, List<MedicineLogModel> logs) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7; // 0 = Sunday
    final daysInMonth = lastDay.day;

    // Create a map of day -> status for quick lookup
    final statusMap = <int, String>{};
    for (var log in logs) {
      final takenAt = log.takenAt;
      if (takenAt.month == _currentMonth.month && takenAt.year == _currentMonth.year) {
        final day = takenAt.day;
        final status = log.status;
        // Keep the most recent status if multiple logs per day, prefer 'taken'
        if (!statusMap.containsKey(day) || status == 'taken') {
          statusMap[day] = status;
        }
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: firstWeekday + daysInMonth,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return const SizedBox.shrink(); // Empty cells before first day
        }

        final day = index - firstWeekday + 1;
        final dayDate = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isSelected = dayDate.year == selectedDate.year &&
            dayDate.month == selectedDate.month &&
            dayDate.day == selectedDate.day;
        final isToday = dayDate.year == DateTime.now().year &&
            dayDate.month == DateTime.now().month &&
            dayDate.day == DateTime.now().day;
        final status = statusMap[day];

        return _buildDayCell(context, day, isSelected, isToday, status, dayDate);
      },
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    int day,
    bool isSelected,
    bool isToday,
    String? status,
    DateTime dayDate,
  ) {
    Color dotColor = AppColors.textSecondary(context);
    if (status == 'taken') {
      dotColor = AppColors.primaryGreen;
    } else if (status == 'missed') {
      dotColor = AppColors.errorRed;
    } else if (status == 'skipped') {
      dotColor = AppColors.textSecondary(context);
    }

    return GestureDetector(
      onTap: () {
        ref.read(selectedDateProvider.notifier).setDate(dayDate);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSelected)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: AppColors.darkBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Text(
              day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
            ),
          if (status != null && !isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: status == 'taken'
                    ? [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

