import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';
import 'package:tickdose/core/utils/firestore_validator.dart';
import 'package:tickdose/core/utils/logger.dart';

class TrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<void> logMedicine(MedicineLogModel log) async {
    try {
      final data = log.toMap();
      
      // Validate data before saving
      final validationErrors = FirestoreValidator.validateMedicineLog(data);
      if (validationErrors != null) {
        final errorMessage = validationErrors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        Logger.error('Medicine log validation failed: $errorMessage', tag: 'TrackingService');
        throw Exception('Validation failed: $errorMessage');
      }
      
      await _firestore
          .collection(_collection)
          .doc(log.userId)
          .collection('logs')
          .add(data);
    } catch (e) {
      Logger.error('Failed to log medicine: $e', tag: 'TrackingService', error: e);
      throw Exception('Failed to log medicine: $e');
    }
  }

  Future<void> updateLog(String userId, MedicineLogModel log) async {
    try {
      final data = log.toMap();
      
      // Validate data before saving
      final validationErrors = FirestoreValidator.validateMedicineLog(data);
      if (validationErrors != null) {
        final errorMessage = validationErrors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        Logger.error('Medicine log validation failed: $errorMessage', tag: 'TrackingService');
        throw Exception('Validation failed: $errorMessage');
      }
      
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('logs')
          .doc(log.id)
          .update(data);
    } catch (e) {
      Logger.error('Failed to update log: $e', tag: 'TrackingService', error: e);
      throw Exception('Failed to update log: $e');
    }
  }

  Future<void> deleteLog(String userId, String logId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('logs')
          .doc(logId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete log: $e');
    }
  }

  Stream<List<MedicineLogModel>> watchLogsForDay(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('logs')
        .where('takenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('takenAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('takenAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineLogModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MedicineLogModel>> watchLogsForMonth(String userId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('logs')
        .where('takenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('takenAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineLogModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<Map<String, int>> getMonthlyStats(String userId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    final snapshot = await _firestore
        .collection(_collection)
        .doc(userId)
        .collection('logs')
        .where('takenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('takenAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .get();

    int taken = 0;
    int missed = 0;
    int skipped = 0;

    for (var doc in snapshot.docs) {
      final status = doc.data()['status'] ?? 'taken';
      if (status == 'taken') {
        taken++;
      } else if (status == 'missed') {
        missed++;
      } else if (status == 'skipped') {
        skipped++;
      }
    }

    return {'taken': taken, 'missed': missed, 'skipped': skipped};
  }

  Future<int> getStreak(String userId) async {
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('logs')
          .where('takenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('takenAt', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', isEqualTo: 'taken')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) break;
      streak++;
    }

    return streak;
  }
}
