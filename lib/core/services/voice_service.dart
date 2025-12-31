import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize();
    }
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onStatus,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isInitialized) {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        onSoundLevelChange: (level) {
          // Optional: Visual feedback
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
      );
      onStatus('listening');
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;
}
