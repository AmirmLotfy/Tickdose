import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tickdose/core/services/voice_reminder_service.dart';
import 'package:tickdose/core/utils/logger.dart';

class RemoteCommandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final VoiceReminderService _voiceService = VoiceReminderService();
  StreamSubscription? _commandSubscription;

  /// Send a command to a target user
  Future<void> sendCommand({
    required String targetUserId,
    required String commandType,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('commands')
          .add({
        'type': commandType,
        'payload': payload,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      Logger.info('Command sent to $targetUserId: $commandType');
    } catch (e) {
      Logger.error('Failed to send command: $e');
      rethrow;
    }
  }

  /// Listen for incoming commands for the current user
  void listenForCommands(String currentUserId) {
    _commandSubscription?.cancel();
    
    Logger.info('Listening for remote commands for user: $currentUserId');

    _commandSubscription = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('commands')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) async {
      for (final doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final data = doc.doc.data();
          if (data != null) {
            await _handleCommand(doc.doc.reference, data);
          }
        }
      }
    });
  }

  /// Handle receipt of a command
  Future<void> _handleCommand(DocumentReference docRef, Map<String, dynamic> data) async {
    try {
      final String type = data['type'] ?? 'unknown';
      final Map<String, dynamic> payload = data['payload'] ?? {};
      
      Logger.info('Received remote command: $type');

      // Mark as processing
      await docRef.update({'status': 'processing'});

      switch (type) {
        case 'voice_reminder':
          await _handleVoiceReminder(payload);
          break;
        default:
          Logger.warn('Unknown command type: $type');
      }

      // Mark as completed
      await docRef.update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Logger.error('Error handling command: $e');
      await docRef.update({
        'status': 'failed',
        'error': e.toString(),
      });
    }
  }

  /// Process voice reminder payload
  Future<void> _handleVoiceReminder(Map<String, dynamic> payload) async {
    final String medicineName = payload['medicineName'] ?? 'Medication';
    final String dosage = payload['dosage'] ?? '';
    
    await _voiceService.sendVoiceReminder(
      medicineName: medicineName,
      dosage: dosage,
      voiceId: '', // Uses default/preferred
      reminderType: VoiceReminderType.caregiver,
      caregiverMessage: payload['message'],
    );
  }
  
  void dispose() {
    _commandSubscription?.cancel();
  }
}
