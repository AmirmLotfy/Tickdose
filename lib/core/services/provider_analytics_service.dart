import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';
import 'package:tickdose/core/models/side_effect_log_model.dart';

/// Service for generating analytics and insights for healthcare providers
/// Provides trend analysis, correlations, and effectiveness tracking
class ProviderAnalyticsService {
  static final ProviderAnalyticsService _instance = ProviderAnalyticsService._internal();
  factory ProviderAnalyticsService() => _instance;
  ProviderAnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get comprehensive analytics for a patient
  Future<PatientAnalytics> getPatientAnalytics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Fetch all relevant data
      final logs = await _fetchMedicineLogs(userId, startDate, endDate);
      final sideEffects = await _fetchSideEffects(userId, startDate, endDate);
      final reminders = await _fetchReminders(userId);

      // Calculate metrics
      final adherenceRate = _calculateAdherenceRate(logs, reminders, startDate, endDate);
      final sideEffectCorrelations = _analyzeSideEffectCorrelations(logs, sideEffects);
      final effectivenessMetrics = _calculateEffectivenessMetrics(logs, sideEffects);
      final trends = _calculateTrends(logs, startDate, endDate);
      final timeOfDayAnalysis = _analyzeTimeOfDayPatterns(logs);

      return PatientAnalytics(
        userId: userId,
        period: DateTimeRange(start: startDate, end: endDate),
        adherenceRate: adherenceRate,
        totalDoses: logs.length,
        takenDoses: logs.where((l) => l.status == 'taken').length,
        skippedDoses: logs.where((l) => l.status == 'skipped').length,
        sideEffectCorrelations: sideEffectCorrelations,
        effectivenessMetrics: effectivenessMetrics,
        trends: trends,
        timeOfDayPatterns: timeOfDayAnalysis,
      );
    } catch (e) {
      Logger.error('Error generating patient analytics: $e', tag: 'ProviderAnalytics');
      rethrow;
    }
  }

  /// Calculate adherence rate percentage
  double _calculateAdherenceRate(
    List<MedicineLogModel> logs,
    List<Map<String, dynamic>> reminders,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (reminders.isEmpty) return 0.0;

    // Calculate expected doses based on reminders
    int expectedDoses = 0;
    final daysBetween = endDate.difference(startDate).inDays;

    for (final reminder in reminders) {
      final frequency = reminder['frequency'] ?? 'daily';
      int dosesPerDay = 1;
      
      switch (frequency) {
        case 'twiceDaily':
          dosesPerDay = 2;
          break;
        case 'threeTimes':
          dosesPerDay = 3;
          break;
        case 'fourTimes':
          dosesPerDay = 4;
          break;
        default:
          dosesPerDay = 1;
      }

      expectedDoses += dosesPerDay * daysBetween;
    }

    final takenDoses = logs.where((l) => l.status == 'taken').length;
    if (expectedDoses == 0) return 0.0;

    return (takenDoses / expectedDoses) * 100;
  }

  /// Analyze correlations between medication adherence and side effects
  Map<String, SideEffectCorrelation> _analyzeSideEffectCorrelations(
    List<MedicineLogModel> logs,
    List<SideEffectLog> sideEffects,
  ) {
    final correlations = <String, SideEffectCorrelation>{};

    for (final sideEffect in sideEffects) {
      final medicineId = sideEffect.medicineId;
      
      // Find related medication logs
      final relatedLogs = logs.where((l) => l.medicineId == medicineId).toList();
      
      if (relatedLogs.isEmpty) continue;

      // Calculate adherence rate for this medicine
      final takenCount = relatedLogs.where((l) => l.status == 'taken').length;
      final adherenceRate = relatedLogs.isNotEmpty 
          ? (takenCount / relatedLogs.length) * 100 
          : 0.0;

      // Check if side effect occurred on non-adherent days
      final sideEffectDate = sideEffect.occurredAt;
      final missedDosesBeforeSideEffect = relatedLogs.where((log) {
        final daysDiff = sideEffectDate.difference(log.takenAt).inDays;
        return log.status == 'skipped' && daysDiff >= 0 && daysDiff <= 7;
      }).length;

      correlations[medicineId] = SideEffectCorrelation(
        medicineId: medicineId,
        medicineName: sideEffect.medicineName,
        sideEffectType: sideEffect.symptom,
        adherenceRate: adherenceRate,
        sideEffectCount: sideEffects.where((se) => se.medicineId == medicineId).length,
        missedDosesBeforeSideEffect: missedDosesBeforeSideEffect,
        correlationStrength: _calculateCorrelationStrength(
          adherenceRate,
          missedDosesBeforeSideEffect,
        ),
      );
    }

    return correlations;
  }

  /// Calculate medication effectiveness metrics
  Map<String, EffectivenessMetric> _calculateEffectivenessMetrics(
    List<MedicineLogModel> logs,
    List<SideEffectLog> sideEffects,
  ) {
    final metrics = <String, EffectivenessMetric>{};
    final medicines = logs.map((l) => l.medicineId).toSet();

    for (final medicineId in medicines) {
      final medicineLogs = logs.where((l) => l.medicineId == medicineId).toList();
      final medicineSideEffects = sideEffects.where((se) => se.medicineId == medicineId).toList();

      if (medicineLogs.isEmpty) continue;

      final adherenceRate = (medicineLogs.where((l) => l.status == 'taken').length / 
                            medicineLogs.length) * 100;
      
      final sideEffectRate = medicineSideEffects.isNotEmpty
          ? (medicineSideEffects.length / medicineLogs.length) * 100
          : 0.0;

      // Effectiveness score (higher adherence + lower side effects = better)
      final effectivenessScore = adherenceRate - (sideEffectRate * 0.5);

      metrics[medicineId] = EffectivenessMetric(
        medicineId: medicineId,
        medicineName: medicineLogs.first.medicineName,
        adherenceRate: adherenceRate,
        sideEffectRate: sideEffectRate,
        effectivenessScore: effectivenessScore.clamp(0, 100),
        totalDoses: medicineLogs.length,
        sideEffectCount: medicineSideEffects.length,
      );
    }

    return metrics;
  }

  /// Calculate trends over time
  List<TrendDataPoint> _calculateTrends(
    List<MedicineLogModel> logs,
    DateTime startDate,
    DateTime endDate,
  ) {
    final trends = <TrendDataPoint>[];
    final days = endDate.difference(startDate).inDays;

    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      final dayLogs = logs.where((l) {
        return l.takenAt.year == date.year &&
               l.takenAt.month == date.month &&
               l.takenAt.day == date.day;
      }).toList();

      if (dayLogs.isEmpty) continue;

      final takenCount = dayLogs.where((l) => l.status == 'taken').length;
      final adherenceRate = (takenCount / dayLogs.length) * 100;

      trends.add(TrendDataPoint(
        date: date,
        adherenceRate: adherenceRate,
        totalDoses: dayLogs.length,
        takenDoses: takenCount,
      ));
    }

    return trends;
  }

  /// Analyze time-of-day patterns for medication taking
  Map<String, TimeOfDayPattern> _analyzeTimeOfDayPatterns(List<MedicineLogModel> logs) {
    final patterns = <String, Map<String, int>>{};

    for (final log in logs) {
      if (log.status != 'taken') continue;

      final hour = log.takenAt.hour;
      final timeSlot = _getTimeSlot(hour);

      patterns.putIfAbsent(log.medicineId, () => {});
      patterns[log.medicineId]![timeSlot] = 
          (patterns[log.medicineId]![timeSlot] ?? 0) + 1;
    }

    return patterns.map((medicineId, counts) {
      final total = counts.values.fold(0, (a, b) => a + b);
      final mostCommon = counts.entries.reduce((a, b) => a.value > b.value ? a : b);

      return MapEntry(medicineId, TimeOfDayPattern(
        medicineId: medicineId,
        mostCommonTime: mostCommon.key,
        distribution: counts.map((k, v) => MapEntry(k, (v / total) * 100)),
      ));
    });
  }

  String _getTimeSlot(int hour) {
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }

  String _calculateCorrelationStrength(double adherenceRate, int missedDoses) {
    if (missedDoses >= 3 && adherenceRate < 70) return 'High';
    if (missedDoses >= 2 && adherenceRate < 80) return 'Medium';
    if (missedDoses >= 1) return 'Low';
    return 'None';
  }

  Future<List<MedicineLogModel>> _fetchMedicineLogs(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('logs')
          .where('takenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('takenAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return query.docs.map((doc) {
        return MedicineLogModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      Logger.error('Error fetching medicine logs: $e', tag: 'ProviderAnalytics');
      return [];
    }
  }

  Future<List<SideEffectLog>> _fetchSideEffects(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('side_effects')
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return SideEffectLog(
          id: doc.id,
          userId: data['userId'] ?? '',
          medicineId: data['medicineId'] ?? '',
          medicineName: data['medicineName'] ?? '',
          symptom: data['symptom'] ?? data['effectName'] ?? '',
          severity: data['severity'] ?? 'mild',
          occurredAt: (data['occurredAt'] ?? data['dateTime'] as Timestamp).toDate(),
          notes: data['notes'] ?? '',
        );
      }).toList();
    } catch (e) {
      Logger.error('Error fetching side effects: $e', tag: 'ProviderAnalytics');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReminders(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .get();

      return query.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      Logger.error('Error fetching reminders: $e', tag: 'ProviderAnalytics');
      return [];
    }
  }

  /// Export analytics data for doctor visit
  Future<ExportData> exportForDoctorVisit({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final analytics = await getPatientAnalytics(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return ExportData(
      analytics: analytics,
      exportedAt: DateTime.now(),
      format: 'json', // Can be extended to PDF/CSV
    );
  }
}

/// Patient analytics model
class PatientAnalytics {
  final String userId;
  final DateTimeRange period;
  final double adherenceRate;
  final int totalDoses;
  final int takenDoses;
  final int skippedDoses;
  final Map<String, SideEffectCorrelation> sideEffectCorrelations;
  final Map<String, EffectivenessMetric> effectivenessMetrics;
  final List<TrendDataPoint> trends;
  final Map<String, TimeOfDayPattern> timeOfDayPatterns;

  PatientAnalytics({
    required this.userId,
    required this.period,
    required this.adherenceRate,
    required this.totalDoses,
    required this.takenDoses,
    required this.skippedDoses,
    required this.sideEffectCorrelations,
    required this.effectivenessMetrics,
    required this.trends,
    required this.timeOfDayPatterns,
  });
}

/// Side effect correlation model
class SideEffectCorrelation {
  final String medicineId;
  final String medicineName;
  final String sideEffectType;
  final double adherenceRate;
  final int sideEffectCount;
  final int missedDosesBeforeSideEffect;
  final String correlationStrength;

  SideEffectCorrelation({
    required this.medicineId,
    required this.medicineName,
    required this.sideEffectType,
    required this.adherenceRate,
    required this.sideEffectCount,
    required this.missedDosesBeforeSideEffect,
    required this.correlationStrength,
  });
}

/// Medication effectiveness metric
class EffectivenessMetric {
  final String medicineId;
  final String medicineName;
  final double adherenceRate;
  final double sideEffectRate;
  final double effectivenessScore;
  final int totalDoses;
  final int sideEffectCount;

  EffectivenessMetric({
    required this.medicineId,
    required this.medicineName,
    required this.adherenceRate,
    required this.sideEffectRate,
    required this.effectivenessScore,
    required this.totalDoses,
    required this.sideEffectCount,
  });
}

/// Trend data point
class TrendDataPoint {
  final DateTime date;
  final double adherenceRate;
  final int totalDoses;
  final int takenDoses;

  TrendDataPoint({
    required this.date,
    required this.adherenceRate,
    required this.totalDoses,
    required this.takenDoses,
  });
}

/// Time of day pattern
class TimeOfDayPattern {
  final String medicineId;
  final String mostCommonTime;
  final Map<String, double> distribution;

  TimeOfDayPattern({
    required this.medicineId,
    required this.mostCommonTime,
    required this.distribution,
  });
}

/// Export data model
class ExportData {
  final PatientAnalytics analytics;
  final DateTime exportedAt;
  final String format;

  ExportData({
    required this.analytics,
    required this.exportedAt,
    required this.format,
  });
}
