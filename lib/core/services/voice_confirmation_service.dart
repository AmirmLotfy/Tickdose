import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:tickdose/core/services/audio_service.dart'; // Unused import
import 'package:tickdose/core/services/voice_reminder_service.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/features/tracking/services/tracking_service.dart';
import 'package:uuid/uuid.dart';

/// Service for voice-based confirmation of medication intake
class VoiceConfirmationService {
  static final VoiceConfirmationService _instance = VoiceConfirmationService._internal();
  factory VoiceConfirmationService() => _instance;
  VoiceConfirmationService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final VoiceReminderService _voiceReminderService = VoiceReminderService();
  final TrackingService _trackingService = TrackingService();
  final _uuid = const Uuid();

  bool _isListening = false;
  bool _isInitialized = false;
  Timer? _listeningTimeout;
  
  // Stream controller for confirmation results
  final _confirmationController = StreamController<ConfirmationResult>.broadcast();
  Stream<ConfirmationResult> get confirmationResults => _confirmationController.stream;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          Logger.info('Speech recognition status: $status', tag: 'VoiceConfirmation');
        },
        onError: (error) {
          Logger.error('Speech recognition error: $error', tag: 'VoiceConfirmation');
          _confirmationController.add(ConfirmationResult.error(error.errorMsg));
        },
      );

      _isInitialized = available;
      return available;
    } catch (e) {
      Logger.error('Error initializing speech recognition: $e', tag: 'VoiceConfirmation');
      return false;
    }
  }

  /// Play reminder and wait for yes/no confirmation
  /// 
  /// [medicineName] - Name of the medicine
  /// [dosage] - Dosage amount
  /// [voiceId] - ElevenLabs voice ID
  /// [timeoutSeconds] - How long to wait for response (default 5 seconds)
  /// Returns ConfirmationResult with user's response
  Future<ConfirmationResult> playReminderAndWaitForConfirmation({
    required String medicineName,
    required String dosage,
    required String voiceId,
    int timeoutSeconds = 5,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return ConfirmationResult.error('Speech recognition not available');
      }
    }

    try {
      // Play the reminder voice
      await _voiceReminderService.sendVoiceReminder(
        medicineName: medicineName,
        dosage: dosage,
        voiceId: voiceId,
      );

      // Wait a moment for the voice to finish
      await Future.delayed(const Duration(seconds: 1));

      // Play confirmation question
      await _voiceReminderService.sendVoiceReminder(
        medicineName: medicineName,
        dosage: dosage,
        voiceId: voiceId,
        timeOfDay: TimeOfDay.now(),
      );

      // Wait for user response
      final result = await listenForConfirmation(timeoutSeconds: timeoutSeconds);
      
      return result;
    } catch (e) {
      Logger.error('Error in playReminderAndWaitForConfirmation: $e', tag: 'VoiceConfirmation');
      return ConfirmationResult.error(e.toString());
    }
  }

  /// Listen for yes/no confirmation
  /// 
  /// [timeoutSeconds] - Maximum time to wait for response
  /// Returns ConfirmationResult
  Future<ConfirmationResult> listenForConfirmation({
    int timeoutSeconds = 5,
  }) async {
    if (_isListening) {
      Logger.warn('Already listening for confirmation', tag: 'VoiceConfirmation');
      return ConfirmationResult.error('Already listening');
    }

    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return ConfirmationResult.error('Speech recognition not available');
      }
    }

    final completer = Completer<ConfirmationResult>();

    try {
      _isListening = true;
      
      // Start listening
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            final text = result.recognizedWords.toLowerCase().trim();
            Logger.info('Speech recognized: $text', tag: 'VoiceConfirmation');

            // Check for yes/no responses
            if (_isYesResponse(text)) {
              _isListening = false;
              _listeningTimeout?.cancel();
              _speech.stop();
              
              final confirmationResult = ConfirmationResult(
                response: ConfirmationResponse.yes,
                recognizedText: text,
                timestamp: DateTime.now(),
              );
              
              completer.complete(confirmationResult);
              _confirmationController.add(confirmationResult);
            } else if (_isNoResponse(text)) {
              _isListening = false;
              _listeningTimeout?.cancel();
              _speech.stop();
              
              final confirmationResult = ConfirmationResult(
                response: ConfirmationResponse.no,
                recognizedText: text,
                timestamp: DateTime.now(),
              );
              
              completer.complete(confirmationResult);
              _confirmationController.add(confirmationResult);
            }
          }
        },
        listenFor: Duration(seconds: timeoutSeconds),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US', // Can be made configurable
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
        ),
      );

      // Set timeout
      _listeningTimeout = Timer(Duration(seconds: timeoutSeconds), () {
        if (!completer.isCompleted) {
          _isListening = false;
          _speech.stop();
          
          final timeoutResult = ConfirmationResult(
            response: ConfirmationResponse.timeout,
            recognizedText: '',
            timestamp: DateTime.now(),
          );
          
          completer.complete(timeoutResult);
          _confirmationController.add(timeoutResult);
        }
      });

      return completer.future;
    } catch (e) {
      _isListening = false;
      _listeningTimeout?.cancel();
      Logger.error('Error listening for confirmation: $e', tag: 'VoiceConfirmation');
      // Fallback: return error result
      final errorResult = ConfirmationResult.error(e.toString());
      _confirmationController.add(errorResult);
      return errorResult;
    }
  }

  /// Check if text indicates "yes" response
  bool _isYesResponse(String text) {
    final yesPatterns = [
      'yes',
      'yeah',
      'yep',
      'yup',
      'sure',
      'ok',
      'okay',
      'taken',
      'did',
      'done',
      'already',
      'correct',
    ];

    return yesPatterns.any((pattern) => text.contains(pattern));
  }

  /// Check if text indicates "no" response
  bool _isNoResponse(String text) {
    final noPatterns = [
      'no',
      'nope',
      'nah',
      'not',
      'didn\'t',
      'did not',
      'haven\'t',
      'have not',
      'skip',
      'later',
    ];

    return noPatterns.any((pattern) => text.contains(pattern));
  }

  /// Handle timeout scenario
  Future<void> handleTimeout() async {
    _isListening = false;
    _listeningTimeout?.cancel();
    await _speech.stop();
    
    _confirmationController.add(
      ConfirmationResult(
        response: ConfirmationResponse.timeout,
        recognizedText: '',
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Log confirmation response to medicine log
  /// 
  /// This should be called by the caller after getting confirmation
  Future<void> logConfirmationResponse({
    required String userId,
    required String medicineId,
    required String medicineName,
    required ConfirmationResult result,
    String? dosage,
  }) async {
    try {
      // Create medicine log entry
      final logStatus = result.response == ConfirmationResponse.yes
          ? 'taken'
          : result.response == ConfirmationResponse.no
              ? 'skipped'
              : 'missed';

      // Create MedicineLogModel instance
      final log = MedicineLogModel(
        id: _uuid.v4(),
        userId: userId,
        medicineId: medicineId,
        medicineName: medicineName,
        takenAt: result.timestamp,
        status: logStatus,
        notes: 'Voice confirmation: ${result.recognizedText.isNotEmpty ? result.recognizedText : result.response.name}',
      );

      // Save to Firestore via TrackingService
      await _trackingService.logMedicine(log);
      
      Logger.info(
        'Voice confirmation logged to Firestore: $medicineName - $logStatus',
        tag: 'VoiceConfirmation',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Error logging confirmation response: $e',
        tag: 'VoiceConfirmation',
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
    _listeningTimeout?.cancel();
    await _speech.stop();
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Dispose resources
  void dispose() {
    _speech.stop();
    _listeningTimeout?.cancel();
    _confirmationController.close();
  }
}

/// Result of voice confirmation
class ConfirmationResult {
  final ConfirmationResponse response;
  final String recognizedText;
  final DateTime timestamp;
  final String? error;

  ConfirmationResult({
    required this.response,
    required this.recognizedText,
    required this.timestamp,
    this.error,
  });

  factory ConfirmationResult.error(String error) {
    return ConfirmationResult(
      response: ConfirmationResponse.error,
      recognizedText: '',
      timestamp: DateTime.now(),
      error: error,
    );
  }

  bool get isSuccess => response == ConfirmationResponse.yes || response == ConfirmationResponse.no;
  bool get isError => response == ConfirmationResponse.error || response == ConfirmationResponse.timeout;
}

/// Possible confirmation responses
enum ConfirmationResponse {
  yes,
  no,
  timeout,
  error,
}
