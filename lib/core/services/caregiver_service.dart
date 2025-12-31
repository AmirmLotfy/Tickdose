import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickdose/core/models/caregiver_model.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for managing caregiver relationships
class CaregiverService {
  static final CaregiverService _instance = CaregiverService._internal();
  factory CaregiverService() => _instance;
  CaregiverService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'caregivers';

  /// Add a new caregiver (send invitation)
  /// 
  /// [userId] - The user being cared for
  /// [caregiverEmail] - Email of the caregiver
  /// [caregiverName] - Name of the caregiver
  /// [permissions] - Permissions to grant
  /// [relationship] - Relationship type
  /// Returns caregiver ID
  Future<String> addCaregiver({
    required String userId,
    required String caregiverEmail,
    required String caregiverName,
    List<CaregiverPermission>? permissions,
    String relationship = 'family',
  }) async {
    try {
      final permissionsList = permissions ?? [
        CaregiverPermission.viewMedications,
        CaregiverPermission.receiveAlerts,
      ];

      final caregiver = CaregiverModel(
        id: '', // Will be set by Firestore
        userId: userId,
        caregiverEmail: caregiverEmail,
        caregiverName: caregiverName,
        permissions: permissionsList,
        relationship: relationship,
      );

      final docRef = await _firestore.collection(_collection).add(caregiver.toMap());
      
      // Update user's caregiver list
      await _firestore.collection('users').doc(userId).update({
        'caregivers': FieldValue.arrayUnion([docRef.id]),
      });

      Logger.info('Caregiver added: $caregiverEmail for user $userId', tag: 'CaregiverService');
      
      // TODO: Send invitation email/FCM notification to caregiver
      
      return docRef.id;
    } catch (e) {
      Logger.error('Error adding caregiver: $e', tag: 'CaregiverService');
      rethrow;
    }
  }

  /// Remove a caregiver
  /// 
  /// [userId] - The user being cared for
  /// [caregiverId] - ID of caregiver to remove
  Future<void> removeCaregiver({
    required String userId,
    required String caregiverId,
  }) async {
    try {
      // Update caregiver status
      await _firestore.collection(_collection).doc(caregiverId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Remove from user's caregiver list
      await _firestore.collection('users').doc(userId).update({
        'caregivers': FieldValue.arrayRemove([caregiverId]),
      });

      Logger.info('Caregiver removed: $caregiverId', tag: 'CaregiverService');
    } catch (e) {
      Logger.error('Error removing caregiver: $e', tag: 'CaregiverService');
      rethrow;
    }
  }

  /// Update caregiver permissions
  /// 
  /// [caregiverId] - ID of caregiver
  /// [permissions] - New permissions list
  Future<void> updateCaregiverPermissions({
    required String caregiverId,
    required List<CaregiverPermission> permissions,
  }) async {
    try {
      await _firestore.collection(_collection).doc(caregiverId).update({
        'permissions': permissions.map((p) => p.name).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Logger.info('Caregiver permissions updated: $caregiverId', tag: 'CaregiverService');
    } catch (e) {
      Logger.error('Error updating caregiver permissions: $e', tag: 'CaregiverService');
      rethrow;
    }
  }

  /// Get all caregivers for a user
  /// 
  /// [userId] - The user being cared for
  /// Returns list of caregivers
  Future<List<CaregiverModel>> getCaregivers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => CaregiverModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Logger.error('Error getting caregivers: $e', tag: 'CaregiverService');
      rethrow;
    }
  }

  /// Stream of caregivers for a user
  Stream<List<CaregiverModel>> watchCaregivers(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CaregiverModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Check if caregiver has access to specific data
  /// 
  /// [caregiverId] - ID of caregiver
  /// [permission] - Permission to check
  /// Returns true if caregiver has permission
  Future<bool> checkCaregiverAccess({
    required String caregiverId,
    required CaregiverPermission permission,
  }) async {
    try {
      final doc = await _firestore.collection(_collection).doc(caregiverId).get();
      
      if (!doc.exists) return false;

      final caregiver = CaregiverModel.fromMap(doc.data()!, doc.id);
      return caregiver.hasPermission(permission) && caregiver.isActive;
    } catch (e) {
      Logger.error('Error checking caregiver access: $e', tag: 'CaregiverService');
      return false;
    }
  }

  /// Get caregiver by ID
  Future<CaregiverModel?> getCaregiver(String caregiverId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(caregiverId).get();
      
      if (!doc.exists) return null;

      return CaregiverModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      Logger.error('Error getting caregiver: $e', tag: 'CaregiverService');
      return null;
    }
  }
}
