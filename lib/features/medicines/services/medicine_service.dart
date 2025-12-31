import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickdose/core/models/medicine_model.dart';
import 'package:tickdose/core/utils/firestore_validator.dart';
import 'package:tickdose/core/utils/logger.dart';

class MedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users'; // medicines are subcollection of users

  Future<List<MedicineModel>> getMedicines(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('medicines')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch medicines: $e');
    }
  }

  Stream<List<MedicineModel>> watchMedicines(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('medicines')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicineModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    try {
      final data = medicine.toMap();
      
      // Validate data before saving
      final validationErrors = FirestoreValidator.validateMedicine(data);
      if (validationErrors != null) {
        final errorMessage = validationErrors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        Logger.error('Medicine validation failed: $errorMessage', tag: 'MedicineService');
        throw Exception('Validation failed: $errorMessage');
      }
      
      await _firestore
          .collection(_collection)
          .doc(medicine.userId)
          .collection('medicines')
          .add(data);
    } catch (e) {
      Logger.error('Failed to add medicine: $e', tag: 'MedicineService', error: e);
      throw Exception('Failed to add medicine: $e');
    }
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    try {
      final data = medicine.toMap();
      
      // Validate data before saving (for updates, some fields may be optional)
      final validationErrors = FirestoreValidator.validateMedicine(data);
      if (validationErrors != null && validationErrors.containsKey('createdAt')) {
        // createdAt is not required for updates, remove it from errors
        validationErrors.remove('createdAt');
      }
      if (validationErrors != null && validationErrors.isNotEmpty) {
        final errorMessage = validationErrors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        Logger.error('Medicine validation failed: $errorMessage', tag: 'MedicineService');
        throw Exception('Validation failed: $errorMessage');
      }
      
      await _firestore
          .collection(_collection)
          .doc(medicine.userId)
          .collection('medicines')
          .doc(medicine.id)
          .update(data);
    } catch (e) {
      Logger.error('Failed to update medicine: $e', tag: 'MedicineService', error: e);
      throw Exception('Failed to update medicine: $e');
    }
  }

  Future<void> deleteMedicine(String userId, String medicineId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('medicines')
          .doc(medicineId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete medicine: $e');
    }
  }
}
