import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/features/tracking/services/tracking_service.dart';
import 'package:tickdose/features/medicines/services/medicine_service.dart';
import 'package:tickdose/features/reminders/services/reminder_service.dart';
import 'package:tickdose/core/services/voice_reminder_service.dart';
import 'package:tickdose/core/services/elevenlabs_service.dart';
import 'package:tickdose/core/services/audio_service.dart';

/// Service to handle notification actions (yes/no buttons) and voice reminders
class NotificationActionService {
  static final NotificationActionService _instance = NotificationActionService._internal();
  factory NotificationActionService() => _instance;
  NotificationActionService._internal();
  
  final TrackingService _trackingService = TrackingService();
  final MedicineService _medicineService = MedicineService();
  final ReminderService _reminderService = ReminderService();
  final VoiceReminderService _voiceReminderService = VoiceReminderService();
  final ElevenLabsService _elevenLabsService = ElevenLabsService();
  final AudioService _audioService = AudioService();
  final _uuid = const Uuid();
  
  /// Handle notification action (yes/no button tap) or notification display
  /// This is called both when notification is shown and when user taps it
  Future<void> handleNotificationAction(NotificationResponse response) async {
    Logger.info('Notification action received: ${response.actionId}, payload: ${response.payload}', tag: 'NotificationActionService');
    
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Logger.warn('No authenticated user for notification action', tag: 'NotificationActionService');
      return;
    }
    
    // Parse payload: format is "medicineId|reminderId" or "medicineId|reminderId|audio:filepath"
    final payload = response.payload;
    if (payload == null || !payload.contains('|')) {
      Logger.warn('Invalid notification payload: $payload', tag: 'NotificationActionService');
      return;
    }
    
    final parts = payload.split('|');
    if (parts.length < 2) {
      Logger.warn('Invalid payload format: $payload', tag: 'NotificationActionService');
      return;
    }
    
    final medicineId = parts[0];
    final reminderId = parts[1];
    final actionId = response.actionId;
    
    // Extract custom audio file path if present (format: |audio:path)
    String? customAudioFilePath;
    for (final part in parts) {
      if (part.startsWith('audio:')) {
        customAudioFilePath = part.substring(6); // Remove 'audio:' prefix
        break;
      }
    }
    
    Logger.info('Parsed: medicineId=$medicineId, reminderId=$reminderId, action=$actionId, audioFile=${customAudioFilePath != null ? "present" : "none"}', tag: 'NotificationActionService');
    
    try {
      // Get medicine and reminder details
      final medicines = await _medicineService.getMedicines(user.uid);
      final medicine = medicines.firstWhere((m) => m.id == medicineId, orElse: () => throw Exception('Medicine not found'));
      
      final reminders = await _reminderService.getReminders(user.uid);
      final reminder = reminders.firstWhere((r) => r.id == reminderId, orElse: () => throw Exception('Reminder not found'));
      
      // If no action (notification just fired, not tapped), play voice reminder audio
      if (actionId == null) {
        // COST-OPTIMIZED LAZY GENERATION: Generate audio on-demand when notification fires
        // This is much more cost-effective than pre-generating all reminders
        
        // Step 1: Try to use pre-generated audio file if provided in payload
        if (customAudioFilePath != null) {
          try {
            final audioFile = File(customAudioFilePath);
            if (await audioFile.exists()) {
              Logger.info('Playing pre-generated voice reminder audio: $customAudioFilePath', tag: 'NotificationActionService');
              await _elevenLabsService.playAudio(audioPath: customAudioFilePath);
              Logger.info('Voice reminder audio played successfully', tag: 'NotificationActionService');
              return; // Successfully played audio, exit
            } else {
              Logger.info('Pre-provided audio file not found, will generate on-demand', tag: 'NotificationActionService');
            }
          } catch (e) {
            Logger.warn('Error playing pre-generated audio: $e, will generate on-demand', tag: 'NotificationActionService');
          }
        }
        
        // Step 2: Check if voice reminders are enabled and get ALL voice settings
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        bool voiceRemindersEnabled = false;
        String? voiceId;
        String? modelId;
        double? clarity;
        double? styleExaggeration;
        bool? speakerBoost;
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final voiceSettings = userData['voiceSettings'] as Map<String, dynamic>?;
          voiceRemindersEnabled = voiceSettings?['useVoiceReminders'] ?? false; // Default to FALSE (opt-in)
          voiceId = voiceSettings?['selectedVoiceId'] ?? 'default';
          // Get all advanced voice settings
          modelId = voiceSettings?['selectedModel'] as String?;
          clarity = (voiceSettings?['clarity'] as num?)?.toDouble();
          styleExaggeration = (voiceSettings?['styleExaggeration'] as num?)?.toDouble();
          speakerBoost = voiceSettings?['speakerBoost'] as bool?;
          
          // Get user language preference
          final language = userData['language'] as String? ?? 'en';
          
          if (voiceRemindersEnabled) {
            // Step 3: Generate audio file on-demand (lazy generation) with ALL voice settings
            // This method checks if file already exists before generating (cost-saving)
            try {
              final voiceReminderService = VoiceReminderService();
              final generatedAudioPath = await voiceReminderService.generateReminderAudioFileFromModel(
                reminder: reminder,
                voiceId: voiceId ?? 'default',
                modelId: modelId,
                clarity: clarity,
                styleExaggeration: styleExaggeration,
                speakerBoost: speakerBoost,
                language: language,
              );
              
              if (generatedAudioPath != null) {
                // Play the generated audio
                await _elevenLabsService.playAudio(audioPath: generatedAudioPath);
                Logger.info('Voice reminder audio generated on-demand and played successfully (language: $language)', tag: 'NotificationActionService');
                return; // Success
              } else {
                Logger.warn('Audio generation failed, will use asset sound fallback', tag: 'NotificationActionService');
              }
            } catch (e, stackTrace) {
              Logger.error(
                'Error generating voice reminder on-demand: $e',
                tag: 'NotificationActionService',
                stackTrace: stackTrace,
              );
              // Fall through to asset sound fallback
            }
          } else {
            Logger.info('Voice reminders disabled, using asset sound', tag: 'NotificationActionService');
          }
        }
        
        // Step 4: Final fallback: Play asset sound (reminder_alert.mp3)
        // This is free and works offline - no API costs
        try {
          await _audioService.playSound(SoundEffect.reminderAlert);
          Logger.info('Played asset sound fallback (reminder_alert.mp3)', tag: 'NotificationActionService');
        } catch (e, stackTrace) {
          Logger.error(
            'Error playing asset sound: $e',
            tag: 'NotificationActionService',
            stackTrace: stackTrace,
          );
          // Even if asset sound fails, notification was already shown with system default sound
          // This is the final fallback - graceful degradation
        }
        
        return; // Don't log if it's just the notification firing
      }
      
      // Handle action button taps (yes/no)
      // Determine status based on action
      final status = (actionId == 'yes_action') ? 'taken' : 'skipped';
      
      // Create medicine log
      final log = MedicineLogModel(
        id: _uuid.v4(),
        userId: user.uid,
        medicineId: medicineId,
        medicineName: medicine.name,
        takenAt: DateTime.now(),
        status: status,
        notes: actionId == 'yes_action' ? 'Confirmed via notification' : 'Skipped via notification',
      );
      
      // Log to Firestore
      await _trackingService.logMedicine(log);
      Logger.info('Medicine logged: $status for ${medicine.name}', tag: 'NotificationActionService');
      
    } catch (e, stackTrace) {
      Logger.error('Error handling notification action: $e', tag: 'NotificationActionService', stackTrace: stackTrace);
    }
  }
  
  /// Trigger voice reminder when notification fires
  /// This should be called when a notification is received (foreground or background)
  Future<void> triggerVoiceReminderOnNotification({
    required String medicineId,
    required String reminderId,
    required String userId,
    String? voiceId,
  }) async {
    try {
      Logger.info('Triggering voice reminder for notification: medicineId=$medicineId, reminderId=$reminderId', tag: 'NotificationActionService');
      
      // Get reminder details
      final reminders = await _reminderService.getReminders(userId);
      final reminder = reminders.firstWhere(
        (r) => r.id == reminderId,
        orElse: () => throw Exception('Reminder not found'),
      );
      
      // Get medicine details (currently unused but may be needed for future features)
      // final medicines = await _medicineService.getMedicines(userId);
      // final medicine = medicines.firstWhere(
      //   (m) => m.id == medicineId,
      //   orElse: () => throw Exception('Medicine not found'),
      // );
      
      // Use default voice ID if not provided
      final effectiveVoiceId = voiceId ?? 'default';
      
      // Send voice reminder (this generates and plays audio)
      await _voiceReminderService.sendVoiceReminderFromModel(
        reminder: reminder,
        voiceId: effectiveVoiceId,
      );
      
      Logger.info('Voice reminder triggered successfully', tag: 'NotificationActionService');
    } catch (e, stackTrace) {
      Logger.error('Error triggering voice reminder: $e', tag: 'NotificationActionService', stackTrace: stackTrace);
    }
  }
}
