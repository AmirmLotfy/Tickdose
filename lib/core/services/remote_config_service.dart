import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../utils/logger.dart';

/// Remote Configuration Service
/// Fetches API keys and configuration from Firebase Remote Config
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  
  RemoteConfigService._internal();
  
  late FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;
  
  /// Initialize Remote Config
  /// Call this in main.dart before running the app
  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // Set config settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1), // Cache for 1 hour
        ),
      );
      
      // Set default values (fallbacks)
      await _remoteConfig.setDefaults({
        'GEMINI_API_KEY': '',
        'ELEVENLABS_API_KEY': '',
      });
      
      // Fetch and activate
      await _remoteConfig.fetchAndActivate();
      
      _initialized = true;
      Logger.info('✓ Remote Config initialized successfully');
      Logger.info('  Gemini API Key: ${getGeminiApiKey().isEmpty ? "NOT SET" : "SET (${getGeminiApiKey().length} chars)"}');
      Logger.info('  ElevenLabs API Key: ${getElevenLabsApiKey().isEmpty ? "NOT SET" : "SET (${getElevenLabsApiKey().length} chars)"}');
      
    } catch (e) {
      Logger.error('Failed to initialize Remote Config: $e');
      _initialized = false;
      rethrow;
    }
  }
  
  /// Get Gemini API Key
  String getGeminiApiKey() {
    if (!_initialized) {
      Logger.warning('Remote Config not initialized, returning empty key');
      return '';
    }
    final key = _remoteConfig.getString('GEMINI_API_KEY');
    if (key.isNotEmpty && !_validateGeminiApiKey(key)) {
      Logger.warn('Gemini API key format appears invalid', tag: 'RemoteConfig');
    }
    return key;
  }
  
  /// Get ElevenLabs API Key
  String getElevenLabsApiKey() {
    if (!_initialized) {
      Logger.warning('Remote Config not initialized, returning empty key');
      return '';
    }
    final key = _remoteConfig.getString('ELEVENLABS_API_KEY');
    if (key.isNotEmpty && !_validateElevenLabsApiKey(key)) {
      Logger.warn('ElevenLabs API key format appears invalid', tag: 'RemoteConfig');
    }
    return key;
  }
  
  /// Validate Gemini API key format
  /// Gemini API keys typically start with "AIza" and are 39 characters long
  bool _validateGeminiApiKey(String key) {
    if (key.isEmpty) return false;
    // Basic format validation - Gemini keys typically start with "AIza"
    if (key.length < 30 || key.length > 100) {
      return false;
    }
    // Additional validation could check for specific patterns
    return true;
  }
  
  /// Validate ElevenLabs API key format
  /// ElevenLabs API keys are typically alphanumeric strings
  bool _validateElevenLabsApiKey(String key) {
    if (key.isEmpty) return false;
    // Basic format validation - ElevenLabs keys are typically 32+ characters
    if (key.length < 20 || key.length > 200) {
      return false;
    }
    // Additional validation could check for specific patterns
    return true;
  }
  
  /// Validate all API keys on startup
  /// Returns map of validation results
  Future<Map<String, bool>> validateApiKeys() async {
    final results = <String, bool>{};
    
    try {
      if (!_initialized) {
        await initialize();
      }
      
      final geminiKey = getGeminiApiKey();
      results['gemini'] = geminiKey.isNotEmpty && _validateGeminiApiKey(geminiKey);
      
      final elevenlabsKey = getElevenLabsApiKey();
      results['elevenlabs'] = elevenlabsKey.isNotEmpty && _validateElevenLabsApiKey(elevenlabsKey);
      
      Logger.info('API key validation results: $results', tag: 'RemoteConfig');
    } catch (e) {
      Logger.error('Failed to validate API keys: $e', tag: 'RemoteConfig');
      results['error'] = false;
    }
    
    return results;
  }
  
  /// Force refresh config (useful for testing)
  Future<void> forceRefresh() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero, // Force immediate fetch
        ),
      );
      
      await _remoteConfig.fetchAndActivate();
      Logger.info('Remote Config refreshed');
    } catch (e) {
      Logger.error('Failed to refresh Remote Config: $e');
    }
  }
  
  /// Get all config values (for debugging)
  Map<String, String> getAllConfig() {
    return {
      'GEMINI_API_KEY': getGeminiApiKey().isEmpty ? '(not set)' : '(set)',
      'ELEVENLABS_API_KEY': getElevenLabsApiKey().isEmpty ? '(not set)' : '(set)',
    };
  }
  
  /// Check if initialized
  bool get isInitialized => _initialized;
}
