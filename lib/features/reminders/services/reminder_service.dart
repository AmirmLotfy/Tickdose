import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickdose/core/models/reminder_model.dart';
import 'package:tickdose/core/utils/firestore_validator.dart';
import 'package:tickdose/core/utils/logger.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  Stream<List<ReminderModel>> watchReminders(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .collection('reminders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReminderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<ReminderModel>> getReminders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('reminders')
          .get();
      
      return snapshot.docs
          .map((doc) => ReminderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Logger.error('Failed to get reminders: $e', tag: 'ReminderService', error: e);
      throw Exception('Failed to get reminders: $e');
    }
  }

  Future<void> addReminder(String userId, ReminderModel reminder) async {
    try {
      final data = reminder.toMap();
      
      // Validate data before saving
      final validationErrors = FirestoreValidator.validateReminder(data);
      if (validationErrors != null) {
        final errorMessage = validationErrors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        Logger.error('Reminder validation failed: $errorMessage', tag: 'ReminderService');
        throw Exception('Validation failed: $errorMessage');
      }
      
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('reminders')
          .add(data);
    } catch (e) {
      Logger.error('Failed to add reminder: $e', tag: 'ReminderService', error: e);
      throw Exception('Failed to add reminder: $e');
    }
  }

  Future<void> updateReminder(String userId, ReminderModel reminder) async {
    try {
      final data = reminder.toMap();
      
      // Validate data before saving (for updates, createdAt is not required)
      final validationErrors = FirestoreValidator.validateReminder(data);
      if (validationErrors != null && validationErrors.containsKey('createdAt')) {
        validationErrors.remove('createdAt');
      }
      if (validationErrors != null && validationErrors.isNotEmpty) {
        final errorMessage = validationErrors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        Logger.error('Reminder validation failed: $errorMessage', tag: 'ReminderService');
        throw Exception('Validation failed: $errorMessage');
      }
      
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('reminders')
          .doc(reminder.id)
          .update(data);
    } catch (e) {
      Logger.error('Failed to update reminder: $e', tag: 'ReminderService', error: e);
      throw Exception('Failed to update reminder: $e');
    }
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .collection('reminders')
          .doc(reminderId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }
}
