import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../utils/logger.dart';
import 'elevenlabs_service.dart';
import 'api_error.dart';

/// Streaming Audio Source for real-time playback
class StreamingAudioSource extends StreamAudioSource {
  final Stream<List<int>> audioStream;
  
  StreamingAudioSource(this.audioStream);
  
  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    return StreamAudioResponse(
      sourceLength: null, // Unknown length for streaming
      contentLength: null,
      offset: start ?? 0,
      stream: audioStream,
      contentType: 'audio/mpeg',
    );
  }
}

/// ElevenLabs Streaming Service Extension
/// Handles real-time streaming text-to-speech
class ElevenLabsStreamingService {
  final ElevenLabsService _elevenLabs;
  final http.Client _client = http.Client();
  
  // Retry configuration
  static const _maxRetries = 3;
  static const _baseRetryDelay = Duration(seconds: 1);
  static const _streamingTimeout = Duration(seconds: 30);
  
  ElevenLabsStreamingService(this._elevenLabs);
  
  /// Stream text-to-speech with real-time playback
  /// Returns a stream of audio chunks that can be played immediately
  Stream<List<int>> streamTextToSpeech({
    required String text,
    required String voiceId,
    ElevenLabsModel model = ElevenLabsModel.flash, // Flash is best for streaming
    double stability = 0.5,
    double similarityBoost = 0.75,
    double styleExaggeration = 0.0,
    bool speakerBoost = true,
  }) async* {
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        if (!_elevenLabs.isInitialized) {
          await _elevenLabs.initialize();
        }
        
        Logger.info('Starting streaming TTS for text: "${text.substring(0, text.length > 50 ? 50 : text.length)}..." (attempt ${attempt + 1}/$_maxRetries)');
        
        // Create streaming request
        final request = http.Request(
          'POST',
          Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId/stream'),
        );
        
        // Set headers
        request.headers.addAll({
          'xi-api-key': _elevenLabs.apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        });
        
        // Set body with advanced settings
        request.body = json.encode({
          'text': text,
          'model_id': model.id,
          'voice_settings': {
            'stability': stability,
            'similarity_boost': similarityBoost,
            'style': styleExaggeration,
            'use_speaker_boost': speakerBoost,
          },
          'optimize_streaming_latency': 4, // Maximum optimization (0-4)
        });
        
        // Send request and stream response with timeout
        final response = await _client.send(request).timeout(_streamingTimeout);
        
        if (response.statusCode == 200) {
          Logger.info('Streaming started successfully');
          
          int chunkCount = 0;
          int totalBytes = 0;
          
          // Stream audio chunks as they arrive with validation
          await for (final chunk in response.stream.timeout(_streamingTimeout)) {
            // Validate chunk (basic check - non-empty)
            if (chunk.isEmpty) {
              Logger.warn('Received empty chunk, skipping', tag: 'ElevenLabsStreaming');
              continue;
            }
            
            // Basic validation: check if chunk looks like audio data
            // MP3 chunks should have some non-zero bytes
            final hasData = chunk.any((byte) => byte != 0);
            if (!hasData && chunkCount > 0) {
              Logger.warn('Received chunk with all zeros, may indicate corruption', tag: 'ElevenLabsStreaming');
              // Don't skip - might be valid silence
            }
            
            chunkCount++;
            totalBytes += chunk.length;
            yield chunk;
          }
          
          Logger.info('Streaming completed: $chunkCount chunks, $totalBytes bytes');
          return; // Success - exit retry loop
        } else {
          final body = await response.stream.bytesToString();
          final errorMsg = 'Streaming failed: ${response.statusCode} - $body';
          
          // Check if error is retryable
          if (response.statusCode == 429 || 
              response.statusCode == 500 || 
              response.statusCode == 502 || 
              response.statusCode == 503) {
            attempt++;
            if (attempt >= _maxRetries) {
              Logger.error('Max retries reached for streaming: $errorMsg', tag: 'ElevenLabsStreaming');
              throw ApiError(ApiErrorType.serverError, errorMsg);
            }
            
            final delay = _baseRetryDelay * pow(2, attempt - 1);
            Logger.info('Retrying streaming after ${delay.inSeconds}s (attempt $attempt/$_maxRetries)', tag: 'ElevenLabsStreaming');
            await Future.delayed(delay);
            continue;
          } else {
            // Non-retryable error
            Logger.error(errorMsg, tag: 'ElevenLabsStreaming');
            throw ApiError.fromException(Exception(errorMsg));
          }
        }
      } on TimeoutException {
        attempt++;
        if (attempt >= _maxRetries) {
          Logger.error('Streaming timeout after $_maxRetries attempts', tag: 'ElevenLabsStreaming');
          throw ApiError(ApiErrorType.networkError, 'Streaming request timed out');
        }
        
        final delay = _baseRetryDelay * pow(2, attempt - 1);
        Logger.info('Retrying streaming after timeout (${delay.inSeconds}s, attempt $attempt/$_maxRetries)', tag: 'ElevenLabsStreaming');
        await Future.delayed(delay);
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetries) {
          Logger.error('Max retries reached for streaming: $e', tag: 'ElevenLabsStreaming');
          rethrow;
        }
        
        // Check if it's a network error (retryable)
        final errorString = e.toString().toLowerCase();
        final isRetryable = errorString.contains('timeout') ||
            errorString.contains('network') ||
            errorString.contains('connection');
        
        if (!isRetryable) {
          Logger.error('Non-retryable error in streaming: $e', tag: 'ElevenLabsStreaming');
          rethrow;
        }
        
        final delay = _baseRetryDelay * pow(2, attempt - 1);
        Logger.info('Retrying streaming after error (${delay.inSeconds}s, attempt $attempt/$_maxRetries)', tag: 'ElevenLabsStreaming');
        await Future.delayed(delay);
      }
    }
    
    throw ApiError(ApiErrorType.networkError, 'Streaming failed after $_maxRetries attempts');
  }
  
  /// Play streaming audio in real-time
  /// This starts playback immediately as data arrives (no wait!)
  Future<AudioPlayer> playStreamingAudio({
    required Stream<List<int>> audioStream,
    double volume = 1.0,
  }) async {
    try {
      final player = AudioPlayer();
      await player.setVolume(volume);
      
      // Create streaming audio source
      final source = StreamingAudioSource(audioStream);
      
      // Set and play immediately
      await player.setAudioSource(source);
      await player.play();
      
      Logger.info('Streaming audio playback started');
      return player;
    } catch (e) {
      Logger.error('Error playing streaming audio: $e');
      rethrow;
    }
  }
  
  /// Convenience method: Stream and play in one call
  Future<AudioPlayer> streamAndPlay({
    required String text,
    required String voiceId,
    ElevenLabsModel model = ElevenLabsModel.flash,
    double volume = 1.0,
    double stability = 0.5,
    double similarityBoost = 0.75,
    double styleExaggeration = 0.0,
    bool speakerBoost = true,
  }) async {
    final audioStream = streamTextToSpeech(
      text: text,
      voiceId: voiceId,
      model: model,
      stability: stability,
      similarityBoost: similarityBoost,
      styleExaggeration: styleExaggeration,
      speakerBoost: speakerBoost,
    );
    
    return await playStreamingAudio(
      audioStream: audioStream,
      volume: volume,
    );
  }
  
  /// Dispose of resources
  void dispose() {
    _client.close();
  }
}
