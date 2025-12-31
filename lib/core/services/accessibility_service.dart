import 'package:shared_preferences/shared_preferences.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for managing accessibility settings
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  // Keys for SharedPreferences
  static const String _keyLargeText = 'accessibility_large_text';
  static const String _keyHighContrast = 'accessibility_high_contrast';
  static const String _keySimplifiedMode = 'accessibility_simplified_mode';
  static const String _keyVoiceNavigation = 'accessibility_voice_navigation';
  static const String _keyHapticFeedback = 'accessibility_haptic_feedback';
  static const String _keyTextSize = 'accessibility_text_size';
  static const String _keyVoiceConfirmations = 'accessibility_voice_confirmations';

  bool? _largeTextEnabled;
  bool? _highContrastEnabled;
  bool? _simplifiedModeEnabled;
  bool? _voiceNavigationEnabled;
  bool? _hapticFeedbackEnabled;
  double? _textSizeMultiplier;
  bool? _voiceConfirmationsEnabled;

  /// Initialize and load settings
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _largeTextEnabled = prefs.getBool(_keyLargeText) ?? false;
      _highContrastEnabled = prefs.getBool(_keyHighContrast) ?? false;
      _simplifiedModeEnabled = prefs.getBool(_keySimplifiedMode) ?? false;
      _voiceNavigationEnabled = prefs.getBool(_keyVoiceNavigation) ?? false;
      _hapticFeedbackEnabled = prefs.getBool(_keyHapticFeedback) ?? true;
      _textSizeMultiplier = prefs.getDouble(_keyTextSize) ?? 1.0;
      _voiceConfirmationsEnabled = prefs.getBool(_keyVoiceConfirmations) ?? false;

      Logger.info('Accessibility settings loaded', tag: 'Accessibility');
    } catch (e) {
      Logger.error('Error loading accessibility settings: $e', tag: 'Accessibility');
    }
  }

  /// Check if large text mode is enabled
  bool isLargeTextEnabled() {
    return _largeTextEnabled ?? false;
  }

  /// Enable/disable large text mode
  Future<void> setLargeTextEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLargeText, enabled);
      _largeTextEnabled = enabled;
      Logger.info('Large text mode: $enabled', tag: 'Accessibility');
    } catch (e) {
      Logger.error('Error setting large text mode: $e', tag: 'Accessibility');
    }
  }

  /// Check if high contrast mode is enabled
  bool isHighContrastEnabled() {
    return _highContrastEnabled ?? false;
  }

  /// Enable/disable high contrast mode
  Future<void> setHighContrastEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHighContrast, enabled);
      _highContrastEnabled = enabled;
      Logger.info('High contrast mode: $enabled', tag: 'Accessibility');
    } catch (e) {
      Logger.error('Error setting high contrast mode: $e', tag: 'Accessibility');
    }
  }

  /// Check if simplified mode is enabled
  bool isSimplifiedModeEnabled() {
    return _simplifiedModeEnabled ?? false;
  }

  /// Enable/disable simplified mode
  Future<void> setSimplifiedModeEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keySimplifiedMode, enabled);
      _simplifiedModeEnabled = enabled;
      Logger.info('Simplified mode: $enabled', tag: 'Accessibility');
    } catch (e) {
      Logger.error('Error setting simplified mode: $e', tag: 'Accessibility');
    }
  }

  /// Check if voice navigation is enabled
  bool isVoiceNavigationEnabled() {
    return _voiceNavigationEnabled ?? false;
  }

  /// Enable/disable voice navigation
  Future<void> setVoiceNavigationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyVoiceNavigation, enabled);
      _voiceNavigationEnabled = enabled;
      Logger.info('Voice navigation: $enabled', tag: 'Accessibility');
    } catch (e) {
      Logger.error('Error setting voice navigation: $e', tag: 'Accessibility');
    }
  }

  /// Check if haptic feedback is enabled
  bool isHapticFeedbackEnabled() {
    return _hapticFeedbackEnabled ?? true; // Default to true
  }

  /// Enable/disable haptic feedback
  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHapticFeedback, enabled);
      _hapticFeedbackEnabled = enabled;
      Logger.info('Haptic feedback: $enabled', tag: 'Accessibility');
    } catch (e) {
      Logger.error('Error setting haptic feedback: $e', tag: 'Accessibility');
    }
  }

  /// Get text size multiplier (1.0 to 3.0)
  double getTextSizeMultiplier() {
    return _textSizeMultiplier ?? 1.0;
  }

  /// Set text size multiplier (1.0 to 3.0)
  Future<void> setTextSizeMultiplier(double multiplier) async {
    // Clamp between 1.0 and 3.0
    final clamped = multiplier.clamp(1.0, 3.0);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyTextSize, clamped);
      _textSizeMultiplier = clamped;
      Logger.info('Text size multiplier: $clamped', tag: 'Accessibility');
    } catch (e) {
      Logger.error('Error setting text size multiplier: $e', tag: 'Accessibility');
    }
  }

  /// Check if voice confirmations on actions are enabled
  bool isVoiceConfirmationsEnabled() {
    return _voiceConfirmationsEnabled ?? false;
  }

  /// Enable/disable voice confirmations on actions
  Future<void> setVoiceConfirmationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyVoiceConfirmations, enabled);
      _voiceConfirmationsEnabled = enabled;
      Logger.info('Voice confirmations: $enabled', tag: 'Accessibility');
    } catch (e) {
      Logger.error('Error setting voice confirmations: $e', tag: 'Accessibility');
    }
  }

  /// Get all accessibility settings as map
  Map<String, dynamic> getAllSettings() {
    return {
      'largeText': isLargeTextEnabled(),
      'highContrast': isHighContrastEnabled(),
      'simplifiedMode': isSimplifiedModeEnabled(),
      'voiceNavigation': isVoiceNavigationEnabled(),
      'hapticFeedback': isHapticFeedbackEnabled(),
      'textSizeMultiplier': getTextSizeMultiplier(),
      'voiceConfirmations': isVoiceConfirmationsEnabled(),
    };
  }
}
