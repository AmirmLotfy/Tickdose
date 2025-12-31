import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voice_model.dart';
import '../services/elevenlabs_service.dart';
import '../utils/logger.dart';

/// Voice Settings State
class VoiceSettings {
  final String selectedVoiceId;
  final String selectedVoiceName;
  final double speed;
  final double volume;
  final String language;
  final bool useVoiceReminders;
  final bool useVoiceCongratulations;
  final List<VoiceModel> availableVoices;
  
  // NEW: Advanced Controls
  final String selectedModel;
  final double clarity;
  final double styleExaggeration;
  final bool speakerBoost;
  final bool useStreaming;
  
  // NEW: Multilingual Support
  final String languageCode;
  final String voiceStylePreference;
  final bool autoDetectLanguage;
  
  // NEW: Voice confirmation and mode
  final bool? useVoiceConfirmations;
  final String? voiceMode; // 'strict' or 'gentle'
  
  const VoiceSettings({
    this.selectedVoiceId = '',
    this.selectedVoiceName = 'Default',
    this.speed = 1.0,
    this.volume = 1.0,
    this.language = 'en-US',
    this.useVoiceReminders = false, // DEFAULT OFF (opt-in) to save costs
    this.useVoiceCongratulations = true,
    this.availableVoices = const [],
    this.selectedModel = 'eleven_flash_v2_5',
    this.clarity = 0.75,
    this.styleExaggeration = 0.0,
    this.speakerBoost = true,
    this.useStreaming = true,
    this.languageCode = 'en',
    this.voiceStylePreference = 'friendly',
    this.autoDetectLanguage = false,
    this.useVoiceConfirmations = true,
    this.voiceMode = 'gentle',
  });
  
  VoiceSettings copyWith({
    String? selectedVoiceId,
    String? selectedVoiceName,
    double? speed,
    double? volume,
    String? language,
    bool? useVoiceReminders,
    bool? useVoiceCongratulations,
    List<VoiceModel>? availableVoices,
    String? selectedModel,
    double? clarity,
    double? styleExaggeration,
    bool? speakerBoost,
    bool? useStreaming,
    String? languageCode,
    String? voiceStylePreference,
    bool? autoDetectLanguage,
    bool? useVoiceConfirmations,
    String? voiceMode,
  }) {
    return VoiceSettings(
      selectedVoiceId: selectedVoiceId ?? this.selectedVoiceId,
      selectedVoiceName: selectedVoiceName ?? this.selectedVoiceName,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      language: language ?? this.language,
      useVoiceReminders: useVoiceReminders ?? this.useVoiceReminders,
      useVoiceCongratulations: useVoiceCongratulations ?? this.useVoiceCongratulations,
      availableVoices: availableVoices ?? this.availableVoices,
      selectedModel: selectedModel ?? this.selectedModel,
      clarity: clarity ?? this.clarity,
      styleExaggeration: styleExaggeration ?? this.styleExaggeration,
      speakerBoost: speakerBoost ?? this.speakerBoost,
      useStreaming: useStreaming ?? this.useStreaming,
      languageCode: languageCode ?? this.languageCode,
      voiceStylePreference: voiceStylePreference ?? this.voiceStylePreference,
      autoDetectLanguage: autoDetectLanguage ?? this.autoDetectLanguage,
      useVoiceConfirmations: useVoiceConfirmations ?? this.useVoiceConfirmations,
      voiceMode: voiceMode ?? this.voiceMode,
    );
  }
  
  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'selectedVoiceId': selectedVoiceId,
      'selectedVoiceName': selectedVoiceName,
      'speed': speed,
      'volume': volume,
      'language': language,
      'useVoiceReminders': useVoiceReminders,
      'useVoiceCongratulations': useVoiceCongratulations,
      'useVoiceConfirmations': useVoiceConfirmations,
      'voiceMode': voiceMode,
      'selectedModel': selectedModel,
      'clarity': clarity,
      'styleExaggeration': styleExaggeration,
      'speakerBoost': speakerBoost,
      'useStreaming': useStreaming,
      'languageCode': languageCode,
      'voiceStylePreference': voiceStylePreference,
      'autoDetectLanguage': autoDetectLanguage,
    };
  }
  
  /// Create from map
  factory VoiceSettings.fromMap(Map<String, dynamic> map) {
    return VoiceSettings(
      selectedVoiceId: map['selectedVoiceId'] as String? ?? '',
      selectedVoiceName: map['selectedVoiceName'] as String? ?? 'Default',
      speed: (map['speed'] as num?)?.toDouble() ?? 1.0,
      volume: (map['volume'] as num?)?.toDouble() ?? 1.0,
      language: map['language'] as String? ?? 'en-US',
      useVoiceReminders: map['useVoiceReminders'] as bool? ?? false, // Default OFF (opt-in)
      useVoiceCongratulations: map['useVoiceCongratulations'] as bool? ?? true,
      selectedModel: map['selectedModel'] as String? ?? 'eleven_flash_v2_5',
      clarity: (map['clarity'] as num?)?.toDouble() ?? 0.75,
      styleExaggeration: (map['styleExaggeration'] as num?)?.toDouble() ?? 0.0,
      speakerBoost: map['speakerBoost'] as bool? ?? true,
      useStreaming: map['useStreaming'] as bool? ?? true,
      languageCode: map['languageCode'] as String? ?? 'en',
      voiceStylePreference: map['voiceStylePreference'] as String? ?? 'friendly',
      autoDetectLanguage: map['autoDetectLanguage'] as bool? ?? false,
      useVoiceConfirmations: map['useVoiceConfirmations'] as bool? ?? true,
      voiceMode: map['voiceMode'] as String? ?? 'gentle',
    );
  }
}

/// Voice Settings Provider
final voiceSettingsProvider = NotifierProvider<VoiceSettingsNotifier, VoiceSettings>(VoiceSettingsNotifier.new);

/// Voice Settings Notifier
class VoiceSettingsNotifier extends Notifier<VoiceSettings> {
  @override
  VoiceSettings build() {
    _loadSettings();
    _loadVoices();
    return const VoiceSettings();
  }
  
  final ElevenLabsService _elevenLabs = ElevenLabsService();
  
  /// Load settings from persistent storage (tries Firestore first, falls back to SharedPreferences)
  Future<void> _loadSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // Try loading from Firestore first (for cross-device sync)
      if (user != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final voiceSettingsMap = userData['voiceSettings'] as Map<String, dynamic>?;
            
            if (voiceSettingsMap != null) {
              // Load from Firestore
              state = VoiceSettings.fromMap(voiceSettingsMap);
              // Also save to SharedPreferences for offline access
              await _saveToSharedPreferences();
              Logger.info('Voice settings loaded from Firestore', tag: 'VoiceSettings');
              return;
            }
          }
        } catch (e) {
          Logger.warn('Failed to load from Firestore, using SharedPreferences: $e', tag: 'VoiceSettings');
        }
      }
      
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      final selectedVoiceId = prefs.getString('voice_id') ?? '';
      final selectedVoiceName = prefs.getString('voice_name') ?? 'Default';
      final speed = prefs.getDouble('voice_speed') ?? 1.0;
      final volume = prefs.getDouble('voice_volume') ?? 1.0;
      final language = prefs.getString('voice_language') ?? 'en-US';
      final useVoiceReminders = prefs.getBool('use_voice_reminders') ?? false; // Default OFF (opt-in)
      final useVoiceCongratulations = prefs.getBool('use_voice_congratulations') ?? true;
      final useVoiceConfirmations = prefs.getBool('use_voice_confirmations') ?? true;
      final voiceMode = prefs.getString('voice_mode') ?? 'gentle';
      
      // Load advanced settings
      final selectedModel = prefs.getString('voice_model') ?? 'eleven_flash_v2_5';
      final clarity = prefs.getDouble('voice_clarity') ?? 0.75;
      final styleExaggeration = prefs.getDouble('voice_style_exaggeration') ?? 0.0;
      final speakerBoost = prefs.getBool('voice_speaker_boost') ?? true;
      final useStreaming = prefs.getBool('voice_streaming') ?? true;
      final languageCode = prefs.getString('voice_language_code') ?? 'en';
      final voiceStylePreference = prefs.getString('voice_style_preference') ?? 'friendly';
      final autoDetectLanguage = prefs.getBool('voice_auto_detect') ?? false;
      
      state = state.copyWith(
        selectedVoiceId: selectedVoiceId,
        selectedVoiceName: selectedVoiceName,
        speed: speed,
        volume: volume,
        language: language,
        useVoiceReminders: useVoiceReminders,
        useVoiceCongratulations: useVoiceCongratulations,
        useVoiceConfirmations: useVoiceConfirmations,
        voiceMode: voiceMode,
        selectedModel: selectedModel,
        clarity: clarity,
        styleExaggeration: styleExaggeration,
        speakerBoost: speakerBoost,
        useStreaming: useStreaming,
        languageCode: languageCode,
        voiceStylePreference: voiceStylePreference,
        autoDetectLanguage: autoDetectLanguage,
      );
      
      Logger.info('Voice settings loaded from SharedPreferences', tag: 'VoiceSettings');
    } catch (e) {
      Logger.error('Failed to load voice settings: $e');
    }
  }
  
  /// Helper: Save current state to SharedPreferences (used after loading from Firestore)
  Future<void> _saveToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('voice_id', state.selectedVoiceId);
      await prefs.setString('voice_name', state.selectedVoiceName);
      await prefs.setDouble('voice_speed', state.speed);
      await prefs.setDouble('voice_volume', state.volume);
      await prefs.setString('voice_language', state.language);
      await prefs.setBool('use_voice_reminders', state.useVoiceReminders);
      await prefs.setBool('use_voice_congratulations', state.useVoiceCongratulations);
      await prefs.setBool('use_voice_confirmations', state.useVoiceConfirmations ?? true);
      await prefs.setString('voice_mode', state.voiceMode ?? 'gentle');
      await prefs.setString('voice_model', state.selectedModel);
      await prefs.setDouble('voice_clarity', state.clarity);
      await prefs.setDouble('voice_style_exaggeration', state.styleExaggeration);
      await prefs.setBool('voice_speaker_boost', state.speakerBoost);
      await prefs.setBool('voice_streaming', state.useStreaming);
      await prefs.setString('voice_language_code', state.languageCode);
      await prefs.setString('voice_style_preference', state.voiceStylePreference);
      await prefs.setBool('voice_auto_detect', state.autoDetectLanguage);
    } catch (e) {
      Logger.error('Failed to save to SharedPreferences: $e', tag: 'VoiceSettings');
    }
  }
  
  /// Load available voices from ElevenLabs
  Future<void> _loadVoices() async {
    try {
      await _elevenLabs.initialize();
      final voices = await _elevenLabs.getAvailableVoices();
      
      state = state.copyWith(availableVoices: voices);
      
      // If no voice selected, select first available
      if (state.selectedVoiceId.isEmpty && voices.isNotEmpty) {
        updateVoice(voices.first.id, voices.first.name);
      }
      
      Logger.info('Loaded ${voices.length} available voices');
    } catch (e) {
      Logger.error('Failed to load voices: $e');
    }
  }
  
  /// Update selected voice
  Future<void> updateVoice(String voiceId, String voiceName) async {
    state = state.copyWith(
      selectedVoiceId: voiceId,
      selectedVoiceName: voiceName,
    );
    await _saveSettings();
  }
  
  /// Update voice speed
  Future<void> updateSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    await _saveSettings();
  }
  
  /// Update voice volume
  Future<void> updateVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _saveSettings();
  }
  
  /// Update language
  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _saveSettings();
  }
  
  /// Toggle voice reminders
  Future<void> toggleVoiceReminders(bool enabled) async {
    state = state.copyWith(useVoiceReminders: enabled);
    await _saveSettings();
  }
  
  /// Toggle voice congratulations
  Future<void> toggleVoiceCongratulations(bool enabled) async {
    state = state.copyWith(useVoiceCongratulations: enabled);
    await _saveSettings();
  }
  
  /// Update selected model
  Future<void> updateModel(String modelId) async {
    state = state.copyWith(selectedModel: modelId);
    await _saveSettings();
  }
  
  /// Update voice clarity
  Future<void> updateClarity(double clarity) async {
    state = state.copyWith(clarity: clarity);
    await _saveSettings();
  }
  
  /// Update style exaggeration (emotional intensity)
  Future<void> updateStyleExaggeration(double style) async {
    state = state.copyWith(styleExaggeration: style);
    await _saveSettings();
  }
  
  /// Toggle speaker boost
  Future<void> toggleSpeakerBoost(bool enabled) async {
    state = state.copyWith(speakerBoost: enabled);
    await _saveSettings();
  }
  
  /// Toggle streaming mode
  Future<void> toggleStreaming(bool enabled) async {
    state = state.copyWith(useStreaming: enabled);
    await _saveSettings();
  }
  
  /// Update language code
  Future<void> updateLanguageCode(String code) async {
    state = state.copyWith(languageCode: code);
    await _saveSettings();
  }
  
  /// Update voice style preference
  Future<void> updateVoiceStyle(String style) async {
    state = state.copyWith(voiceStylePreference: style);
    await _saveSettings();
  }
  
  /// Toggle auto-detect language
  Future<void> toggleAutoDetect(bool enabled) async {
    state = state.copyWith(autoDetectLanguage: enabled);
    await _saveSettings();
  }
  
  /// Toggle voice confirmations
  Future<void> toggleVoiceConfirmations(bool enabled) async {
    state = state.copyWith(useVoiceConfirmations: enabled);
    await _saveSettings();
  }
  
  /// Update voice mode (strict or gentle)
  Future<void> updateVoiceMode(String mode) async {
    state = state.copyWith(voiceMode: mode);
    await _saveSettings();
  }
  
  /// Reset to defaults
  Future<void> resetToDefaults() async {
    state = const VoiceSettings();
    await _saveSettings();
    await _loadVoices(); // Reload to set first voice as default
  }
  
  /// Refresh voices list
  Future<void> refreshVoices() async {
    try {
      final voices = await _elevenLabs.getAvailableVoices(forceRefresh: true);
      state = state.copyWith(availableVoices: voices);
      Logger.info('Refreshed voice list');
    } catch (e) {
      Logger.error('Failed to refresh voices: $e');
    }
  }
  
  /// Save settings to persistent storage (SharedPreferences + Firestore)
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save to SharedPreferences (local storage)
      await prefs.setString('voice_id', state.selectedVoiceId);
      await prefs.setString('voice_name', state.selectedVoiceName);
      await prefs.setDouble('voice_speed', state.speed);
      await prefs.setDouble('voice_volume', state.volume);
      await prefs.setString('voice_language', state.language);
      await prefs.setBool('use_voice_reminders', state.useVoiceReminders);
      await prefs.setBool('use_voice_congratulations', state.useVoiceCongratulations);
      await prefs.setBool('use_voice_confirmations', state.useVoiceConfirmations ?? true);
      await prefs.setString('voice_mode', state.voiceMode ?? 'gentle');
      
      // Save advanced settings
      await prefs.setString('voice_model', state.selectedModel);
      await prefs.setDouble('voice_clarity', state.clarity);
      await prefs.setDouble('voice_style_exaggeration', state.styleExaggeration);
      await prefs.setBool('voice_speaker_boost', state.speakerBoost);
      await prefs.setBool('voice_streaming', state.useStreaming);
      await prefs.setString('voice_language_code', state.languageCode);
      await prefs.setString('voice_style_preference', state.voiceStylePreference);
      await prefs.setBool('voice_auto_detect', state.autoDetectLanguage);
      
      // Sync to Firestore (for notification service and cross-device sync)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'voiceSettings': state.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          Logger.info('Voice settings synced to Firestore', tag: 'VoiceSettings');
        } catch (e) {
          Logger.warn('Failed to sync voice settings to Firestore: $e', tag: 'VoiceSettings');
          // Continue - local storage is still saved
        }
      }
      
      Logger.info('Voice settings saved');
    } catch (e) {
      Logger.error('Failed to save voice settings: $e');
    }
  }
}

