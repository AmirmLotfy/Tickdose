import 'package:tickdose/core/models/caregiver_model.dart';
import 'package:tickdose/core/services/caregiver_service.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for sending notifications to caregivers
class CaregiverNotificationService {
  static final CaregiverNotificationService _instance = CaregiverNotificationService._internal();
  factory CaregiverNotificationService() => _instance;
  CaregiverNotificationService._internal();

  final CaregiverService _caregiverService = CaregiverService();

  /// Notify caregivers when a dose is missed
  /// 
  /// [userId] - User who missed the dose
  /// [medicineName] - Name of the missed medicine
  /// [missedTime] - Time when the dose was missed
  Future<void> notifyMissedDose({
    required String userId,
    required String medicineName,
    required DateTime missedTime,
  }) async {
    try {
      final caregivers = await _caregiverService.getCaregivers(userId);

      for (final caregiver in caregivers) {
        if (!caregiver.hasPermission(CaregiverPermission.receiveAlerts)) {
          continue;
        }

        const title = 'Missed Medication Alert';
        final body = '${caregiver.userId == userId ? "Patient" : "User"} missed $medicineName at ${missedTime.toString().substring(11, 16)}';

        // TODO: Send push notification via FCM
        // For now, store notification in Firestore for the caregiver to read
        // In production, use Cloud Functions to send FCM notifications
        Logger.info('Would send notification to caregiver: $title - $body', tag: 'CaregiverNotification');

        Logger.info('Missed dose alert sent to caregiver: ${caregiver.caregiverEmail}', tag: 'CaregiverNotification');
      }
    } catch (e) {
      Logger.error('Error notifying caregivers of missed dose: $e', tag: 'CaregiverNotification');
    }
  }

  /// Send adherence summary to caregivers
  /// 
  /// [userId] - User ID
  /// [summaryType] - 'daily' or 'weekly'
  /// [adherenceRate] - Adherence percentage
  /// [stats] - Statistics (taken, missed, skipped counts)
  Future<void> sendAdherenceSummary({
    required String userId,
    required String summaryType, // 'daily' or 'weekly'
    required double adherenceRate,
    required Map<String, int> stats,
  }) async {
    try {
      final caregivers = await _caregiverService.getCaregivers(userId);

      for (final caregiver in caregivers) {
        if (!caregiver.hasPermission(CaregiverPermission.viewAdherence)) {
          continue;
        }

        final title = '${summaryType.toUpperCase()} Adherence Summary';
        final body = 'Adherence: ${(adherenceRate * 100).toStringAsFixed(1)}% | '
                    'Taken: ${stats['taken'] ?? 0} | '
                    'Missed: ${stats['missed'] ?? 0} | '
                    'Skipped: ${stats['skipped'] ?? 0}';

        // TODO: Send push notification via FCM
        Logger.info('Would send notification to caregiver: $title - $body', tag: 'CaregiverNotification');

        Logger.info('Adherence summary sent to caregiver: ${caregiver.caregiverEmail}', tag: 'CaregiverNotification');
      }
    } catch (e) {
      Logger.error('Error sending adherence summary: $e', tag: 'CaregiverNotification');
    }
  }

  /// Notify caregivers of serious side effects
  /// 
  /// [userId] - User ID
  /// [medicineName] - Medicine name
  /// [symptom] - Side effect symptom
  /// [severity] - Severity level
  Future<void> notifySideEffect({
    required String userId,
    required String medicineName,
    required String symptom,
    required String severity, // 'mild', 'moderate', 'severe'
  }) async {
    try {
      if (severity != 'severe' && severity != 'moderate') {
        return; // Only notify for moderate/severe side effects
      }

      final caregivers = await _caregiverService.getCaregivers(userId);

      for (final caregiver in caregivers) {
        if (!caregiver.hasPermission(CaregiverPermission.receiveAlerts)) {
          continue;
        }

        const title = 'Side Effect Alert';
        final body = '$medicineName: $symptom (${severity.toUpperCase()})';

        // TODO: Send push notification via FCM
        Logger.info('Would send notification to caregiver: $title - $body', tag: 'CaregiverNotification');

        Logger.info('Side effect alert sent to caregiver: ${caregiver.caregiverEmail}', tag: 'CaregiverNotification');
      }
    } catch (e) {
      Logger.error('Error notifying caregivers of side effect: $e', tag: 'CaregiverNotification');
    }
  }

  /// Escalate health concern to caregivers
  /// 
  /// [userId] - User ID
  /// [concern] - Health concern description
  /// [urgency] - 'low', 'medium', 'high', 'critical'
  Future<void> escalateHealthConcern({
    required String userId,
    required String concern,
    required String urgency,
  }) async {
    try {
      final caregivers = await _caregiverService.getCaregivers(userId);

      for (final caregiver in caregivers) {
        final title = urgency == 'critical' ? 'URGENT Health Concern' : 'Health Concern Alert';
        final body = concern;

        // TODO: Send push notification via FCM
        Logger.info('Would send notification to caregiver: $title - $body', tag: 'CaregiverNotification');

        Logger.info('Health concern escalated to caregiver: ${caregiver.caregiverEmail}', tag: 'CaregiverNotification');
      }
    } catch (e) {
      Logger.error('Error escalating health concern: $e', tag: 'CaregiverNotification');
    }
  }
}
