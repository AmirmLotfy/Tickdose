import 'dart:io';
import 'package:tickdose/core/services/storage_service.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for managing personal voice recordings
class PersonalVoiceService {
  static final PersonalVoiceService _instance = PersonalVoiceService._internal();
  factory PersonalVoiceService() => _instance;
  PersonalVoiceService._internal();

  final StorageService _storageService = StorageService();

  /// Record personal voice (15-30 seconds)
  /// 
  /// [audioFile] - Recorded audio file
  /// [userId] - User ID
  /// [name] - Name for the voice (e.g., "Mom's voice")
  /// Returns download URL of uploaded voice
  Future<String> recordPersonalVoice({
    required File audioFile,
    required String userId,
    required String name,
  }) async {
    try {
      // Upload to Firebase Storage
      final path = 'personal_voices/$userId/${DateTime.now().millisecondsSinceEpoch}.m4a';
      final downloadUrl = await _storageService.uploadFile(audioFile, path);

      if (downloadUrl == null) {
        throw Exception('Failed to upload voice recording');
      }

      // TODO: Store metadata in Firestore (voice URL, name, userId)
      // await _storeVoiceMetadata(userId, name, downloadUrl);

      Logger.info('Personal voice recorded and uploaded: $name', tag: 'PersonalVoice');
      return downloadUrl;
    } catch (e) {
      Logger.error('Error recording personal voice: $e', tag: 'PersonalVoice');
      rethrow;
    }
  }

  /// Upload voice to Firebase Storage
  Future<String> uploadVoiceToFirebase({
    required File audioFile,
    required String userId,
  }) async {
    try {
      final path = 'personal_voices/$userId/${DateTime.now().millisecondsSinceEpoch}.m4a';
      final downloadUrl = await _storageService.uploadFile(audioFile, path);

      if (downloadUrl == null) {
        throw Exception('Failed to upload voice');
      }

      return downloadUrl;
    } catch (e) {
      Logger.error('Error uploading voice to Firebase: $e', tag: 'PersonalVoice');
      rethrow;
    }
  }

  /// Generate voice from recording (using ElevenLabs cloning API if available)
  /// 
  /// Note: This would require ElevenLabs voice cloning API
  /// For now, we just store the recording URL for playback
  Future<String?> generateVoiceFromRecording({
    required String recordingUrl,
    required String voiceName,
  }) async {
    try {
      // TODO: If ElevenLabs voice cloning API is available, use it here
      // For now, return the recording URL for direct playback
      Logger.info('Using recorded voice for playback: $voiceName', tag: 'PersonalVoice');
      return recordingUrl;
    } catch (e) {
      Logger.error('Error generating voice from recording: $e', tag: 'PersonalVoice');
      return null;
    }
  }

  /// Set personal voice as default for reminders
  /// 
  /// [userId] - User ID
  /// [voiceUrl] - URL of the personal voice
  Future<void> setPersonalVoiceAsDefault({
    required String userId,
    required String voiceUrl,
  }) async {
    try {
      // TODO: Store in user profile or preferences
      // await _updateUserVoicePreference(userId, voiceUrl);
      Logger.info('Personal voice set as default for user: $userId', tag: 'PersonalVoice');
    } catch (e) {
      Logger.error('Error setting personal voice as default: $e', tag: 'PersonalVoice');
      rethrow;
    }
  }
}
