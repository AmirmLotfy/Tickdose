import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';
import '../utils/firestore_validator.dart';

/// Service for managing user profiles in Firestore
/// Handles creation, updates, and retrieval of user data
class FirebaseUserService {
  static final FirebaseUserService _instance = FirebaseUserService._internal();
  factory FirebaseUserService() => _instance;
  FirebaseUserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new user profile in Firestore after Firebase Auth registration
  /// This MUST be called immediately after user registration
  Future<void> createUserProfile(User user, String displayName) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      // Check if profile already exists (in case of re-creation)
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        // Update existing profile instead
        await userDoc.update({
          'displayName': displayName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      // Create new profile
      final profileData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': displayName,
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Optional health-related fields
        'healthInfo': {
          'allergies': [],
          'chronicConditions': [],
          'emergencyContact': null,
        },
        // App preferences
        'preferences': {
          'notificationsEnabled': true,
          'darkMode': false,
          'language': 'en',
        },
      };
      
      // Validate profile data before saving
      final validationErrors = FirestoreValidator.validateUserProfile(profileData);
      if (validationErrors != null) {
        final errorMessage = validationErrors.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        Logger.error('User profile validation failed: $errorMessage', tag: 'FirebaseUserService');
        throw Exception('Validation failed: $errorMessage');
      }
      
      await userDoc.set(profileData);
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Update FCM token in user profile
  /// 
  /// [uid] - User ID
  /// [fcmToken] - Firebase Cloud Messaging token
  Future<void> updateFCMToken(String uid, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      Logger.info('FCM token updated for user: $uid', tag: 'FirebaseUserService');
    } catch (e) {
      Logger.error('Error updating FCM token: $e', tag: 'FirebaseUserService');
      rethrow;
    }
  }

  /// Updates user profile in Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Gets user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Deletes user profile from Firestore (for account deletion)
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  /// Updates email verification status in Firestore
  Future<void> updateEmailVerificationStatus(String uid, bool isVerified) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'emailVerified': isVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update email verification status: $e');
    }
  }
}
