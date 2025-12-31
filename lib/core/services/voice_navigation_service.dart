import 'dart:async';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tickdose/core/services/accessibility_service.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for voice-based navigation
class VoiceNavigationService {
  static final VoiceNavigationService _instance = VoiceNavigationService._internal();
  factory VoiceNavigationService() => _instance;
  VoiceNavigationService._internal();

  final AccessibilityService _accessibilityService = AccessibilityService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isListening = false;
  bool _ttsInitialized = false;

  /// Initialize speech recognition and TTS
  Future<bool> initialize() async {
    if (_isInitialized && _ttsInitialized) return true;

    try {
      // Initialize speech recognition
      final available = await _speech.initialize(
        onStatus: (status) {
          Logger.info('Voice navigation status: $status', tag: 'VoiceNavigation');
        },
        onError: (error) {
          Logger.error('Voice navigation error: ${error.errorMsg}', tag: 'VoiceNavigation');
        },
      );

      _isInitialized = available;

      // Initialize TTS
      await _tts.setLanguage("en");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ttsInitialized = true;

      return available && _ttsInitialized;
    } catch (e) {
      Logger.error('Error initializing voice navigation: $e', tag: 'VoiceNavigation');
      return false;
    }
  }

  /// Announce current screen name and options
  /// 
  /// [screenName] - Name of the current screen
  /// [options] - List of available options/actions
  Future<void> announceCurrentScreen({
    required String screenName,
    List<String>? options,
  }) async {
    if (!_accessibilityService.isVoiceNavigationEnabled()) {
      return;
    }

    try {
      if (!_ttsInitialized) {
        await initialize();
      }

      String announcement = 'You are on the $screenName screen';
      if (options != null && options.isNotEmpty) {
        announcement += '. Available options: ${options.join(", ")}';
      }

      await _tts.speak(announcement);
      Logger.info('Announcing screen: $screenName', tag: 'VoiceNavigation');
    } catch (e) {
      Logger.error('Error announcing screen: $e', tag: 'VoiceNavigation');
    }
  }

  /// Handle voice commands for navigation
  /// 
  /// Returns the command recognized (e.g., "go to medicines", "go to reminders")
  Future<String?> navigateByVoice() async {
    if (!_accessibilityService.isVoiceNavigationEnabled()) {
      return null;
    }

    if (_isListening) {
      Logger.warn('Already listening for voice navigation', tag: 'VoiceNavigation');
      return null;
    }

    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return null;
      }
    }

    final completer = Completer<String?>();

    try {
      _isListening = true;

      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            final text = result.recognizedWords.toLowerCase().trim();
            Logger.info('Voice navigation recognized: $text', tag: 'VoiceNavigation');
            
            _isListening = false;
            _speech.stop();
            completer.complete(text);
          }
        },
        listenFor: const Duration(seconds: 3),
        pauseFor: const Duration(seconds: 2),
      );

      // Timeout after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          _isListening = false;
          _speech.stop();
          completer.complete(null);
        }
      });

      return completer.future;
    } catch (e) {
      _isListening = false;
      Logger.error('Error in voice navigation: $e', tag: 'VoiceNavigation');
      return null;
    }
  }

  /// Parse voice command and return route name
  /// 
  /// [command] - Voice command text
  /// Returns route name or null
  String? parseVoiceCommand(String command) {
    final cmd = command.toLowerCase();

    // Navigation commands
    if (cmd.contains('medicine') || cmd.contains('medication')) {
      return '/medicines';
    }
    if (cmd.contains('reminder')) {
      return '/reminders';
    }
    if (cmd.contains('track') || cmd.contains('history')) {
      return '/tracking';
    }
    if (cmd.contains('pharmacy')) {
      return '/pharmacy';
    }
    if (cmd.contains('profile') || cmd.contains('settings')) {
      return '/profile';
    }
    if (cmd.contains('home') || cmd.contains('main')) {
      return '/home';
    }

    // Action commands
    if (cmd.contains('add') && cmd.contains('medicine')) {
      return '/medicines/add';
    }
    if (cmd.contains('add') && cmd.contains('reminder')) {
      return '/reminders/add';
    }

    return null;
  }

  /// Announce an action for confirmation
  /// 
  /// [action] - Action description
  Future<void> announceAction(String action) async {
    if (!_accessibilityService.isVoiceNavigationEnabled()) {
      return;
    }

    try {
      // Provide haptic feedback
      if (_accessibilityService.isHapticFeedbackEnabled()) {
        HapticFeedback.mediumImpact();
      }

      // Use Text-to-Speech to announce
      if (!_ttsInitialized) {
        await initialize();
      }

      await _tts.speak(action);
      Logger.info('Announcing action: $action', tag: 'VoiceNavigation');
    } catch (e) {
      Logger.error('Error announcing action: $e', tag: 'VoiceNavigation');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  /// Check if currently listening
  bool get isListening => _isListening;
}
