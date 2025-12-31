import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Analytics service for tracking user events
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _isEnabled = true;

  /// Enable or disable analytics
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  /// Track timezone change
  Future<void> trackTimezoneChange({
    required String oldTimezone,
    required String newTimezone,
    required bool autoDetected,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'timezone_changed',
        parameters: {
          'old_timezone': oldTimezone,
          'new_timezone': newTimezone,
          'auto_detected': autoDetected,
        },
      );
      Logger.info('Analytics: timezone_changed tracked', tag: 'Analytics');
    } catch (e) {
      Logger.error('Error tracking timezone change: $e', tag: 'Analytics');
    }
  }

  /// Track voice interaction
  Future<void> trackVoiceInteraction({
    required String interactionType, // 'reminder', 'confirmation', 'navigation'
    required bool success,
    String? errorMessage,
    String? language,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'voice_interaction',
        parameters: {
          'interaction_type': interactionType,
          'success': success,
          if (errorMessage != null) 'error': errorMessage,
          if (language != null) 'language': language,
        },
      );
      Logger.info('Analytics: voice_interaction tracked', tag: 'Analytics');
    } catch (e) {
      Logger.error('Error tracking voice interaction: $e', tag: 'Analytics');
    }
  }

  /// Track caregiver usage
  Future<void> trackCaregiverUsage({
    required String action, // 'added', 'removed', 'invited', 'accepted'
    String? caregiverId,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'caregiver_action',
        parameters: {
          'action': action,
          if (caregiverId != null) 'caregiver_id': caregiverId,
        },
      );
      Logger.info('Analytics: caregiver_action tracked', tag: 'Analytics');
    } catch (e) {
      Logger.error('Error tracking caregiver usage: $e', tag: 'Analytics');
    }
  }

  /// Track reminder creation/update
  Future<void> trackReminderAction({
    required String action, // 'created', 'updated', 'deleted'
    required String frequency,
    required bool isMealBased,
    required bool isTimezoneAware,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'reminder_action',
        parameters: {
          'action': action,
          'frequency': frequency,
          'is_meal_based': isMealBased,
          'is_timezone_aware': isTimezoneAware,
        },
      );
    } catch (e) {
      Logger.error('Error tracking reminder action: $e', tag: 'Analytics');
    }
  }

  /// Track medication adherence
  Future<void> trackAdherence({
    required bool taken,
    required String reminderId,
    String? method, // 'voice', 'manual', 'notification'
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: 'medication_adherence',
        parameters: {
          'taken': taken,
          'reminder_id': reminderId,
          if (method != null) 'method': method,
        },
      );
    } catch (e) {
      Logger.error('Error tracking adherence: $e', tag: 'Analytics');
    }
  }

  /// Track screen view
  Future<void> trackScreenView({required String screenName}) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      Logger.error('Error tracking screen view: $e', tag: 'Analytics');
    }
  }

  /// Track custom event
  Future<void> trackEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      Logger.error('Error tracking event: $e', tag: 'Analytics');
    }
  }
}
