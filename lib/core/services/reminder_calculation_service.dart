import 'package:timezone/timezone.dart' as tz;
import 'package:tickdose/core/models/reminder_model.dart';
import 'package:tickdose/core/models/user_model.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for calculating reminder times based on user routines and timezone
class ReminderCalculationService {
  static final ReminderCalculationService _instance = ReminderCalculationService._internal();
  factory ReminderCalculationService() => _instance;
  ReminderCalculationService._internal();

  /// Convert meal time name to DateTime based on user's routine
  /// 
  /// [mealTime] - Meal name: "breakfast", "lunch", "dinner", "bedtime"
  /// [user] - UserModel with routine times
  /// [userTimezone] - User's timezone string (e.g., "Africa/Cairo")
  /// [reminder] - ReminderModel for offset calculation
  /// Returns DateTime in user's timezone
  DateTime? convertMealTimeToDateTime({
    required String mealTime,
    required UserModel user,
    required String userTimezone,
    required ReminderModel reminder,
  }) {
    try {
      String? mealTimeString;
      
      switch (mealTime.toLowerCase()) {
        case 'breakfast':
          mealTimeString = user.breakfastTime;
          break;
        case 'lunch':
          mealTimeString = user.lunchTime;
          break;
        case 'dinner':
          mealTimeString = user.dinnerTime;
          break;
        case 'bedtime':
          mealTimeString = user.sleepTime;
          break;
        default:
          Logger.warn('Unknown meal time: $mealTime', tag: 'ReminderCalculation');
          return null;
      }

      if (mealTimeString.isEmpty) {
        Logger.warn('Meal time not set for: $mealTime', tag: 'ReminderCalculation');
        return null;
      }

      // Parse time (HH:mm format)
      final timeParts = mealTimeString.split(':');
      if (timeParts.length != 2) {
        Logger.error('Invalid time format: $mealTimeString', tag: 'ReminderCalculation');
        return null;
      }

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null || minute == null) {
        Logger.error('Invalid time values: $mealTimeString', tag: 'ReminderCalculation');
        return null;
      }

      // Get user's timezone location
      final location = tz.getLocation(userTimezone);
      final now = tz.TZDateTime.now(location);
      
      // Create DateTime for today at the meal time
      var reminderTime = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Apply minutes offset (flexibility window)
      reminderTime = reminderTime.add(Duration(minutes: reminder.minutesOffset));

      // If time has passed today, schedule for tomorrow
      if (reminderTime.isBefore(now)) {
        reminderTime = reminderTime.add(const Duration(days: 1));
      }

      return reminderTime;
    } catch (e) {
      Logger.error('Error converting meal time to DateTime: $e', tag: 'ReminderCalculation');
      return null;
    }
  }

  /// Calculate reminder time from ReminderModel
  /// 
  /// [reminder] - The reminder to calculate times for
  /// [user] - UserModel with routine and timezone info
  /// Returns list of DateTime objects for all reminder times
  List<DateTime> calculateReminderTime({
    required ReminderModel reminder,
    required UserModel user,
  }) {
    final List<DateTime> reminderTimes = [];
    final userTimezone = reminder.isTimezoneAware ? user.timezone : 'UTC';

    try {
      // Handle meal-based reminders
      if (reminder.frequency == ReminderFrequency.withMeals && reminder.mealTimes != null) {
        for (final entry in reminder.mealTimes!.entries) {
          final mealTime = entry.key; // e.g., "breakfast", "lunch"
          final dateTime = convertMealTimeToDateTime(
            mealTime: mealTime,
            user: user,
            userTimezone: userTimezone,
            reminder: reminder,
          );
          
          if (dateTime != null) {
            // Validate against wake/sleep window
            final validatedTime = validateWakeSleepWindow(
              reminderTime: dateTime,
              user: user,
            );
            
            if (validatedTime != null) {
              reminderTimes.add(validatedTime);
            }
          }
        }
      } else {
        // Handle time-based reminders
        for (final timeStr in reminder.times) {
          final dateTime = _parseTimeString(timeStr, userTimezone, reminder.minutesOffset);
          
          if (dateTime != null) {
            final validatedTime = validateWakeSleepWindow(
              reminderTime: dateTime,
              user: user,
            );
            
            if (validatedTime != null) {
              reminderTimes.add(validatedTime);
            }
          }
        }
      }

      return reminderTimes;
    } catch (e) {
      Logger.error('Error calculating reminder times: $e', tag: 'ReminderCalculation');
      // Fallback: return empty list or basic times if calculation fails
      return [];
    }
  }

  /// Parse time string (HH:mm) to DateTime in specified timezone
  DateTime? _parseTimeString(String timeStr, String timezone, int offsetMinutes) {
    try {
      final timeParts = timeStr.split(':');
      if (timeParts.length != 2) return null;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) return null;

      final location = tz.getLocation(timezone);
      final now = tz.TZDateTime.now(location);

      var reminderTime = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Apply offset
      reminderTime = reminderTime.add(Duration(minutes: offsetMinutes));

      // If time has passed, schedule for tomorrow
      if (reminderTime.isBefore(now)) {
        reminderTime = reminderTime.add(const Duration(days: 1));
      }

      return reminderTime;
    } catch (e) {
      Logger.error('Error parsing time string: $e', tag: 'ReminderCalculation');
      return null;
    }
  }

  /// Validate reminder time is within wake/sleep window
  /// 
  /// Returns adjusted DateTime or null if outside window
  DateTime? validateWakeSleepWindow({
    required DateTime reminderTime,
    required UserModel user,
  }) {
    try {
      final location = reminderTime is tz.TZDateTime
          ? (reminderTime).location
          : tz.getLocation(user.timezone);

      // Convert to TZDateTime if needed
      tz.TZDateTime tzReminderTime;
      if (reminderTime is tz.TZDateTime) {
        tzReminderTime = reminderTime;
      } else {
        tzReminderTime = tz.TZDateTime.from(reminderTime, location);
      }

      // Parse wake and sleep times
      final wakeParts = user.wakeTime.split(':');
      final sleepParts = user.sleepTime.split(':');
      
      if (wakeParts.length != 2 || sleepParts.length != 2) {
        Logger.warn('Invalid wake/sleep time format', tag: 'ReminderCalculation');
        return tzReminderTime; // Return as-is if can't parse
      }

      final wakeHour = int.tryParse(wakeParts[0]) ?? 7;
      final wakeMinute = int.tryParse(wakeParts[1]) ?? 0;
      final sleepHour = int.tryParse(sleepParts[0]) ?? 22;
      final sleepMinute = int.tryParse(sleepParts[1]) ?? 0;

      final reminderHour = tzReminderTime.hour;
      final reminderMinute = tzReminderTime.minute;

      // Check if reminder is within wake hours (7 AM - 11 PM by default)
      final reminderTimeOfDay = reminderHour * 60 + reminderMinute;
      final wakeTimeOfDay = wakeHour * 60 + wakeMinute;
      final sleepTimeOfDay = sleepHour * 60 + sleepMinute;

      // Handle case where sleep time is before midnight (e.g., 22:00)
      // and wake time is after midnight (e.g., 07:00)
      bool isWithinWindow;
      if (sleepTimeOfDay > wakeTimeOfDay) {
        // Normal case: wake < sleep (e.g., 07:00 to 22:00)
        isWithinWindow = reminderTimeOfDay >= wakeTimeOfDay && reminderTimeOfDay <= sleepTimeOfDay;
      } else {
        // Edge case: sleep < wake (e.g., 22:00 to 07:00) - spans midnight
        isWithinWindow = reminderTimeOfDay >= wakeTimeOfDay || reminderTimeOfDay <= sleepTimeOfDay;
      }

      if (!isWithinWindow) {
        Logger.info(
          'Reminder time $reminderTime outside wake window (${user.wakeTime} - ${user.sleepTime})',
          tag: 'ReminderCalculation',
        );
        
        // Adjust to nearest valid time (clamp to wake time)
        final wakeDateTime = tz.TZDateTime(
          location,
          tzReminderTime.year,
          tzReminderTime.month,
          tzReminderTime.day,
          wakeHour,
          wakeMinute,
        );
        
        return wakeDateTime.isBefore(tzReminderTime)
            ? wakeDateTime.add(const Duration(days: 1))
            : wakeDateTime;
      }

      return tzReminderTime;
    } catch (e) {
      Logger.error('Error validating wake/sleep window: $e', tag: 'ReminderCalculation');
      return reminderTime; // Return as-is on error
    }
  }

  /// Recalculate all reminders for a timezone change
  /// 
  /// This is called when timezone changes to recalculate all reminder times
  /// Returns map of reminderId -> new reminder times
  Future<Map<String, List<DateTime>>> recalculateRemindersForTimezone({
    required String oldTimezone,
    required String newTimezone,
    required List<ReminderModel> reminders,
    required UserModel user,
  }) async {
    final Map<String, List<DateTime>> recalculatedTimes = {};

    Logger.info(
      'Recalculating ${reminders.length} reminders for timezone change: $oldTimezone → $newTimezone',
      tag: 'ReminderCalculation',
    );

    for (final reminder in reminders) {
      if (!reminder.enabled || !reminder.isTimezoneAware) {
        continue; // Skip disabled or timezone-unaware reminders
      }

      final newTimes = calculateReminderTime(
        reminder: reminder,
        user: user.copyWith(timezone: newTimezone),
      );

      recalculatedTimes[reminder.id] = newTimes;
    }

    return recalculatedTimes;
  }
}
