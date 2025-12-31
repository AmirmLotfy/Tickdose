import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:tickdose/core/utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS: Register notification categories with action buttons
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'MEDICINE_REMINDER',
          actions: [
            DarwinNotificationAction.plain(
              'yes_action',
              'Yes',
              options: {
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              'no_action',
              'No',
              options: {
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
        ),
      ],
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _onNotificationTapped(response);
        // Call external callback if set
        onNotificationTapCallback?.call(response);
      },
    );

    _initialized = true;
    Logger.info('NotificationService initialized with iOS action buttons', tag: 'Notifications');
  }

  Future<void> requestPermissions() async {
    // iOS permissions
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+ permissions
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    Logger.info('Notification permissions requested', tag: 'Notifications');
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Reminders to take your medicine on time',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
    Logger.info('Notification shown: $title', tag: 'Notifications');
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    List<int>? daysOfWeek,
    String? payload,
    String? timezone,
    String? customAudioFilePath, // ElevenLabs generated audio file path
    String yesLabel = 'Yes',
    String noLabel = 'No',
  }) async {
    // Use specified timezone or default to local
    final location = timezone != null ? tz.getLocation(timezone) : tz.local;
    final now = tz.TZDateTime.now(location);
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Reminders to take your medicine on time',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true, // Use default notification sound
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'reminder_alert.mp3', // Asset sound
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Include custom audio path in payload if provided
    final finalPayload = customAudioFilePath != null 
        ? '${payload ?? ""}|audio:$customAudioFilePath'
        : payload;

    // Schedule daily repeating notification
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at same time
      payload: finalPayload,
    );

    Logger.info('Daily notification scheduled for $hour:${minute.toString().padLeft(2, '0')}', tag: 'Notifications');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String? timezone,
    String? customAudioFilePath, // ElevenLabs generated audio file path
    String yesLabel = 'Yes',
    String noLabel = 'No',
  }) async {
    // Use specified timezone or default to local
    final location = timezone != null ? tz.getLocation(timezone) : tz.local;
    final tzScheduledDate = scheduledDate is tz.TZDateTime
        ? scheduledDate
        : tz.TZDateTime.from(scheduledDate, location);

    // Use default notification sound (playSound: true)
    // Custom audio files (ElevenLabs generated) will be played via AudioPlayer when notification fires
    // Asset sounds (reminder_alert.mp3) can be played separately via AudioService
    final androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Reminders to take your medicine on time',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true, // Use default notification sound
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'yes_action',
          yesLabel,
          titleColor: const Color(0xFF10B981), // green
        ),
        AndroidNotificationAction(
          'no_action',
          noLabel,
          titleColor: const Color(0xFFEF4444), // red
        ),
      ],
    );

    // iOS: Use default notification sound
    // Custom runtime audio will be played via AudioPlayer when notification fires
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true, // Use default notification sound
      categoryIdentifier: 'MEDICINE_REMINDER',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Include custom audio path in payload if provided
    final finalPayload = customAudioFilePath != null 
        ? '${payload ?? ""}|audio:$customAudioFilePath'
        : payload;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: finalPayload,
    );

    Logger.info('Notification scheduled for $scheduledDate in timezone ${location.name}${customAudioFilePath != null ? " with custom audio" : " with asset sound"}', tag: 'Notifications');
  }

  /// Schedule notification using timezone-aware DateTime
  Future<void> scheduleNotificationWithTimezone({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    String? customAudioFilePath, // ElevenLabs generated audio file path
    String? largeIconPath, // Path to local image file
    String yesLabel = 'Yes',
    String noLabel = 'No',
  }) async {
    StyleInformation? styleInformation;
    if (largeIconPath != null) {
      styleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(largeIconPath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        contentTitle: title,
        summaryText: body,
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true,
      );
    }

    final androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Reminders to take your medicine on time',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      styleInformation: styleInformation,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'yes_action',
          yesLabel,
          titleColor: const Color(0xFF10B981), // green
        ),
        AndroidNotificationAction(
          'no_action',
          noLabel,
          titleColor: const Color(0xFFEF4444), // red
        ),
      ],
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'MEDICINE_REMINDER',
      attachments: largeIconPath != null 
          ? [DarwinNotificationAttachment(largeIconPath)] 
          : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Include custom audio path in payload if provided
    final finalPayload = customAudioFilePath != null 
        ? '${payload ?? ""}|audio:$customAudioFilePath'
        : payload;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: finalPayload,
    );

    Logger.info('Timezone-aware notification scheduled for $scheduledDate${customAudioFilePath != null ? " with custom audio" : " with asset sound"}${largeIconPath != null ? " and image" : ""}', tag: 'Notifications');
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    Logger.info('Notification $id cancelled', tag: 'Notifications');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    Logger.info('All notifications cancelled', tag: 'Notifications');
  }

  void _onNotificationTapped(NotificationResponse response) {
    Logger.info('Notification tapped: ${response.payload}, actionId: ${response.actionId}', tag: 'Notifications');
    
    // Call the callback if set
    if (onNotificationTapCallback != null) {
      onNotificationTapCallback!(response);
    }
  }

  /// Set callback for notification tap handling (for voice reminder integration)
  Function(NotificationResponse)? onNotificationTapCallback;

  /// Initialize with notification tap callback
  Future<void> initializeWithCallback(Function(NotificationResponse) callback) async {
    await initialize();
    onNotificationTapCallback = callback;
  }
}
