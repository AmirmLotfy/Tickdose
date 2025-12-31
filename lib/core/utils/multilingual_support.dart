/// Supported Languages for ElevenLabs Multilingual v2
/// 32 total languages supported
enum SupportedLanguage {
  english('en', 'English', 'English'),
  arabic('ar', 'العربية', 'Arabic'),
  chinese('zh', '中文', 'Chinese'),
  czech('cs', 'Čeština', 'Czech'),
  danish('da', 'Dansk', 'Danish'),
  dutch('nl', 'Nederlands', 'Dutch'),
  filipino('fil', 'Filipino', 'Filipino'),
  finnish('fi', 'Suomi', 'Finnish'),
  french('fr', 'Français', 'French'),
  german('de', 'Deutsch', 'German'),
  greek('el', 'Ελληνικά', 'Greek'),
  hindi('hi', 'हिन्दी', 'Hindi'),
  hungarian('hu', 'Magyar', 'Hungarian'),
  indonesian('id', 'Bahasa Indonesia', 'Indonesian'),
  italian('it', 'Italiano', 'Italian'),
  japanese('ja', '日本語', 'Japanese'),
  korean('ko', '한국어', 'Korean'),
  malay('ms', 'Bahasa Melayu', 'Malay'),
  norwegian('no', 'Norsk', 'Norwegian'),
  polish('pl', 'Polski', 'Polish'),
  portuguese('pt', 'Português', 'Portuguese'),
  russian('ru', 'Русский', 'Russian'),
  slovak('sk', 'Slovenčina', 'Slovak'),
  spanish('es', 'Español', 'Spanish'),
  swedish('sv', 'Svenska', 'Swedish'),
  tamil('ta', 'தமிழ்', 'Tamil'),
  turkish('tr', 'Türkçe', 'Turkish'),
  ukrainian('uk', 'Українська', 'Ukrainian'),
  vietnamese('vi', 'Tiếng Việt', 'Vietnamese');

  const SupportedLanguage(this.code, this.nativeName, this.englishName);
  final String code;
  final String nativeName;
  final String englishName;
  
  /// Get language from code
  static SupportedLanguage? fromCode(String code) {
    try {
      return SupportedLanguage.values.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }
  
  /// Get optimal model for this language
  String get optimalModel {
    if (this == SupportedLanguage.english) {
      return 'eleven_turbo_v2_5'; // Turbo for English
    } else {
      return 'eleven_multilingual_v2'; // Multilingual for others
    }
  }
}

/// Voice Style for context-aware reminders
enum VoiceStyle {
  professional('Professional', 'Formal and clear'),
  friendly('Friendly', 'Warm and casual'),
  motivational('Motivational', 'Encouraging and energetic'),
  calm('Calm', 'Gentle and soothing');

  const VoiceStyle(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// Context-Aware Reminder Text Generator
class ReminderTextGenerator {
  /// Generate reminder text based on context
  static String generate({
    required String medicineName,
    required String dosage,
    required VoiceStyle style,
    SupportedLanguage language = SupportedLanguage.english,
  }) {
    switch (language) {
      case SupportedLanguage.english:
        return _generateEnglish(medicineName, dosage, style);
      case SupportedLanguage.arabic:
        return _generateArabic(medicineName, dosage, style);
      case SupportedLanguage.spanish:
        return _generateSpanish(medicineName, dosage, style);
      case SupportedLanguage.french:
        return _generateFrench(medicineName, dosage, style);
      default:
        return _generateEnglish(medicineName, dosage, style);
    }
  }
  
  static String _generateEnglish(String medicine, String dosage, VoiceStyle style) {
    switch (style) {
      case VoiceStyle.professional:
        return 'Medication reminder: Please take $medicine, dosage $dosage.';
      case VoiceStyle.friendly:
        return 'Hey! Time for your $medicine ($dosage). Don\'t forget!';
      case VoiceStyle.motivational:
        return 'Great job staying on track! Time for your $medicine ($dosage). You\'re doing amazing!';
      case VoiceStyle.calm:
        return 'Gentle reminder: Please take your $medicine, $dosage. Take care of yourself.';
    }
  }
  
  static String _generateArabic(String medicine, String dosage, VoiceStyle style) {
    switch (style) {
      case VoiceStyle.professional:
        return 'تذكير بالدواء: يرجى تناول $medicine، الجرعة $dosage.';
      case VoiceStyle.friendly:
        return 'مرحبا! حان وقت $medicine ($dosage). لا تنسى!';
      case VoiceStyle.motivational:
        return 'عمل رائع! حان وقت $medicine ($dosage). أنت تقوم بعمل مذهل!';
      case VoiceStyle.calm:
        return 'تذكير لطيف: يرجى تناول $medicine، $dosage. اعتني بنفسك.';
    }
  }
  
  static String _generateSpanish(String medicine, String dosage, VoiceStyle style) {
    switch (style) {
      case VoiceStyle.professional:
        return 'Recordatorio de medicamento: Por favor tome $medicine, dosis $dosage.';
      case VoiceStyle.friendly:
        return '¡Hola! Hora de tu $medicine ($dosage). ¡No lo olvides!';
      case VoiceStyle.motivational:
        return '¡Excelente trabajo! Hora de tu $medicine ($dosage). ¡Lo estás haciendo genial!';
      case VoiceStyle.calm:
        return 'Recordatorio suave: Por favor tome su $medicine, $dosage. Cuídese.';
    }
  }
  
  static String _generateFrench(String medicine, String dosage, VoiceStyle style) {
    switch (style) {
      case VoiceStyle.professional:
        return 'Rappel de médicament: Veuillez prendre $medicine, dosage $dosage.';
      case VoiceStyle.friendly:
        return 'Salut! C\'est l\'heure de votre $medicine ($dosage). N\'oubliez pas!';
      case VoiceStyle.motivational:
        return 'Excellent travail! C\'est l\'heure de votre $medicine ($dosage). Vous faites du super boulot!';
      case VoiceStyle.calm:
        return 'Rappel doux: Veuillez prendre votre $medicine, $dosage. Prenez soin de vous.';
    }
  }
}
