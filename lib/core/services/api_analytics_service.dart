import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

/// API Analytics Service
/// Tracks API call success/failure rates, response times, and error patterns
class ApiAnalyticsService {
  static final ApiAnalyticsService _instance = ApiAnalyticsService._internal();
  factory ApiAnalyticsService() => _instance;
  ApiAnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Record an API call with metrics
  /// [apiType] - 'gemini' or 'elevenlabs'
  /// [success] - Whether the call was successful
  /// [responseTimeMs] - Response time in milliseconds
  /// [errorType] - Type of error if failed (optional)
  /// [model] - Model used (optional, for Gemini: 'flash' or 'pro')
  Future<void> recordApiCall({
    required String apiType,
    required bool success,
    int? responseTimeMs,
    String? errorType,
    String? model,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Record in daily analytics
      final dailyDocRef = _firestore
          .collection('api_analytics')
          .doc(user.uid)
          .collection('daily')
          .doc(today.toIso8601String().split('T')[0]);

      final updateData = <String, dynamic>{
        'userId': user.uid,
        'date': Timestamp.fromDate(today),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update counters
      updateData['$apiType.totalCalls'] = FieldValue.increment(1);
      if (success) {
        updateData['$apiType.successfulCalls'] = FieldValue.increment(1);
      } else {
        updateData['$apiType.failedCalls'] = FieldValue.increment(1);
        if (errorType != null) {
          updateData['$apiType.errors.$errorType'] = FieldValue.increment(1);
        }
      }

      // Update response time statistics
      if (responseTimeMs != null) {
        updateData['$apiType.totalResponseTime'] = FieldValue.increment(responseTimeMs);
        updateData['$apiType.responseTimeCount'] = FieldValue.increment(1);
        
        // Track min/max response times
        final currentDoc = await dailyDocRef.get();
        if (currentDoc.exists) {
          final data = currentDoc.data()!;
          final currentMin = data['$apiType.minResponseTime'] as int?;
          final currentMax = data['$apiType.maxResponseTime'] as int?;
          
          if (currentMin == null || responseTimeMs < currentMin) {
            updateData['$apiType.minResponseTime'] = responseTimeMs;
          }
          if (currentMax == null || responseTimeMs > currentMax) {
            updateData['$apiType.maxResponseTime'] = responseTimeMs;
          }
        } else {
          updateData['$apiType.minResponseTime'] = responseTimeMs;
          updateData['$apiType.maxResponseTime'] = responseTimeMs;
        }
      }

      // Track model usage (for Gemini)
      if (model != null && apiType == 'gemini') {
        updateData['$apiType.models.$model'] = FieldValue.increment(1);
      }

      await dailyDocRef.set(updateData, SetOptions(merge: true));

      // Clean up old analytics (older than 30 days)
      await _cleanupOldAnalytics(user.uid);
    } catch (e) {
      Logger.error('Failed to record API analytics: $e', tag: 'ApiAnalytics');
      // Don't throw - analytics shouldn't break the app
    }
  }

  /// Get analytics summary for a user
  Future<Map<String, dynamic>> getAnalyticsSummary({
    int days = 7,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'error': 'User not authenticated'};
      }

      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      
      final snapshot = await _firestore
          .collection('api_analytics')
          .doc(user.uid)
          .collection('daily')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      int geminiTotal = 0;
      int geminiSuccess = 0;
      int geminiFailed = 0;
      int geminiTotalTime = 0;
      int geminiTimeCount = 0;
      Map<String, int> geminiModels = {};
      Map<String, int> geminiErrors = {};

      int elevenlabsTotal = 0;
      int elevenlabsSuccess = 0;
      int elevenlabsFailed = 0;
      int elevenlabsTotalTime = 0;
      int elevenlabsTimeCount = 0;
      Map<String, int> elevenlabsErrors = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Gemini stats
        geminiTotal += (data['gemini.totalCalls'] as int?) ?? 0;
        geminiSuccess += (data['gemini.successfulCalls'] as int?) ?? 0;
        geminiFailed += (data['gemini.failedCalls'] as int?) ?? 0;
        geminiTotalTime += (data['gemini.totalResponseTime'] as int?) ?? 0;
        geminiTimeCount += (data['gemini.responseTimeCount'] as int?) ?? 0;
        
        final geminiModelsData = data['gemini.models'] as Map<String, dynamic>?;
        if (geminiModelsData != null) {
          geminiModelsData.forEach((model, count) {
            geminiModels[model] = (geminiModels[model] ?? 0) + (count as int? ?? 0);
          });
        }
        
        final geminiErrorsData = data['gemini.errors'] as Map<String, dynamic>?;
        if (geminiErrorsData != null) {
          geminiErrorsData.forEach((error, count) {
            geminiErrors[error] = (geminiErrors[error] ?? 0) + (count as int? ?? 0);
          });
        }

        // ElevenLabs stats
        elevenlabsTotal += (data['elevenlabs.totalCalls'] as int?) ?? 0;
        elevenlabsSuccess += (data['elevenlabs.successfulCalls'] as int?) ?? 0;
        elevenlabsFailed += (data['elevenlabs.failedCalls'] as int?) ?? 0;
        elevenlabsTotalTime += (data['elevenlabs.totalResponseTime'] as int?) ?? 0;
        elevenlabsTimeCount += (data['elevenlabs.responseTimeCount'] as int?) ?? 0;
        
        final elevenlabsErrorsData = data['elevenlabs.errors'] as Map<String, dynamic>?;
        if (elevenlabsErrorsData != null) {
          elevenlabsErrorsData.forEach((error, count) {
            elevenlabsErrors[error] = (elevenlabsErrors[error] ?? 0) + (count as int? ?? 0);
          });
        }
      }

      return {
        'period_days': days,
        'gemini': {
          'total': geminiTotal,
          'successful': geminiSuccess,
          'failed': geminiFailed,
          'success_rate': geminiTotal > 0 ? (geminiSuccess / geminiTotal * 100).toStringAsFixed(2) : '0.00',
          'avg_response_time_ms': geminiTimeCount > 0 ? (geminiTotalTime / geminiTimeCount).round() : 0,
          'models': geminiModels,
          'errors': geminiErrors,
        },
        'elevenlabs': {
          'total': elevenlabsTotal,
          'successful': elevenlabsSuccess,
          'failed': elevenlabsFailed,
          'success_rate': elevenlabsTotal > 0 ? (elevenlabsSuccess / elevenlabsTotal * 100).toStringAsFixed(2) : '0.00',
          'avg_response_time_ms': elevenlabsTimeCount > 0 ? (elevenlabsTotalTime / elevenlabsTimeCount).round() : 0,
          'errors': elevenlabsErrors,
        },
      };
    } catch (e) {
      Logger.error('Failed to get analytics summary: $e', tag: 'ApiAnalytics');
      return {'error': e.toString()};
    }
  }

  /// Clean up old analytics records (older than 30 days)
  Future<void> _cleanupOldAnalytics(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final snapshot = await _firestore
          .collection('api_analytics')
          .doc(userId)
          .collection('daily')
          .where('date', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .limit(100) // Clean up in batches
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      Logger.warn('Failed to cleanup old analytics: $e', tag: 'ApiAnalytics');
    }
  }
}

