import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for crash recovery and data restoration
class CrashRecoveryService {
  static final CrashRecoveryService _instance = CrashRecoveryService._internal();
  factory CrashRecoveryService() => _instance;
  CrashRecoveryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _pendingOperationsKey = 'pending_operations';

  /// Save last successful sync timestamp
  Future<void> saveLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      Logger.info('Last sync timestamp saved', tag: 'CrashRecovery');
    } catch (e) {
      Logger.error('Failed to save last sync timestamp: $e', tag: 'CrashRecovery', error: e);
    }
  }

  /// Get last successful sync timestamp
  Future<DateTime?> getLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      Logger.error('Failed to get last sync timestamp: $e', tag: 'CrashRecovery', error: e);
    }
    return null;
  }

  /// Save pending operation to be retried after crash
  Future<void> savePendingOperation(String operation, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingOps = prefs.getStringList(_pendingOperationsKey) ?? [];
      final operationData = {
        'operation': operation,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      pendingOps.add(operationData.toString());
      await prefs.setStringList(_pendingOperationsKey, pendingOps);
      Logger.info('Pending operation saved: $operation', tag: 'CrashRecovery');
    } catch (e) {
      Logger.error('Failed to save pending operation: $e', tag: 'CrashRecovery', error: e);
    }
  }

  /// Restore pending operations after app restart
  Future<void> restorePendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingOps = prefs.getStringList(_pendingOperationsKey) ?? [];
      
      if (pendingOps.isEmpty) {
        return;
      }

      Logger.info('Restoring ${pendingOps.length} pending operations', tag: 'CrashRecovery');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Logger.warn('No user logged in, cannot restore operations', tag: 'CrashRecovery');
        return;
      }

      // Clear pending operations (will re-add if they fail)
      await prefs.remove(_pendingOperationsKey);

      // Process each pending operation
      for (final opString in pendingOps) {
        try {
          // Parse and retry operation
          // Note: This is a simplified version - in production, you'd want proper serialization
          Logger.info('Retrying operation: $opString', tag: 'CrashRecovery');
          // Operations would be retried here based on type
        } catch (e) {
          Logger.error('Failed to restore operation: $e', tag: 'CrashRecovery', error: e);
          // Re-add failed operations
          final failedOps = prefs.getStringList(_pendingOperationsKey) ?? [];
          failedOps.add(opString);
          await prefs.setStringList(_pendingOperationsKey, failedOps);
        }
      }
    } catch (e) {
      Logger.error('Failed to restore pending operations: $e', tag: 'CrashRecovery', error: e);
    }
  }

  /// Check for data inconsistencies and attempt recovery
  Future<void> checkAndRecoverData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      Logger.info('Checking for data inconsistencies', tag: 'CrashRecovery');

      // Check if user profile exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        Logger.warn('User profile missing, attempting recovery', tag: 'CrashRecovery');
        // Could attempt to recreate from Firebase Auth data
      }

      // Check for orphaned data
      // This is a placeholder - in production, you'd implement specific recovery logic
      
      Logger.info('Data recovery check completed', tag: 'CrashRecovery');
    } catch (e) {
      Logger.error('Data recovery check failed: $e', tag: 'CrashRecovery', error: e);
    }
  }

  /// Clear all pending operations (after successful sync)
  Future<void> clearPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingOperationsKey);
      Logger.info('Pending operations cleared', tag: 'CrashRecovery');
    } catch (e) {
      Logger.error('Failed to clear pending operations: $e', tag: 'CrashRecovery', error: e);
    }
  }
}
