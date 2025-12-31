import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickdose/core/models/side_effect_log_model.dart';
import 'package:tickdose/core/utils/firestore_validator.dart';
import 'package:tickdose/core/utils/logger.dart';

class SideEffectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<void> logSideEffect(SideEffectLog log) async {
    try {
      final data = log.toMap();
      
      // Validate data before saving
      final validationErrors = FirestoreValidator.validateSideEffect(data);
      if (validationErrors != null) {
        final errorMessage = validationErrors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        Logger.error('Side effect validation failed: $errorMessage', tag: 'SideEffectService');
        throw Exception('Validation failed: $errorMessage');
      }
      
      await _firestore
          .collection(_collection)
          .doc(log.userId)
          .collection('side_effects')
          .add(data);
    } catch (e) {
      Logger.error('Failed to log side effect: $e', tag: 'SideEffectService', error: e);
      throw Exception('Failed to log side effect: $e');
    }
  }

  Stream<List<SideEffectLog>> watchSideEffects(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('side_effects')
        .orderBy('occurredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SideEffectLog.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<SideEffectLog>> watchSideEffectsForMedicine(String userId, String medicineId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('side_effects')
        .where('medicineId', isEqualTo: medicineId)
        .orderBy('occurredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SideEffectLog.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteSideEffect(String userId, String effectId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('side_effects')
          .doc(effectId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete side effect: $e');
    }
  }
}
