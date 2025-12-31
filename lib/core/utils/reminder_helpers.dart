import 'package:flutter/material.dart';
import 'package:tickdose/core/models/reminder_model.dart';
import '../icons/app_icons.dart';

class DefaultTimes {
  static const morning = TimeOfDay(hour: 8, minute: 0);     // 8:00 AM
  static const midday = TimeOfDay(hour: 13, minute: 0);     // 1:00 PM  
  static const evening = TimeOfDay(hour: 19, minute: 0);    // 7:00 PM
  static const night = TimeOfDay(hour: 22, minute: 0);      // 10:00 PM
  
  static const breakfast = TimeOfDay(hour: 8, minute: 0);   // 8:00 AM
  static const lunch = TimeOfDay(hour: 13, minute: 0);      // 1:00 PM
  static const dinner = TimeOfDay(hour: 19, minute: 0);     // 7:00 PM
  static const bedtime = TimeOfDay(hour: 22, minute: 0);    // 10:00 PM
}

class IntervalCalculator {
  /// Calculate reminder times for interval-based schedules
  static List<TimeOfDay> calculateSchedule({
    required TimeOfDay startTime,
    required int intervalHours,
    required bool includeOvernight,
  }) {
    final List<TimeOfDay> times = [];
    int currentHour = startTime.hour;
    int currentMinute = startTime.minute;
    
    // Add first time
    times.add(TimeOfDay(hour: currentHour, minute: currentMinute));
    
    // Calculate subsequent times
    while (times.length < 24 / intervalHours) {
      currentHour += intervalHours;
      
      if (currentHour >= 24) {
        if (!includeOvernight) break;
        currentHour -= 24;
      }
      
      times.add(TimeOfDay(hour: currentHour, minute: currentMinute));
      
      // Stop if we've gone past midnight and not including overnight
      if (!includeOvernight && currentHour < startTime.hour) break;
    }
    
    return times;
  }
  
  /// Get schedule for every 8 hours
  static List<TimeOfDay> getEvery8Hours(TimeOfDay start, bool overnight) {
    return calculateSchedule(
      startTime: start,
      intervalHours: 8,
      includeOvernight: overnight,
    );
  }
  
  /// Get schedule for every 12 hours (exactly 2 times)
  static List<TimeOfDay> getEvery12Hours(TimeOfDay start) {
    final secondTime = TimeOfDay(
      hour: (start.hour + 12) % 24,
      minute: start.minute,
    );
    return [start, secondTime];
  }
  
  /// Get schedule for every 6 hours (4 times daily)
  static List<TimeOfDay> getEvery6Hours(TimeOfDay start) {
    return calculateSchedule(
      startTime: start,
      intervalHours: 6,
      includeOvernight: true,
    );
  }
}

class FrequencyHelpers {
  /// Get description for frequency
  static String getDescription(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.onceDaily:
        return 'Best for daily vitamins, blood pressure meds';
      case ReminderFrequency.twiceDaily:
        return 'Morning and evening, 12 hours apart';
      case ReminderFrequency.threeTimes:
        return 'Breakfast, lunch, and dinner times';
      case ReminderFrequency.fourTimes:
        return 'Every 6 hours throughout the day';
      case ReminderFrequency.every8Hours:
        return '3 times daily with consistent intervals';
      case ReminderFrequency.every12Hours:
        return 'Strict 12-hour intervals (e.g., antibiotics)';
      case ReminderFrequency.withMeals:
        return 'Take with breakfast, lunch, or dinner';
      case ReminderFrequency.custom:
        return 'Set your own schedule';
    }
  }
  
  /// Get icon for frequency
  static IconData getIcon(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.onceDaily:
        return AppIcons.alarm();
      case ReminderFrequency.twiceDaily:
        return AppIcons.alarm();
      case ReminderFrequency.threeTimes:
        return AppIcons.alarm();
      case ReminderFrequency.fourTimes:
        return AppIcons.alarm();
      case ReminderFrequency.every8Hours:
        return AppIcons.time();
      case ReminderFrequency.every12Hours:
        return AppIcons.time();
      case ReminderFrequency.withMeals:
        return AppIcons.medical();
      case ReminderFrequency.custom:
        return AppIcons.settings();
    }
  }
  
  /// Get default times for frequency
  static List<TimeOfDay> getDefaultTimes(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.onceDaily:
        return [DefaultTimes.morning];
      case ReminderFrequency.twiceDaily:
        return [DefaultTimes.morning, DefaultTimes.evening];
      case ReminderFrequency.threeTimes:
        return [DefaultTimes.morning, DefaultTimes.midday, DefaultTimes.evening];
      case ReminderFrequency.fourTimes:
        return IntervalCalculator.getEvery6Hours(DefaultTimes.morning);
      case ReminderFrequency.every8Hours:
        return IntervalCalculator.getEvery8Hours(DefaultTimes.morning, false);
      case ReminderFrequency.every12Hours:
        return IntervalCalculator.getEvery12Hours(DefaultTimes.morning);
      case ReminderFrequency.withMeals:
        return [DefaultTimes.breakfast, DefaultTimes.lunch, DefaultTimes.dinner];
      case ReminderFrequency.custom:
        return [DefaultTimes.morning];
    }
  }
}

/// Extension to convert TimeOfDay to String
extension TimeOfDayExtension on TimeOfDay {
  String toFormattedString() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Extension to parse String to TimeOfDay
extension TimeOfDayParsing on String {
  TimeOfDay toTimeOfDay() {
    final parts = split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
