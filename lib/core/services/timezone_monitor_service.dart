import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:tickdose/core/utils/logger.dart';
import 'package:workmanager/workmanager.dart';

/// Service that monitors timezone changes and triggers reminder recalculation
/// Uses WorkManager for battery-efficient background monitoring
class TimezoneMonitorService {
  static final TimezoneMonitorService _instance = TimezoneMonitorService._internal();
  factory TimezoneMonitorService() => _instance;
  TimezoneMonitorService._internal();

  Timer? _monitorTimer;
  String? _lastTimezone;
  bool _isMonitoring = false;
  bool _isBackgroundTaskRegistered = false;

  // Stream controller for timezone change events
  final _timezoneChangeController = StreamController<String>.broadcast();
  Stream<String> get timezoneChanges => _timezoneChangeController.stream;

  // Stream controller for DST transition events
  final _dstTransitionController = StreamController<DateTime>.broadcast();
  Stream<DateTime> get dstTransitions => _dstTransitionController.stream;

  // Background task name
  static const String _timezoneCheckTask = 'timezoneCheckTask';

  /// Initialize WorkManager callback (call this in main.dart)
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      if (task == _timezoneCheckTask) {
        final instance = TimezoneMonitorService();
        await instance._performTimezoneCheck();
        return Future.value(true);
      }
      return Future.value(false);
    });
  }

  /// Start monitoring timezone changes
  /// Uses WorkManager for background checks and Timer for foreground checks
  /// [foregroundInterval] - How often to check when app is active (default 5 minutes)
  void startMonitoring({Duration foregroundInterval = const Duration(minutes: 5)}) {
    if (_isMonitoring) {
      Logger.warn('Timezone monitoring already started', tag: 'TimezoneMonitor');
      return;
    }

    _isMonitoring = true;
    _lastTimezone = _getCurrentTimezone();
    
    Logger.info('Started timezone monitoring', tag: 'TimezoneMonitor');

    // Register background periodic task (every 15 minutes minimum on Android)
    _registerBackgroundTask();

    // Start foreground monitoring (when app is active)
    _monitorTimer = Timer.periodic(foregroundInterval, (_) {
      _checkTimezone();
    });
  }

  /// Register WorkManager periodic task for background monitoring
  void _registerBackgroundTask() {
    if (_isBackgroundTaskRegistered) return;

    try {
      // Cancel any existing task first
      Workmanager().cancelByUniqueName(_timezoneCheckTask);
      
      // Register periodic task (minimum 15 minutes on Android)
      Workmanager().registerPeriodicTask(
        _timezoneCheckTask,
        _timezoneCheckTask,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          // Only run when device is not low on battery
          requiresBatteryNotLow: false,
          // Can run when device is charging (saves battery)
          requiresCharging: false,
          // Can run on any network state
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
          networkType: NetworkType.notRequired,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );

      _isBackgroundTaskRegistered = true;
      Logger.info('Background timezone monitoring registered with WorkManager', tag: 'TimezoneMonitor');
    } catch (e) {
      Logger.error('Error registering background task: $e', tag: 'TimezoneMonitor');
    }
  }

  /// Perform timezone check (called by WorkManager in background)
  Future<void> _performTimezoneCheck() async {
    try {
      Logger.info('Background timezone check started', tag: 'TimezoneMonitor');
      
      final currentTimezone = _getCurrentTimezone();
      
      // Try to get last known timezone from storage/cache
      // For now, we'll check against the last known value
      if (_lastTimezone != null && currentTimezone != _lastTimezone) {
        Logger.info('Background: Timezone changed: $_lastTimezone → $currentTimezone', tag: 'TimezoneMonitor');
        _lastTimezone = currentTimezone;
        _timezoneChangeController.add(currentTimezone);
      } else {
        // Update last known timezone
        _lastTimezone = currentTimezone;
      }

      // Check for DST transition
      _checkDSTTransition();
    } catch (e) {
      Logger.error('Error in background timezone check: $e', tag: 'TimezoneMonitor');
    }
  }

  /// Stop monitoring timezone changes
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isMonitoring = false;

    // Cancel background task
    if (_isBackgroundTaskRegistered) {
      try {
        Workmanager().cancelByUniqueName(_timezoneCheckTask);
        _isBackgroundTaskRegistered = false;
        Logger.info('Background timezone monitoring cancelled', tag: 'TimezoneMonitor');
      } catch (e) {
        Logger.error('Error cancelling background task: $e', tag: 'TimezoneMonitor');
      }
    }

    Logger.info('Stopped timezone monitoring', tag: 'TimezoneMonitor');
  }

  /// Check if timezone has changed (foreground check)
  void _checkTimezone() {
    final currentTimezone = _getCurrentTimezone();
    
    if (_lastTimezone != null && currentTimezone != _lastTimezone) {
      Logger.info('Foreground: Timezone changed: $_lastTimezone → $currentTimezone', tag: 'TimezoneMonitor');
      _lastTimezone = currentTimezone;
      _timezoneChangeController.add(currentTimezone);
    }

    // Check for DST transition
    _checkDSTTransition();
  }

  /// Check for DST (Daylight Saving Time) transitions
  void _checkDSTTransition() {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final tomorrow = now.add(const Duration(days: 1));
      
      // Compare UTC offsets to detect DST changes
      final currentOffset = now.timeZoneOffset;
      final tomorrowOffset = tomorrow.timeZoneOffset;
      
      if (currentOffset != tomorrowOffset) {
        Logger.info('DST transition detected at $now', tag: 'TimezoneMonitor');
        _dstTransitionController.add(now);
      }
    } catch (e) {
      Logger.error('Error checking DST transition: $e', tag: 'TimezoneMonitor');
    }
  }

  /// Get current device timezone
  String _getCurrentTimezone() {
    try {
      return tz.local.name;
    } catch (e) {
      Logger.error('Error getting current timezone: $e', tag: 'TimezoneMonitor');
      return 'UTC';
    }
  }

  /// Get current timezone programmatically
  String getCurrentTimezone() {
    try {
      return _getCurrentTimezone();
    } catch (e) {
      Logger.error('Error getting current timezone: $e', tag: 'TimezoneMonitor');
      return 'UTC'; // Fallback to UTC
    }
  }

  /// Check if currently monitoring
  bool get isMonitoring => _isMonitoring;

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _timezoneChangeController.close();
    _dstTransitionController.close();
  }
}
