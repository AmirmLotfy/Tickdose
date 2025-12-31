import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

/// Speech Recognition Service
/// Handles voice input and speech-to-text conversion
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  
  SpeechService._internal();
  
  late stt.SpeechToText _speech;
  bool _initialized = false;
  bool _isListening = false;
  String _lastRecognizedText = '';
  
  /// Initialize speech recognition
  Future<bool> initialize() async {
    try {
      _speech = stt.SpeechToText();
      final available = await _speech.initialize(
        onStatus: (status) {
          Logger.info('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (error) {
          Logger.error('Speech error: ${error.errorMsg}');
          _isListening = false;
        },
      );
      
      _initialized = available;
      
      if (available) {
        Logger.info('Speech recognition initialized successfully');
      } else {
        Logger.warning('Speech recognition not available on this device');
      }
      
      return available;
    } catch (e) {
      Logger.error('Failed to initialize speech recognition: $e');
      _initialized = false;
      return false;
    }
  }
  
  /// Check if speech recognition is available
  bool get isAvailable => _initialized && _speech.isAvailable;
  
  /// Check if currently listening
  bool get isListening => _isListening;
  
  /// Get last recognized text
  String get lastRecognizedText => _lastRecognizedText;
  
  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      
      if (status.isGranted) {
        Logger.info('Microphone permission granted');
        return true;
      } else if (status.isPermanentlyDenied) {
        Logger.warning('Microphone permission permanently denied');
        return false;
      } else {
        Logger.warning('Microphone permission denied');
        return false;
      }
    } catch (e) {
      Logger.error('Error requesting microphone permission: $e');
      return false;
    }
  }
  
  /// Check microphone permission status
  Future<bool> checkMicrophonePermission() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      Logger.error('Error checking microphone permission: $e');
      return false;
    }
  }
  
  /// Start listening for voice input
  /// 
  /// [onResult] - Callback function to receive recognized text
  /// [language] - Language locale (default: 'en-US')
  /// [partialResults] - Whether to return partial results (default: true)
  Future<void> startListening({
    required Function(String) onResult,
    String language = 'en-US',
    bool partialResults = true,
  }) async {
    try {
      if (!_initialized) {
        final success = await initialize();
        if (!success) {
          throw Exception('Speech recognition not available');
        }
      }
      
      // Check permission
      final hasPermission = await checkMicrophonePermission();
      if (!hasPermission) {
        final granted = await requestMicrophonePermission();
        if (!granted) {
          throw Exception('Microphone permission not granted');
        }
      }
      
      if (!_speech.isAvailable) {
        throw Exception('Speech recognition not available');
      }
      
      if (_isListening) {
        Logger.warning('Already listening, stopping previous session');
        await stopListening();
      }
      
      _isListening = true;
      _lastRecognizedText = '';
      
      await _speech.listen(
        onResult: (result) {
          _lastRecognizedText = result.recognizedWords;
          Logger.info('Recognized text: ${result.recognizedWords}');
          onResult(result.recognizedWords);
        },
        localeId: language,
        listenOptions: stt.SpeechListenOptions(
          partialResults: partialResults,
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: false,
        ),
      );
      
      Logger.info('Started listening for speech (language: $language)');
    } catch (e) {
      Logger.error('Error starting speech recognition: $e');
      _isListening = false;
      rethrow;
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        await _speech.stop();
        _isListening = false;
        Logger.info('Stopped listening for speech');
      }
    } catch (e) {
      Logger.error('Error stopping speech recognition: $e');
      _isListening = false;
    }
  }
  
  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      if (_isListening) {
        await _speech.cancel();
        _isListening = false;
        _lastRecognizedText = '';
        Logger.info('Cancelled speech recognition');
      }
    } catch (e) {
      Logger.error('Error cancelling speech recognition: $e');
      _isListening = false;
    }
  }
  
  /// Get list of available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    try {
      if (!_initialized) {
        await initialize();
      }
      
      final locales = await _speech.locales();
      Logger.info('Available locales: ${locales.length}');
      return locales;
    } catch (e) {
      Logger.error('Error getting available locales: $e');
      return [];
    }
  }
  
  /// Check if a specific locale is supported
  Future<bool> isLocaleSupported(String localeId) async {
    try {
      final locales = await getAvailableLocales();
      return locales.any((locale) => locale.localeId == localeId);
    } catch (e) {
      Logger.error('Error checking locale support: $e');
      return false;
    }
  }
  
  /// Get system locale
  Future<String?> getSystemLocale() async {
    try {
      if (!_initialized) {
        await initialize();
      }
      
      final locale = await _speech.systemLocale();
      return locale?.localeId;
    } catch (e) {
      Logger.error('Error getting system locale: $e');
      return null;
    }
  }
}
