import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tickdose/core/models/caregiver_model.dart';
import 'package:tickdose/core/services/caregiver_service.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for secure caregiver invitation and sharing
class CaregiverSharingService {
  static final CaregiverSharingService _instance = CaregiverSharingService._internal();
  factory CaregiverSharingService() => _instance;
  CaregiverSharingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _invitationsCollection = 'caregiver_invitations';

  /// Generate secure token for caregiver invitation
  String _generateInvitationToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Create caregiver invitation with secure token
  /// 
  /// [userId] - User being cared for
  /// [caregiverEmail] - Email of caregiver
  /// [permissions] - Permissions to grant
  /// Returns invitation token
  Future<String> createInvitation({
    required String userId,
    required String caregiverEmail,
    required List<CaregiverPermission> permissions,
  }) async {
    try {
      final token = _generateInvitationToken();
      final expiresAt = DateTime.now().add(const Duration(days: 7)); // Token expires in 7 days

      await _firestore.collection(_invitationsCollection).doc(token).set({
        'userId': userId,
        'caregiverEmail': caregiverEmail,
        'permissions': permissions.map((p) => p.name).toList(),
        'token': token,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'used': false,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      Logger.info('Invitation token created: $token', tag: 'CaregiverSharing');
      
      // TODO: Send invitation email with token link
      
      return token;
    } catch (e) {
      Logger.error('Error creating invitation: $e', tag: 'CaregiverSharing');
      rethrow;
    }
  }

  /// Validate and accept invitation token
  /// 
  /// [token] - Invitation token
  /// [caregiverUserId] - Caregiver's user ID (if they have an account)
  /// Returns true if accepted successfully
  Future<bool> acceptInvitation({
    required String token,
    String? caregiverUserId,
  }) async {
    try {
      final doc = await _firestore.collection(_invitationsCollection).doc(token).get();
      
      if (!doc.exists) {
        Logger.warn('Invitation token not found: $token', tag: 'CaregiverSharing');
        return false;
      }

      final data = doc.data()!;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final used = data['used'] as bool? ?? false;

      if (used) {
        Logger.warn('Invitation token already used: $token', tag: 'CaregiverSharing');
        return false;
      }

      if (DateTime.now().isAfter(expiresAt)) {
        Logger.warn('Invitation token expired: $token', tag: 'CaregiverSharing');
        return false;
      }

      final userId = data['userId'] as String;
      final caregiverEmail = data['caregiverEmail'] as String;
      final permissions = (data['permissions'] as List<dynamic>?)
              ?.map((p) => CaregiverPermission.values.firstWhere(
                    (perm) => perm.name == p,
                    orElse: () => CaregiverPermission.viewMedications,
                  ))
              .toList() ??
          [];

      // Mark token as used
      await _firestore.collection(_invitationsCollection).doc(token).update({
        'used': true,
        'acceptedAt': Timestamp.fromDate(DateTime.now()),
        'caregiverUserId': caregiverUserId,
      });

      // Create caregiver relationship
      final caregiverService = CaregiverService();
      
      // Note: addCaregiver doesn't accept caregiverUserId parameter, 
      // so we need to update the caregiver record after creation
      final caregiverId = await caregiverService.addCaregiver(
        userId: userId,
        caregiverEmail: caregiverEmail,
        caregiverName: caregiverEmail.split('@').first, // Use email prefix as name
        permissions: permissions,
      );
      
      // Update caregiver record with caregiverUserId if provided
      if (caregiverUserId != null) {
        await FirebaseFirestore.instance
            .collection('caregivers')
            .doc(caregiverId)
            .update({'caregiverUserId': caregiverUserId});
      }

      Logger.info('Invitation accepted: $token', tag: 'CaregiverSharing');
      return true;
    } catch (e) {
      Logger.error('Error accepting invitation: $e', tag: 'CaregiverSharing');
      return false;
    }
  }

  /// Revoke invitation token
  /// 
  /// [token] - Token to revoke
  Future<void> revokeInvitation(String token) async {
    try {
      await _firestore.collection(_invitationsCollection).doc(token).update({
        'used': true,
        'revokedAt': Timestamp.fromDate(DateTime.now()),
      });

      Logger.info('Invitation revoked: $token', tag: 'CaregiverSharing');
    } catch (e) {
      Logger.error('Error revoking invitation: $e', tag: 'CaregiverSharing');
      rethrow;
    }
  }

  /// Get invitation details by token
  Future<Map<String, dynamic>?> getInvitation(String token) async {
    try {
      final doc = await _firestore.collection(_invitationsCollection).doc(token).get();
      
      if (!doc.exists) return null;

      return doc.data();
    } catch (e) {
      Logger.error('Error getting invitation: $e', tag: 'CaregiverSharing');
      return null;
    }
  }

  /// Get invitation URL for sharing
  /// 
  /// [token] - Invitation token
  /// [useCustomScheme] - Use custom scheme (tickdose://) instead of HTTPS
  String getInvitationUrl(String token, {bool useCustomScheme = false}) {
    if (useCustomScheme) {
      return 'tickdose://invite?token=$token';
    }
    return 'https://tickdose.app/invite?token=$token';
  }

  /// Check if the logged-in user's email matches the invitation's caregiver email
  /// 
  /// [token] - Invitation token
  Future<bool> checkEmailMatch(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email == null) return false;

      final invitation = await getInvitation(token);
      if (invitation == null) return false;

      final caregiverEmail = invitation['caregiverEmail'] as String?;
      return caregiverEmail?.toLowerCase() == user!.email!.toLowerCase();
    } catch (e) {
      Logger.error('Error checking email match: $e', tag: 'CaregiverSharing');
      return false;
    }
  }
}
