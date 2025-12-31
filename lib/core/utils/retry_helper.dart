import 'dart:async';
import 'dart:math';
import '../utils/logger.dart';

/// Helper class for retrying operations with exponential backoff
class RetryHelper {
  /// Execute an async operation with retry logic and exponential backoff
  /// 
  /// [operation] - The async operation to retry
  /// [maxRetries] - Maximum number of retry attempts (default: 3)
  /// [initialDelay] - Initial delay before first retry in seconds (default: 1)
  /// [maxDelay] - Maximum delay between retries in seconds (default: 60)
  /// [retryable] - Function to determine if error should be retried (default: retries all errors)
  /// 
  /// Returns the result of the operation or throws the last error
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 60),
    bool Function(dynamic error)? retryable,
  }) async {
    int attempt = 0;
    
    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        attempt++;
        
        // Check if error should be retried
        if (retryable != null && !retryable(e)) {
          Logger.info('Error is not retryable, throwing immediately', tag: 'RetryHelper');
          rethrow;
        }
        
        // If this was the last attempt, throw the error
        if (attempt > maxRetries) {
          Logger.error('Operation failed after $maxRetries retries', tag: 'RetryHelper', error: e, stackTrace: stackTrace);
          rethrow;
        }
        
        // Calculate exponential backoff delay with jitter
        final delay = _calculateDelay(attempt, initialDelay, maxDelay);
        Logger.warn('Operation failed (attempt $attempt/$maxRetries), retrying in ${delay.inSeconds}s', tag: 'RetryHelper', error: e);
        
        await Future.delayed(delay);
      }
    }
    
    // Should never reach here, but satisfy the type checker
    throw StateError('Retry logic ended unexpectedly');
  }

  /// Calculate exponential backoff delay with jitter
  static Duration _calculateDelay(int attempt, Duration initialDelay, Duration maxDelay) {
    // Exponential backoff: delay = initialDelay * 2^(attempt-1)
    final exponentialDelay = initialDelay.inMilliseconds * pow(2, attempt - 1);
    
    // Add jitter (random 0-25% of delay) to prevent thundering herd
    final jitter = exponentialDelay * 0.25 * Random().nextDouble();
    final totalDelay = exponentialDelay + jitter;
    
    // Cap at maxDelay
    final cappedDelay = totalDelay > maxDelay.inMilliseconds 
        ? maxDelay.inMilliseconds 
        : totalDelay;
    
    return Duration(milliseconds: cappedDelay.toInt());
  }

  /// Check if an error is a network-related error that should be retried
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('socket') ||
           errorString.contains('failed host lookup') ||
           errorString.contains('connection refused');
  }

  /// Check if an error is a Firestore error that should be retried
  static bool isFirestoreRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('unavailable') ||
           errorString.contains('deadline exceeded') ||
           errorString.contains('resource exhausted') ||
           errorString.contains('internal error') ||
           isNetworkError(error);
  }
}
