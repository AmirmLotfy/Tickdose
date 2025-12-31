import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/voice_model.dart';
import '../utils/logger.dart';
import 'remote_config_service.dart';
import 'api_rate_limiter.dart';
import 'elevenlabs_streaming_service.dart';
import 'api_error.dart';
import 'api_analytics_service.dart';

/// ElevenLabs Voice Models
enum ElevenLabsModel {
  flash('eleven_flash_v2_5', 'Flash v2.5 (Fastest)', 'Ultra-low latency ~75ms, real-time'),
  multilingual('eleven_multilingual_v3', 'Multilingual v3 (High Quality)', 'High fidelity, 70+ languages, emotional tags'),
  turbo('eleven_turbo_v2_5', 'Turbo v2.5', 'Balanced speed and quality');

  const ElevenLabsModel(this.id, this.displayName, this.description);
  final String id;
  final String displayName;
  final String description;
}


/// ElevenLabs Text-to-Speech Service
/// Handles all voice generation and playback using ElevenLabs API
class ElevenLabsService {
  static final ElevenLabsService _instance = ElevenLabsService._internal();
  factory ElevenLabsService() => _instance;
  
  ElevenLabsService._internal();
  
  // API Configuration
  final String baseUrl = 'https://api.elevenlabs.io/v1';
  
  late String _apiKey;
  bool _initialized = false;
  
  // Audio player
  late AudioPlayer _audioPlayer;
  
  // HTTP client with connection pooling (reused across requests)
  final http.Client _httpClient = http.Client();
  
  // Available voices cache
  List<VoiceModel> _cachedVoices = [];
  DateTime? _cacheTime;
  static const Duration cacheValidDuration = Duration(hours: 24);
  
  // Voice file cache (text -> audio file path)
  final Map<String, String> _voiceCache = {};
  static const int maxCacheSize = 100; // Maximum cached audio files
  
  // Rate limiter
  final ApiRateLimiter _rateLimiter = ApiRateLimiter();
  final ApiAnalyticsService _analytics = ApiAnalyticsService();
  
  // Retry configuration
  static const _maxRetries = 3;
  static const _baseRetryDelay = Duration(seconds: 1);
  
  /// Get API key (for streaming service)
  String get apiKey => _apiKey;
  
  /// Initialize service with API key from environment
  Future<void> initialize() async {
    try {
      // Priority 1: .env file (for local development)
      try {
        final envFileKey = dotenv.env['ELEVENLABS_API_KEY'] ?? '';
        if (envFileKey.isNotEmpty) {
          _apiKey = envFileKey;
          Logger.info('Using ElevenLabs API key from .env file', tag: 'ElevenLabs');
          _initialized = true;
          _audioPlayer = AudioPlayer();
          return;
        }
      } catch (e) {
        Logger.warn('Could not read from .env file: $e', tag: 'ElevenLabs');
      }
      
      // Priority 2: Environment variable (for development/CI)
      const envKey = String.fromEnvironment('ELEVENLABS_API_KEY');
      
      if (envKey.isNotEmpty) {
        _apiKey = envKey;
        Logger.info('Using ElevenLabs API key from environment variable', tag: 'ElevenLabs');
      } else {
        // Priority 3: Remote Config (for production)
        final config = RemoteConfigService();
        _apiKey = config.getElevenLabsApiKey();
        
        if (_apiKey.isNotEmpty) {
          Logger.info('Using ElevenLabs API key from Remote Config', tag: 'ElevenLabs');
        } else {
          // Priority 4: Hardcoded fallback (new key)
          // Priority 4: Hardcoded fallback (removed for security)
          _apiKey = '';
          Logger.warn('No ElevenLabs API key found in .env, environment, or Remote Config', tag: 'ElevenLabs');
        }
      }
      
      // Validate API key format
      if (_apiKey.isNotEmpty) {
        if (_apiKey.length < 20 || _apiKey.length > 200) {
          Logger.warn('ElevenLabs API key format appears invalid (length: ${_apiKey.length})', tag: 'ElevenLabs');
        }
      } else {
        Logger.warn('ElevenLabs API key is empty - voice features will not work', tag: 'ElevenLabs');
      }
      
      _initialized = true;
      _audioPlayer = AudioPlayer();
      
      // Configure AudioPlayer for background playback
      // Note: AudioPlayer from just_audio supports background playback by default
      // Android requires FOREGROUND_SERVICE permission in AndroidManifest
      // iOS requires UIBackgroundModes with 'audio' in Info.plist
      
      Logger.info('ElevenLabs service initialized successfully', tag: 'ElevenLabs');
    } catch (e) {
      Logger.error('Failed to initialize ElevenLabs service: $e', tag: 'ElevenLabs');
      rethrow;
    }
  }
  
  /// Check if service is initialized
  bool get isInitialized => _initialized;
  
  /// Get list of available voices from ElevenLabs API
  Future<List<VoiceModel>> getAvailableVoices({bool forceRefresh = false}) async {
    try {
      _ensureInitialized();
      
      // If API key is empty, return empty list silently (voice features are optional)
      if (_apiKey.isEmpty) {
        Logger.info('ElevenLabs API key not configured - voice features disabled', tag: 'ElevenLabs');
        return [];
      }
      
      // Return cached voices if available and valid
      if (!forceRefresh && _cachedVoices.isNotEmpty && _cacheTime != null) {
        if (DateTime.now().difference(_cacheTime!) < cacheValidDuration) {
          Logger.info('Returning cached voices (${_cachedVoices.length} voices)');
          return _cachedVoices;
        }
      }
      
      // Check rate limit (for API calls, not for fetching voices list which is less frequent)
      // Note: Voice list fetching is less critical, so we don't enforce strict limits
      // But we still track it
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _rateLimiter.recordApiCall(user.uid, 'elevenlabs');
      }

      // Fetch voices from API (using persistent HTTP client for connection pooling)
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/voices'),
        headers: {
          'xi-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final voicesList = data['voices'] as List;
        
        _cachedVoices = voicesList
            .map((v) => VoiceModel.fromJson(v))
            .toList();
        _cacheTime = DateTime.now();
        
        Logger.info('Fetched ${_cachedVoices.length} voices from ElevenLabs');
        return _cachedVoices;
      } else if (response.statusCode == 401) {
        Logger.warn('ElevenLabs authentication failed when fetching voices - API key may be invalid', tag: 'ElevenLabs');
        // Return empty list instead of throwing error - voice features are optional
        return [];
      } else if (response.statusCode >= 500) {
        Logger.error('ElevenLabs server error when fetching voices: ${response.statusCode}', tag: 'ElevenLabs');
        // Return empty list on server errors - voice features are optional
        return [];
      } else {
        Logger.warn('Failed to fetch voices: ${response.statusCode} - returning empty list', tag: 'ElevenLabs');
        // Return empty list instead of throwing error
        return [];
      }
    } catch (e) {
      Logger.warn('Error fetching voices: $e - voice features will be disabled', tag: 'ElevenLabs');
      // Return empty list instead of throwing error - voice features are optional
      return [];
    }
  }
  
  /// Generate cache key for text + voice settings
  /// Note: clarity parameter removed - ElevenLabs API doesn't support it directly
  /// Voice clarity is controlled via stability and similarity_boost parameters
  String _generateCacheKey(String text, String voiceId, ElevenLabsModel model, double stability, double similarityBoost, double styleExaggeration, bool speakerBoost) {
    return '${text}_${voiceId}_${model.id}_${stability}_${similarityBoost}_${styleExaggeration}_$speakerBoost';
  }
  
  /// Convert text to speech and return audio file path
  /// 
  /// [text] - Text to convert to speech
  /// [voiceId] - ElevenLabs voice ID to use
  /// [model] - Voice model to use (default: Flash v2.5 for speed)
  /// [stability] - Voice stability (0.0 - 1.0, default: 0.5). Higher = more consistent, lower = more variable
  /// [similarityBoost] - Similarity boost (0.0 - 1.0, default: 0.75). Higher = closer to original voice
  /// [styleExaggeration] - Emotional intensity (0.0 - 1.0, default: 0.0) - Controls emotional expression
  /// [speakerBoost] - Enhanced voice presence (default: true) - Improves clarity and presence
  /// [useCache] - Whether to use cached audio if available (default: true)
  /// 
  /// Note: The 'clarity' parameter has been removed as ElevenLabs API doesn't support it directly.
  /// Voice clarity is achieved through the combination of stability and similarity_boost parameters.
  Future<String> textToSpeech({
    required String text,
    required String voiceId,
    ElevenLabsModel model = ElevenLabsModel.flash,
    double stability = 0.5,
    double similarityBoost = 0.75,
    double styleExaggeration = 0.0,
    bool speakerBoost = true,
    bool useCache = true,
  }) async {
    // Detect Arabic text
    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    
    // Force multilingual model for Arabic or if explicitly requested
    final effectiveModel = isArabic ? ElevenLabsModel.multilingual : model;
    
    try {
      _ensureInitialized();
      
      // Check cache first
      if (useCache) {
        final cacheKey = _generateCacheKey(text, voiceId, effectiveModel, stability, similarityBoost, styleExaggeration, speakerBoost);
        if (_voiceCache.containsKey(cacheKey)) {
          final cachedPath = _voiceCache[cacheKey]!;
          final file = File(cachedPath);
          if (await file.exists()) {
            // Validate cached audio file before returning
            if (await _validateAudioFile(cachedPath)) {
              Logger.info('Using cached audio for text: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
              return cachedPath;
            } else {
              // Remove invalid cache entry
              _voiceCache.remove(cacheKey);
              Logger.warn('Removed invalid cached audio file', tag: 'ElevenLabs');
            }
          } else {
            // Remove invalid cache entry
            _voiceCache.remove(cacheKey);
          }
        }
      }
      
      Logger.info('Generating speech for text: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
      
      // Prepare request body with advanced settings
      final requestBody = json.encode({
        'text': text,
        'model_id': effectiveModel.id,
        'voice_settings': {
          'stability': stability,
          'similarity_boost': similarityBoost,
          'style': styleExaggeration,
          'use_speaker_boost': speakerBoost,
        },
      });
      
      // Check rate limit before making API call
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final rateLimitResult = await _rateLimiter.checkElevenLabsLimit(user.uid);
        if (!rateLimitResult.allowed) {
          Logger.warn('ElevenLabs API rate limit exceeded: ${rateLimitResult.message}', tag: 'ElevenLabs');
          throw ApiError(ApiErrorType.rateLimitExceeded, rateLimitResult.message ?? 'Rate limit exceeded');
        }
      }
      
      // Make API request with retry logic
      final stopwatch = Stopwatch()..start();
      http.Response? response;
      int attempt = 0;
      bool success = false;
      String? errorType;
      
      while (attempt < _maxRetries) {
        try {
          // Use persistent HTTP client for connection pooling
          response = await _httpClient.post(
            Uri.parse('$baseUrl/text-to-speech/$voiceId'),
            headers: {
              'xi-api-key': _apiKey,
              'Content-Type': 'application/json',
              'Accept': 'audio/mpeg',
            },
            body: requestBody,
          ).timeout(const Duration(seconds: 30));
          
          // Record API call after successful request
          if (user != null && response.statusCode == 200) {
            await _rateLimiter.recordApiCall(user.uid, 'elevenlabs');
            success = true;
          } else if (response.statusCode == 429) {
            errorType = 'rateLimitExceeded';
          } else if (response.statusCode >= 500) {
            errorType = 'serverError';
          } else if (response.statusCode == 401 || response.statusCode == 403) {
            errorType = 'apiKeyInvalid';
          }
          
          // Break on success or non-retryable errors
          if (response.statusCode == 200 || 
              response.statusCode == 401 || 
              response.statusCode == 403 ||
              response.statusCode == 400) {
            break;
          }
          
          // Retry on retryable errors
          if (response.statusCode == 429 || 
              response.statusCode == 500 || 
              response.statusCode == 502 || 
              response.statusCode == 503) {
            attempt++;
            if (attempt >= _maxRetries) {
              break;
            }
            
            final delay = _baseRetryDelay * pow(2, attempt - 1);
            Logger.info('Retrying TTS request after ${delay.inSeconds}s (attempt $attempt/$_maxRetries)', tag: 'ElevenLabs');
            await Future.delayed(delay);
            continue;
          }
          
          // Unknown status code - break
          break;
        } catch (e) {
          attempt++;
          if (attempt >= _maxRetries) {
            Logger.error('Max retries reached for TTS request: $e', tag: 'ElevenLabs');
            rethrow;
          }
          
          // Check if it's a network/timeout error (retryable)
          final errorString = e.toString().toLowerCase();
          final isRetryable = errorString.contains('timeout') ||
              errorString.contains('network') ||
              errorString.contains('connection');
          
          if (!isRetryable) {
            rethrow;
          }
          
          final delay = _baseRetryDelay * pow(2, attempt - 1);
          Logger.info('Retrying TTS request after ${delay.inSeconds}s (attempt $attempt/$_maxRetries)', tag: 'ElevenLabs');
          await Future.delayed(delay);
        }
      }
      
      if (response == null) {
        throw ApiError(ApiErrorType.networkError, 'Failed to get response from ElevenLabs API');
      }
      
      if (response.statusCode == 200) {
        // Save audio to temporary file
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${tempDir.path}/elevenlabs_$timestamp.mp3';
        
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        
        // Validate audio file before caching
        if (!await _validateAudioFile(filePath)) {
          Logger.error('Generated audio file failed validation', tag: 'ElevenLabs');
          await file.delete();
          throw ApiError(ApiErrorType.unknownError, 'Audio generation failed: Invalid audio file');
        }
        
        // Cache the file
        if (useCache) {
          final cacheKey = _generateCacheKey(text, voiceId, effectiveModel, stability, similarityBoost, styleExaggeration, speakerBoost);
          _cacheAudioFile(cacheKey, filePath);
        }
        
        stopwatch.stop();
        
        // Record analytics
        if (user != null) {
          await _analytics.recordApiCall(
            apiType: 'elevenlabs',
            success: true,
            responseTimeMs: stopwatch.elapsedMilliseconds,
          );
        }
        
        Logger.info('Audio saved to: $filePath (${bytes.length} bytes)');
        return filePath;
      } else if (response.statusCode == 429) {
        stopwatch.stop();
        if (user != null) {
          await _analytics.recordApiCall(
            apiType: 'elevenlabs',
            success: false,
            responseTimeMs: stopwatch.elapsedMilliseconds,
            errorType: 'rateLimitExceeded',
          );
        }
        Logger.warn('ElevenLabs rate limit exceeded', tag: 'ElevenLabs');
        throw ApiError(ApiErrorType.rateLimitExceeded, 'Rate limit exceeded');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        stopwatch.stop();
        if (user != null) {
          await _analytics.recordApiCall(
            apiType: 'elevenlabs',
            success: false,
            responseTimeMs: stopwatch.elapsedMilliseconds,
            errorType: 'apiKeyInvalid',
          );
        }
        Logger.error('ElevenLabs authentication failed - API key may be invalid', tag: 'ElevenLabs');
        throw ApiError(ApiErrorType.apiKeyInvalid, 'Authentication failed');
      } else if (response.statusCode >= 500) {
        stopwatch.stop();
        if (user != null) {
          await _analytics.recordApiCall(
            apiType: 'elevenlabs',
            success: false,
            responseTimeMs: stopwatch.elapsedMilliseconds,
            errorType: 'serverError',
          );
        }
        Logger.error('ElevenLabs server error: ${response.statusCode}', tag: 'ElevenLabs');
        throw ApiError(ApiErrorType.serverError, 'Server error: ${response.statusCode}');
      } else {
        stopwatch.stop();
        if (user != null) {
          await _analytics.recordApiCall(
            apiType: 'elevenlabs',
            success: false,
            responseTimeMs: stopwatch.elapsedMilliseconds,
            errorType: 'unknownError',
          );
        }
        Logger.error('TTS request failed: ${response.statusCode} - ${response.body}', tag: 'ElevenLabs');
        throw ApiError(ApiErrorType.unknownError, 'Request failed: ${response.statusCode}');
      }
    } on ApiError {
      rethrow; // Re-throw ApiError as-is
    } catch (e) {
      Logger.error('Error in text-to-speech: $e', tag: 'ElevenLabs');
      // Convert to ApiError for consistent error handling
      throw ApiError.fromException(e);
    }
  }

  /// Validate audio file integrity and quality
  /// Returns true if file is valid, false otherwise
  Future<bool> _validateAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      
      // Check file exists
      if (!await file.exists()) {
        Logger.error('Audio file does not exist: $filePath', tag: 'ElevenLabs');
        return false;
      }
      
      // Check file size > 0
      final fileSize = await file.length();
      if (fileSize == 0) {
        Logger.error('Audio file is empty: $filePath', tag: 'ElevenLabs');
        return false;
      }
      
      // Check minimum file size (MP3 header is at least 4 bytes)
      if (fileSize < 4) {
        Logger.error('Audio file too small: $filePath ($fileSize bytes)', tag: 'ElevenLabs');
        return false;
      }
      
      // Verify MP3 header (ID3v2 tag starts with "ID3" or MP3 frame sync starts with 0xFF)
      final bytes = await file.readAsBytes();
      final header = bytes.take(3).toList();
      
      // Check for ID3v2 tag (starts with "ID3")
      final isId3v2 = String.fromCharCodes(header) == 'ID3';
      
      // Check for MP3 frame sync (0xFF followed by 0xE0-0xFF)
      final isMp3Frame = bytes.length >= 2 && bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
      
      if (!isId3v2 && !isMp3Frame) {
        Logger.error('Invalid MP3 header in file: $filePath', tag: 'ElevenLabs');
        return false;
      }
      
      // Try to get duration using AudioPlayer to verify file is playable
      try {
        final testPlayer = AudioPlayer();
        await testPlayer.setFilePath(filePath);
        final duration = testPlayer.duration;
        await testPlayer.dispose();
        
        // Check minimum duration for non-empty text (at least 0.1 seconds)
        if (duration != null && duration.inMilliseconds < 100) {
          Logger.warn('Audio file duration too short: ${duration.inMilliseconds}ms', tag: 'ElevenLabs');
          // Don't fail validation for short audio - might be valid for very short text
        }
      } catch (e) {
        Logger.warn('Could not verify audio duration: $e', tag: 'ElevenLabs');
        // Don't fail validation if duration check fails - file might still be valid
      }
      
      return true;
    } catch (e) {
      Logger.error('Error validating audio file: $e', tag: 'ElevenLabs');
      return false;
    }
  }

  /// Cache audio file (with LRU eviction if needed)
  void _cacheAudioFile(String cacheKey, String filePath) {
    // Remove oldest entry if cache is full
    if (_voiceCache.length >= maxCacheSize) {
      final firstKey = _voiceCache.keys.first;
      _voiceCache.remove(firstKey);
    }
    
    _voiceCache[cacheKey] = filePath;
    Logger.info('Cached audio file: $cacheKey');
  }

  /// Generate voices for multiple reminders in batch with optimized parallel processing
  /// 
  /// [reminders] - List of reminder texts to generate
  /// [voiceId] - ElevenLabs voice ID to use
  /// [model] - Voice model to use
  /// [maxConcurrent] - Maximum concurrent requests (default: 3 to avoid rate limits)
  /// Returns map of reminder text -> audio file path
  /// 
  /// Performance: Uses parallel processing with controlled concurrency to optimize batch generation
  Future<Map<String, String>> generateReminderVoices({
    required List<String> reminders,
    required String voiceId,
    ElevenLabsModel model = ElevenLabsModel.flash,
    double stability = 0.5,
    double similarityBoost = 0.75,
    double styleExaggeration = 0.0,
    bool speakerBoost = true,
    int maxConcurrent = 3, // Limit concurrent requests to avoid rate limits
  }) async {
    final Map<String, String> results = {};
    
    Logger.info('Generating ${reminders.length} reminder voices in batch (max concurrent: $maxConcurrent)');
    
    // Process reminders in batches with controlled concurrency
    for (int i = 0; i < reminders.length; i += maxConcurrent) {
      final batch = reminders.skip(i).take(maxConcurrent).toList();
      
      // Process batch in parallel
      final batchResults = await Future.wait(
        batch.map((reminder) async {
          try {
            final audioPath = await textToSpeech(
              text: reminder,
              voiceId: voiceId,
              model: model,
              stability: stability,
              similarityBoost: similarityBoost,
              styleExaggeration: styleExaggeration,
              speakerBoost: speakerBoost,
              useCache: true, // Use cache for batch generation
            );
            return MapEntry(reminder, audioPath);
          } catch (e) {
            Logger.error('Error generating voice for reminder "$reminder": $e');
            return null; // Return null on failure
          }
        }),
        eagerError: false, // Continue even if some fail
      );
      
      // Add successful results
      for (final result in batchResults) {
        if (result != null) {
          results[result.key] = result.value;
        }
      }
      
      // Small delay between batches to avoid rate limits
      if (i + maxConcurrent < reminders.length) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    Logger.info('Generated ${results.length}/${reminders.length} reminder voices');
    return results;
  }

  /// Clear voice cache
  Future<void> clearVoiceCache() async {
    _voiceCache.clear();
    Logger.info('Voice cache cleared');
  }

  /// Get cached voice count
  int get cachedVoiceCount => _voiceCache.length;
  
  /// Play audio file at given path
  /// 
  /// [audioPath] - Local file path to audio file
  /// [volume] - Playback volume (0.0 - 1.0, default: 1.0)
  Future<void> playAudio({
    required String audioPath,
    double volume = 1.0,
  }) async {
    try {
      Logger.info('Playing audio: $audioPath');
      
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.setFilePath(audioPath);
      await _audioPlayer.play();
      
      Logger.info('Audio playback started');
    } catch (e) {
      Logger.error('Error playing audio: $e');
      rethrow;
    }
  }
  
  /// Stop current audio playback
  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
      Logger.info('Audio playback stopped');
    } catch (e) {
      Logger.error('Error stopping playback: $e');
    }
  }
  
  /// Pause current audio playback
  Future<void> pausePlayback() async {
    try {
      await _audioPlayer.pause();
      Logger.info('Audio playback paused');
    } catch (e) {
      Logger.error('Error pausing playback: $e');
    }
  }
  
  /// Resume paused audio playback
  Future<void> resumePlayback() async {
    try {
      await _audioPlayer.play();
      Logger.info('Audio playback resumed');
    } catch (e) {
      Logger.error('Error resuming playback: $e');
    }
  }
  
  /// Check if audio is currently playing
  bool get isPlaying => _audioPlayer.playing;
  
  /// Get current playback position
  Duration? get position => _audioPlayer.position;
  
  /// Get audio duration
  Duration? get duration => _audioPlayer.duration;
  
  /// Stream of playback state changes
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  
  /// Stream of playback position changes
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  
  /// Clean up temporary audio files (except cached ones)
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      
      final cachedPaths = _voiceCache.values.toSet();
      
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.contains('elevenlabs_')) {
          // Don't delete cached files
          if (!cachedPaths.contains(entity.path)) {
          await entity.delete();
          Logger.info('Deleted temp file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      Logger.error('Error cleaning up temp files: $e');
    }
  }

  /// Get streaming service instance (for real-time voice generation)
  /// Returns a new streaming service instance
  ElevenLabsStreamingService getStreamingService() {
    return ElevenLabsStreamingService(this);
  }
  
  /// Dispose of resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _httpClient.close(); // Close HTTP client to free connections
      await cleanupTempFiles();
      Logger.info('ElevenLabs service disposed');
    } catch (e) {
      Logger.error('Error disposing service: $e');
    }
  }
  
  /// Ensure service is initialized before use
  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('ElevenLabs service not initialized. Call initialize() first.');
    }
  }
}
