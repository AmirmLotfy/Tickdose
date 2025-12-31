
/// Service for detecting emotions in voice responses
class EmotionDetectionService {
  static final EmotionDetectionService _instance = EmotionDetectionService._internal();
  factory EmotionDetectionService() => _instance;
  EmotionDetectionService._internal();

  /// Detect tone/emotion in voice response
  /// 
  /// [text] - Transcribed text from voice input
  /// Returns detected emotion/tone
  EmotionResult detectToneInResponse(String text) {
    final lowerText = text.toLowerCase().trim();

    // Simple keyword-based emotion detection
    // In production, this could use ML models or external APIs

    EmotionType emotion = EmotionType.neutral;
    double confidence = 0.5;

    // Positive emotions
    if (_containsAny(lowerText, ['yes', 'sure', 'ok', 'good', 'fine', 'great', 'thanks', 'thank you'])) {
      emotion = EmotionType.positive;
      confidence = 0.7;
    }

    // Negative emotions
    if (_containsAny(lowerText, ['no', 'not', "don't", "won't", 'bad', 'hurt', 'pain', 'tired', 'sick'])) {
      emotion = EmotionType.negative;
      confidence = 0.7;
    }

    // Frustrated
    if (_containsAny(lowerText, ['frustrated', 'annoying', 'hate', 'upset', 'angry'])) {
      emotion = EmotionType.frustrated;
      confidence = 0.8;
    }

    // Confused
    if (_containsAny(lowerText, ['confused', "don't know", 'unclear', 'what', 'how', 'why'])) {
      emotion = EmotionType.confused;
      confidence = 0.7;
    }

    return EmotionResult(
      emotion: emotion,
      confidence: confidence,
      detectedText: text,
    );
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// Adjust reminder approach based on detected emotion
  /// 
  /// [emotion] - Detected emotion
  /// Returns suggested approach
  ReminderApproach getReminderApproach(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.negative:
      case EmotionType.frustrated:
        return ReminderApproach.supportive; // More supportive and gentle
      case EmotionType.confused:
        return ReminderApproach.explanatory; // More explanation needed
      case EmotionType.positive:
        return ReminderApproach.standard; // Standard approach
      case EmotionType.neutral:
        return ReminderApproach.standard;
    }
  }

  /// Provide encouragement based on emotion
  String getEncouragementMessage(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.positive:
        return 'Great job! Keep it up!';
      case EmotionType.negative:
      case EmotionType.frustrated:
        return 'I understand this can be challenging. You\'re doing your best, and that\'s what matters.';
      case EmotionType.confused:
        return 'Don\'t worry, we\'re here to help. Take your time.';
      case EmotionType.neutral:
        return 'You\'re doing great!';
    }
  }
}

/// Emotion detection result
class EmotionResult {
  final EmotionType emotion;
  final double confidence;
  final String detectedText;

  EmotionResult({
    required this.emotion,
    required this.confidence,
    required this.detectedText,
  });
}

/// Emotion types
enum EmotionType {
  positive,
  negative,
  frustrated,
  confused,
  neutral,
}

/// Reminder approaches based on emotion
enum ReminderApproach {
  standard,
  supportive,
  explanatory,
}
