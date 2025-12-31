import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

/// Rate limiter for API calls to prevent quota exhaustion
/// Tracks API usage per user and enforces limits
class ApiRateLimiter {
  static final ApiRateLimiter _instance = ApiRateLimiter._internal();
  factory ApiRateLimiter() => _instance;
  ApiRateLimiter._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Rate limits per user per day
  static const int geminiDailyLimit = 50; // Gemini API calls per day
  static const int elevenlabsDailyLimit = 100; // ElevenLabs API calls per day
  
  // Rate limits per minute to prevent burst usage
  static const int geminiPerMinuteLimit = 5;
  static const int elevenlabsPerMinuteLimit = 10;
  
  // Rate limits per hour (sliding window)
  static const int geminiPerHourLimit = 20; // Gemini API calls per hour
  static const int elevenlabsPerHourLimit = 40; // ElevenLabs API calls per hour

  /// Check if user can make a Gemini API call
  Future<RateLimitResult> checkGeminiLimit(String userId) async {
    return await _checkLimit(userId, 'gemini', geminiDailyLimit, geminiPerMinuteLimit, geminiPerHourLimit);
  }

  /// Check if user can make an ElevenLabs API call
  Future<RateLimitResult> checkElevenLabsLimit(String userId) async {
    return await _checkLimit(userId, 'elevenlabs', elevenlabsDailyLimit, elevenlabsPerMinuteLimit, elevenlabsPerHourLimit);
  }

  /// Record an API call for rate limiting tracking
  Future<void> recordApiCall(String userId, String apiType) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final docRef = _firestore
          .collection('api_usage')
          .doc(userId)
          .collection('daily')
          .doc(today.toIso8601String().split('T')[0]);

      await docRef.set({
        'userId': userId,
        'date': Timestamp.fromDate(today),
        '$apiType.calls': FieldValue.increment(1),
        '$apiType.lastCall': Timestamp.now(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Also record per-minute calls
      final minuteDocRef = _firestore
          .collection('api_usage')
          .doc(userId)
          .collection('minute')
          .doc('${now.millisecondsSinceEpoch ~/ 60000}');

      await minuteDocRef.set({
        'userId': userId,
        'timestamp': Timestamp.now(),
        '$apiType.calls': FieldValue.increment(1),
      }, SetOptions(merge: true));

      // Record per-hour calls (for sliding window)
      final hourDocRef = _firestore
          .collection('api_usage')
          .doc(userId)
          .collection('hour')
          .doc('${now.millisecondsSinceEpoch ~/ 3600000}');

      await hourDocRef.set({
        'userId': userId,
        'timestamp': Timestamp.now(),
        '$apiType.calls': FieldValue.increment(1),
      }, SetOptions(merge: true));

      // Clean up old minute-level records (older than 1 hour)
      await _cleanupOldMinuteRecords(userId);
      
      // Clean up old hour-level records (older than 24 hours)
      await _cleanupOldHourRecords(userId);
    } catch (e) {
      Logger.error('Failed to record API call: $e', tag: 'ApiRateLimiter');
      // Don't throw - rate limiting shouldn't break the app
    }
  }

  Future<RateLimitResult> _checkLimit(
    String userId,
    String apiType,
    int dailyLimit,
    int perMinuteLimit,
    int perHourLimit,
  ) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final currentMinute = now.millisecondsSinceEpoch ~/ 60000;

      // Check daily limit
      final dailyDoc = await _firestore
          .collection('api_usage')
          .doc(userId)
          .collection('daily')
          .doc(today.toIso8601String().split('T')[0])
          .get();

      int dailyCalls = 0;
      if (dailyDoc.exists) {
        dailyCalls = (dailyDoc.data()?['$apiType.calls'] as int?) ?? 0;
      }

      if (dailyCalls >= dailyLimit) {
        // final lastCallTime = (dailyDoc.data()?['$apiType.lastCall'] as Timestamp?)?.toDate(); // Unused variable
        final resetTime = today.add(const Duration(days: 1));
        
        return RateLimitResult(
          allowed: false,
          limitType: 'daily',
          currentCount: dailyCalls,
          limit: dailyLimit,
          resetTime: resetTime,
          message: 'Daily API limit reached. Please try again tomorrow.',
        );
      }

      // Check per-minute limit
      final minuteDoc = await _firestore
          .collection('api_usage')
          .doc(userId)
          .collection('minute')
          .doc(currentMinute.toString())
          .get();

      int minuteCalls = 0;
      if (minuteDoc.exists) {
        minuteCalls = (minuteDoc.data()?['$apiType.calls'] as int?) ?? 0;
      }

      if (minuteCalls >= perMinuteLimit) {
        final resetTime = DateTime.fromMillisecondsSinceEpoch((currentMinute + 1) * 60000);
        
        return RateLimitResult(
          allowed: false,
          limitType: 'minute',
          currentCount: minuteCalls,
          limit: perMinuteLimit,
          resetTime: resetTime,
          message: 'Too many requests. Please wait a moment and try again.',
        );
      }

      // Check per-hour limit (sliding window - last 60 minutes)
      final currentHour = now.millisecondsSinceEpoch ~/ 3600000;
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
      final cutoffHour = oneHourAgo.millisecondsSinceEpoch ~/ 3600000;
      
      // Get all hour records from the last 60 minutes
      final hourSnapshot = await _firestore
          .collection('api_usage')
          .doc(userId)
          .collection('hour')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(oneHourAgo))
          .get();
      
      int hourCalls = 0;
      for (var doc in hourSnapshot.docs) {
        final hourData = doc.data();
        final hourCallsForDoc = (hourData['$apiType.calls'] as int?) ?? 0;
        hourCalls += hourCallsForDoc;
      }
      
      if (hourCalls >= perHourLimit) {
        final resetTime = DateTime.fromMillisecondsSinceEpoch((currentHour + 1) * 3600000);
        
        return RateLimitResult(
          allowed: false,
          limitType: 'hour',
          currentCount: hourCalls,
          limit: perHourLimit,
          resetTime: resetTime,
          message: 'Hourly API limit reached. Please try again later.',
        );
      }

      return RateLimitResult(
        allowed: true,
        limitType: 'none',
        currentCount: dailyCalls,
        limit: dailyLimit,
        remainingCalls: dailyLimit - dailyCalls,
      );
    } catch (e) {
      Logger.error('Error checking rate limit: $e', tag: 'ApiRateLimiter');
      // On error, allow the call (fail open) but log the error
      return RateLimitResult(
        allowed: true,
        limitType: 'error',
        currentCount: 0,
        limit: dailyLimit,
        remainingCalls: dailyLimit,
      );
    }
  }

  /// Clean up old minute-level records (older than 1 hour)
  Future<void> _cleanupOldMinuteRecords(String userId) async {
    try {
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

      final snapshot = await _firestore
          .collection('api_usage')
          .doc(userId)
          .collection('minute')
          .where('timestamp', isLessThan: Timestamp.fromDate(oneHourAgo))
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
      Logger.warn('Failed to cleanup old minute records: $e', tag: 'ApiRateLimiter');
    }
  }
  
  /// Clean up old hour-level records (older than 24 hours)
  Future<void> _cleanupOldHourRecords(String userId) async {
    try {
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('api_usage')
          .doc(userId)
          .collection('hour')
          .where('timestamp', isLessThan: Timestamp.fromDate(oneDayAgo))
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
      Logger.warn('Failed to cleanup old hour records: $e', tag: 'ApiRateLimiter');
    }
  }

  /// Get current usage stats for a user
  Future<Map<String, dynamic>> getUsageStats(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final doc = await _firestore
          .collection('api_usage')
          .doc(userId)
          .collection('daily')
          .doc(today.toIso8601String().split('T')[0])
          .get();

      if (!doc.exists) {
        return {
          'gemini': {'used': 0, 'limit': geminiDailyLimit, 'remaining': geminiDailyLimit},
          'elevenlabs': {'used': 0, 'limit': elevenlabsDailyLimit, 'remaining': elevenlabsDailyLimit},
        };
      }

      final data = doc.data() ?? {};
      final geminiUsed = (data['gemini.calls'] as int?) ?? 0;
      final elevenlabsUsed = (data['elevenlabs.calls'] as int?) ?? 0;

      return {
        'gemini': {
          'used': geminiUsed,
          'limit': geminiDailyLimit,
          'remaining': (geminiDailyLimit - geminiUsed).clamp(0, geminiDailyLimit),
        },
        'elevenlabs': {
          'used': elevenlabsUsed,
          'limit': elevenlabsDailyLimit,
          'remaining': (elevenlabsDailyLimit - elevenlabsUsed).clamp(0, elevenlabsDailyLimit),
        },
      };
    } catch (e) {
      Logger.error('Failed to get usage stats: $e', tag: 'ApiRateLimiter');
      return {
        'gemini': {'used': 0, 'limit': geminiDailyLimit, 'remaining': geminiDailyLimit},
        'elevenlabs': {'used': 0, 'limit': elevenlabsDailyLimit, 'remaining': elevenlabsDailyLimit},
      };
    }
  }
}

class RateLimitResult {
  final bool allowed;
  final String limitType; // 'daily', 'minute', 'hour', 'none', 'error'
  final int currentCount;
  final int limit;
  final int? remainingCalls;
  final DateTime? resetTime;
  final String? message;

  RateLimitResult({
    required this.allowed,
    required this.limitType,
    required this.currentCount,
    required this.limit,
    this.remainingCalls,
    this.resetTime,
    this.message,
  });
  
  /// Get rate limit headers for API responses
  Map<String, String> toHeaders() {
    return {
      'X-RateLimit-Limit': limit.toString(),
      'X-RateLimit-Remaining': (remainingCalls ?? 0).toString(),
      'X-RateLimit-Reset': resetTime?.millisecondsSinceEpoch.toString() ?? '',
      'X-RateLimit-Type': limitType,
    };
  }
}
