import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tickdose/core/models/reminder_model.dart';
import 'package:tickdose/core/services/notification_service.dart';
import 'package:tickdose/core/services/reminder_calculation_service.dart';
import 'package:tickdose/core/services/timezone_monitor_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/features/reminders/services/reminder_service.dart';
import 'package:tickdose/features/profile/providers/profile_provider.dart';
import 'package:tickdose/core/services/voice_reminder_service.dart';
import 'package:tickdose/core/services/elevenlabs_service.dart';
import 'package:tickdose/core/providers/voice_settings_provider.dart';
import 'package:tickdose/core/services/analytics_service.dart';
import 'package:tickdose/core/services/wearable_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:tickdose/core/utils/translation_helper.dart';
import 'package:tickdose/features/profile/providers/settings_provider.dart';



final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});

final remindersStreamProvider = StreamProvider<List<ReminderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final service = ref.watch(reminderServiceProvider);
  return service.watchReminders(user.uid);
});

/// Provider for today's reminders - filters reminders that are scheduled for today
final todaysRemindersProvider = StreamProvider<List<ReminderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final service = ref.watch(reminderServiceProvider);
  final now = DateTime.now();
  // final today = DateTime(now.year, now.month, now.day); // Unused
  final todayDayOfWeek = now.weekday - 1; // Convert to 0-6 (Monday = 0)
  
  return service.watchReminders(user.uid).map((reminders) {
    return reminders.where((reminder) {
      // Only show enabled reminders
      if (!reminder.enabled) return false;
      
      // Check if reminder is scheduled for today (check daysOfWeek)
      if (reminder.daysOfWeek.isEmpty || reminder.daysOfWeek.contains(todayDayOfWeek)) {
        return true;
      }
      return false;
    }).toList();
  });
});

final reminderControllerProvider = AsyncNotifierProvider<ReminderController, void>(ReminderController.new);

class ReminderController extends AsyncNotifier<void> {
  StreamSubscription<String>? _timezoneChangeSubscription;

  ReminderService get _service => ref.read(reminderServiceProvider);
  NotificationService get _notificationService => ref.read(notificationServiceProvider);

  @override
  FutureOr<void> build() {
    _listenToTimezoneChanges();
    
    ref.onDispose(() {
      _timezoneChangeSubscription?.cancel();
    });
    


    // Listen to language changes to reschedule notifications with correct localization
    ref.listen<String>(settingsProvider.select((s) => s.language), (previous, next) async {
      if (previous != next) {
        Logger.info('Language change detected ($previous -> $next), rescheduling notifications...', tag: 'Reminders');
        await _handleLanguageChange(next);
      }
    });

    return null;
  }

  Future<void> _handleLanguageChange(String newLanguage) async {
    try {
      // Get all reminders
      final remindersAsync = ref.read(remindersStreamProvider);
      final reminders = remindersAsync.value ?? [];

      // Reschedule all enabled reminders
      for (final reminder in reminders) {
        if (reminder.enabled) {
          await _scheduleLocalNotification(reminder);
        }
      }
      Logger.info('All reminders rescheduled for language: $newLanguage', tag: 'Reminders');
    } catch (e) {
      Logger.error('Error handling language change: $e', tag: 'Reminders');
    }
  }

  void _listenToTimezoneChanges() {
    final timezoneMonitor = TimezoneMonitorService();
    _timezoneChangeSubscription = timezoneMonitor.timezoneChanges.listen((newTimezone) async {
      Logger.info('Timezone changed detected, recalculating reminders...', tag: 'Reminders');
      await _handleTimezoneChange(newTimezone);
    });
  }

  Future<void> _handleTimezoneChange(String newTimezone) async {
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      final userAsync = ref.read(userProfileProvider);
      final currentUser = userAsync.value;
      if (currentUser == null) return;

      // Get old timezone
      final oldTimezone = currentUser.timezone;

      // Update user's timezone
      await ref.read(profileControllerProvider.notifier).updateProfile(
        currentUser.copyWith(timezone: newTimezone),
      );

      // Track analytics
      AnalyticsService().trackTimezoneChange(
        oldTimezone: oldTimezone,
        newTimezone: newTimezone,
        autoDetected: currentUser.timezoneAutoDetect,
      );

      // Get all reminders
      final remindersAsync = ref.read(remindersStreamProvider);
      final reminders = remindersAsync.value ?? [];

      // Recalculate all reminders
      final calculationService = ReminderCalculationService();
      final recalculatedTimes = await calculationService.recalculateRemindersForTimezone(
        oldTimezone: oldTimezone,
        newTimezone: newTimezone,
        reminders: reminders,
        user: currentUser.copyWith(timezone: newTimezone),
      );

      // Cancel old notifications and schedule new ones
      for (final reminder in reminders) {
        if (!reminder.enabled || !reminder.isTimezoneAware) continue;

        await _cancelAllNotificationsForReminder(reminder);

        if (recalculatedTimes.containsKey(reminder.id)) {
          final newTimes = recalculatedTimes[reminder.id]!;
          // final updatedUser = currentUser.copyWith(timezone: newTimezone); // Unused

          for (int i = 0; i < newTimes.length; i++) {
            final reminderTime = newTimes[i];
            final notificationId = reminder.notificationId + i;

            final tzReminderTime = reminderTime is tz.TZDateTime
                ? reminderTime
                : tz.TZDateTime.from(reminderTime, tz.getLocation(newTimezone));

            final l10n = await TranslationHelper.forLanguage(currentUser.language);

            await _notificationService.scheduleNotificationWithTimezone(
              id: notificationId,
              title: l10n.reminderTitle,
              body: l10n.reminderBody(reminder.dosage, reminder.medicineName),
              scheduledDate: tzReminderTime,
              payload: '${reminder.medicineId}|${reminder.id}',
              yesLabel: l10n.yesAction,
              noLabel: l10n.noAction,
            );
          }
        }
      }

      Logger.info('Reminders recalculated for timezone change: $oldTimezone → $newTimezone', tag: 'Reminders');
      
      final l10n = await TranslationHelper.forLanguage(currentUser.language);
      await _notificationService.showNotification(
        id: 88888, // Unique ID for timezone alert
        title: l10n.timezoneUpdatedTitle,
        body: l10n.timezoneUpdatedBody(newTimezone),
      );
    } catch (e) {
      Logger.error('Error handling timezone change: $e', tag: 'Reminders');
    }
  }

  Future<void> addReminder(ReminderModel reminder) async {
    state = const AsyncValue.loading();
    try {
      // 1. Get current user
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');
      
      // 2. Add to Firestore
      await _service.addReminder(user.uid, reminder);
      
      // 3. Schedule Local Notification if enabled
      if (reminder.enabled) {
        await _scheduleLocalNotification(reminder);
      }
      
      // 4. Pre-generate voice reminders (in background, don't wait)
      _preGenerateVoiceReminders(reminder);
      
      // 5. Send reminder to wearable if available
      _sendToWearable(reminder);
      
      // 6. Track analytics
      AnalyticsService().trackReminderAction(
        action: 'created',
        frequency: reminder.frequency.name,
        isMealBased: reminder.frequency == ReminderFrequency.withMeals,
        isTimezoneAware: reminder.isTimezoneAware,
      );
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    state = const AsyncValue.loading();
    try {
      // 1. Get current user
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('User not authenticated');
      
      // 2. Update in Firestore
      await _service.updateReminder(user.uid, reminder);
      
      // 3. Update Local Notification
      if (reminder.enabled) {
        await _scheduleLocalNotification(reminder);
      } else {
        await _cancelAllNotificationsForReminder(reminder);
      }
      
      // 4. Pre-generate voice reminders (in background, don't wait)
      if (reminder.enabled) {
        _preGenerateVoiceReminders(reminder);
      }
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteReminder(String reminderId, ReminderModel reminder) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();
    try {
      // 1. Delete from Firestore
      await _service.deleteReminder(user.uid, reminderId);
      
      // 2. Cancel ALL notifications for this reminder (all times)
      await _cancelAllNotificationsForReminder(reminder);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  
  Future<void> _scheduleLocalNotification(ReminderModel reminder) async {
    // Cancel any existing notifications for this reminder first
    await _cancelAllNotificationsForReminder(reminder);
    
    // Get user profile for timezone and routine info
    final userAsync = ref.read(userProfileProvider);
    final user = userAsync.value;
    
    if (user == null) {
      Logger.warn('Cannot schedule notification: user not found', tag: 'Reminders');
      return;
    }

    // COST-OPTIMIZED: Don't pre-generate audio files at reminder creation
    // Instead, generate on-demand when notification fires (lazy loading)
    // This saves API costs - audio is only generated when actually needed
    // 
    // The notification will be scheduled without audio path initially.
    // When the notification fires, NotificationActionService will:
    // 1. Check if audio file exists (cached from previous use)
    // 2. Generate on-demand if needed
    // 3. Play and cache for future reuse
    // 
    // This way:
    // - First notification: Generates audio (1 API call per unique reminder)
    // - Subsequent notifications: Reuses cached audio (0 API calls)
    // - Much more cost-effective than generating all reminders upfront
    
    String? customAudioFilePath; // Will be null initially - generated on-demand

    // Use ReminderCalculationService to get timezone-aware times
    final calculationService = ReminderCalculationService();
    final reminderTimes = calculationService.calculateReminderTime(
      reminder: reminder,
      user: user,
    );

    if (reminderTimes.isEmpty) {
      Logger.warn('No reminder times calculated for ${reminder.medicineName}', tag: 'Reminders');
      return;
    }

    // Schedule notification for each calculated time
    for (int i = 0; i < reminderTimes.length; i++) {
      final reminderTime = reminderTimes[i];
      
      // Calculate unique notification ID (base + index)
      final notificationId = reminder.notificationId + i;
      
      // Convert DateTime to tz.TZDateTime if needed
      final tzReminderTime = reminderTime is tz.TZDateTime 
          ? reminderTime 
          : tz.TZDateTime.from(reminderTime, tz.getLocation(user.timezone));
      
      // Retrieve localized strings
      final l10n = await TranslationHelper.forLanguage(user.language);

      // Schedule DAILY repeating notification at this specific time
      // Pass custom audio file path if available (will be included in payload for playback)
      await _notificationService.scheduleNotificationWithTimezone(
        id: notificationId,
        title: l10n.reminderTitle,
        body: l10n.reminderBody(reminder.dosage, reminder.medicineName),
        scheduledDate: tzReminderTime,
        payload: '${reminder.medicineId}|${reminder.id}',
        customAudioFilePath: customAudioFilePath, // Pass audio file path for playback when notification fires
        largeIconPath: await _getLocalImagePath(reminder.imageUrl), // Pass image for notification
        yesLabel: l10n.yesAction,
        noLabel: l10n.noAction,
      );
      
      Logger.info(
        'Scheduled timezone-aware notification $notificationId for ${reminder.medicineName} at $tzReminderTime${""}',
        tag: 'Reminders',
      );
    }
  }
  
  Future<void> _cancelAllNotificationsForReminder(ReminderModel reminder) async {
    // Cancel notifications for all times (using the index pattern)
    for (int i = 0; i < reminder.times.length; i++) {
      await _notificationService.cancelNotification(reminder.notificationId + i);
    }
    Logger.info('Cancelled all notifications for ${reminder.medicineName}', tag: 'Reminders');
  }

  /// Pre-generate voice reminders for offline use
  /// This runs in the background and doesn't block the main flow
  void _preGenerateVoiceReminders(ReminderModel reminder) {
    // Run async without awaiting (fire and forget)
    Future.microtask(() async {
      try {
        final userAsync = ref.read(userProfileProvider);
        final user = userAsync.value;
        if (user == null) return;

        final voiceSettings = ref.read(voiceSettingsProvider);
        if (!voiceSettings.useVoiceReminders) return;

        // final voiceService = VoiceReminderService(); // Unused
        final elevenLabsService = ElevenLabsService();
        final l10n = await TranslationHelper.forLanguage(user.language);

        
        // Generate reminder messages for each reminder time
        final reminderTexts = <String>[];
        
        for (final timeStr in reminder.times) {
          final timeParts = timeStr.split(':');
          if (timeParts.length == 2) {
            final hour = int.tryParse(timeParts[0]);
            final minute = int.tryParse(timeParts[1]);
            
            if (hour != null && minute != null) {
              final timeOfDay = TimeOfDay(hour: hour, minute: minute);
              
              // Determine reminder type
              VoiceReminderType reminderType = VoiceReminderType.standard;
              String? mealTime;
              
              if (reminder.frequency == ReminderFrequency.withMeals && reminder.mealTimes != null) {
                reminderType = VoiceReminderType.mealAware;
                // Find which meal this time corresponds to
                for (final entry in reminder.mealTimes!.entries) {
                  if (entry.value == timeStr) {
                    mealTime = entry.key;
                    break;
                  }
                }
              }

              // Generate message text
              String message;
              if (reminderType == VoiceReminderType.mealAware) {
                final greeting = _getGreeting(timeOfDay, l10n);
                
                // Localize meal name
                String localizedMealTime = mealTime ?? 'meal';
                if (mealTime != null) {
                   switch (mealTime.toLowerCase()) {
                     case 'breakfast': localizedMealTime = l10n.mealBreakfast; break;
                     case 'lunch': localizedMealTime = l10n.mealLunch; break;
                     case 'dinner': localizedMealTime = l10n.mealDinner; break;
                     case 'snack': localizedMealTime = l10n.mealSnack; break;
                   }
                }

                message = '$greeting ${l10n.voiceReminderMeal(localizedMealTime, reminder.dosage, reminder.medicineName)}';
              } else {
                final greeting = _getGreeting(timeOfDay, l10n);
                message = '$greeting ${l10n.voiceReminderStandard(reminder.dosage, reminder.medicineName)}';
              }
              
              reminderTexts.add(message);
            }
          }
        }

        // Generate voices in batch
        if (reminderTexts.isNotEmpty && voiceSettings.selectedVoiceId.isNotEmpty) {
          await elevenLabsService.generateReminderVoices(
            reminders: reminderTexts,
            voiceId: voiceSettings.selectedVoiceId,
          );
          
          Logger.info('Pre-generated ${reminderTexts.length} voice reminders for ${reminder.medicineName}', tag: 'Reminders');
        }
      } catch (e) {
        Logger.error('Error pre-generating voice reminders: $e', tag: 'Reminders');
        // Don't throw - this is background operation
      }
    });
  }

  String _getGreeting(TimeOfDay timeOfDay, dynamic l10n) {
    final hour = timeOfDay.hour;
    
    if (hour >= 5 && hour < 12) {
      return l10n.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      return l10n.goodAfternoon;
    } else if (hour >= 17 && hour < 21) {
      return l10n.goodEvening;
    } else {
      return l10n.hello;
    }
  }

  /// Send reminder to wearable device
  void _sendToWearable(ReminderModel reminder) {
    Future.microtask(() async {
      try {
        final wearableService = WearableService();
        final isInitialized = await wearableService.initialize();
        
        if (!isInitialized) return;

        // Send reminder for each scheduled time
        for (int i = 0; i < reminder.times.length; i++) {
          final timeStr = reminder.times[i];
          final timeParts = timeStr.split(':');
          if (timeParts.length == 2) {
            final hour = int.tryParse(timeParts[0]);
            final minute = int.tryParse(timeParts[1]);
            
            if (hour != null && minute != null) {
              final now = DateTime.now();
              var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
              
              // If time has passed today, schedule for tomorrow
              if (scheduledTime.isBefore(now)) {
                scheduledTime = scheduledTime.add(const Duration(days: 1));
              }

              await wearableService.sendReminderToWearable(
                reminderId: '${reminder.id}_$i',
                medicineName: reminder.medicineName,
                dosage: reminder.dosage,
                scheduledTime: scheduledTime,
                mealTime: reminder.frequency == ReminderFrequency.withMeals 
                    ? (reminder.mealTimes?.keys.length ?? 0) > i
                        ? reminder.mealTimes!.keys.elementAt(i)
                        : null
                    : null,
              );
            }
          }
        }
      } catch (e) {
        Logger.error('Error sending reminder to wearable: $e', tag: 'Reminders');
        // Don't throw - wearable is optional
      }
    });
  }
  /// Get local path for image (download if URL, return path if local file)
  Future<String?> _getLocalImagePath(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return null;

    try {
      // If it's a remote URL
      if (imageUrl.startsWith('http')) {
        final directory = await getTemporaryDirectory();
        final fileName = path.basename(imageUrl).split('?')[0]; // simple sanitization
        final localFile = File('${directory.path}/$fileName');

        // Check if we already have it cached
        if (await localFile.exists()) {
          return localFile.path;
        }

        // Download
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          await localFile.writeAsBytes(response.bodyBytes);
          return localFile.path;
        }
      } 
      // If it's a local file path
      else {
        final file = File(imageUrl);
        if (await file.exists()) {
          return imageUrl;
        }
      }
    } catch (e) {
      Logger.error('Error resolving image path: $e', tag: 'Reminders');
    }
    return null;
  }
}
