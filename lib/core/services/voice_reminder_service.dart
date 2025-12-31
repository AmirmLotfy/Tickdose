import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/reminder_model.dart';
import '../services/elevenlabs_service.dart';
import '../utils/logger.dart';

/// Voice reminder types
enum VoiceReminderType {
  standard,
  mealAware,
  confirmation,
  emergency,
  caregiver,
}

/// Voice Reminder Service
/// Generates and plays voice reminders for medications using ElevenLabs
class VoiceReminderService {
  static final VoiceReminderService _instance = VoiceReminderService._internal();
  factory VoiceReminderService() => _instance;
  
  VoiceReminderService._internal();
  
  final ElevenLabsService _elevenLabs = ElevenLabsService();

  // Localization Maps
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'greeting_morning': 'Good morning!',
      'greeting_afternoon': 'Good afternoon!',
      'greeting_evening': 'Good evening!',
      'greeting_default': 'Hello!',
      'meal_breakfast': 'breakfast',
      'meal_lunch': 'lunch',
      'meal_dinner': 'dinner',
      'meal_bedtime': 'bedtime',
      'reminder_standard': '{greeting} It\'s time to take {dosage} of {medicineName}. Please take your medication now to stay on track with your health goals.',
      'reminder_meal': '{greeting} It\'s {mealTime} time! Take {dosage} of {medicineName} WITH FOOD. Please take your medication now to stay on track with your health goals.',
      'reminder_confirmation': '{greeting} Did you take {dosage} of {medicineName}? Say yes or no.',
      'reminder_emergency': 'URGENT! You missed your {medicineName}. This is an important medication. Please take {dosage} now. If you have any concerns, contact your doctor immediately.',
      'reminder_caregiver': '{message}: Take {dosage} of {medicineName} now. {greeting}',
      'congrats_7': 'Congratulations! You\'ve maintained a perfect 7-day streak! Your commitment to your health is amazing. Keep up the great work!',
      'congrats_14': 'Incredible achievement! Two weeks of perfect adherence! You\'re building excellent medication habits.',
      'congrats_30': 'Outstanding! You\'ve completed a full month of perfect adherence! This is a major milestone in your health journey. You should be very proud!',
      'congrats_90': 'Extraordinary! Three months of consistent medication adherence! You\'ve built a rock-solid routine. Your dedication is truly inspiring!',
      'congrats_365': 'Phenomenal! One year of perfect medication adherence! This is an incredible achievement that shows true commitment to your health!',
      'congrats_default': 'Great job! You\'re on a {days} day streak! Keep going, you\'re doing fantastic!',
    },
    'ar': {
      'greeting_morning': 'صباح الخير!',
      'greeting_afternoon': 'مساء الخير!',
      'greeting_evening': 'مساء الخير!',
      'greeting_default': 'مرحبًا!',
      'meal_breakfast': 'الإفطار',
      'meal_lunch': 'الغداء',
      'meal_dinner': 'العشاء',
      'meal_bedtime': 'وقت النوم',
      'reminder_standard': '{greeting} حان وقت تناول {dosage} من {medicineName}. يرجى تناول دوائك الآن للحفاظ على صحتك.',
      'reminder_meal': '{greeting} حان وقت {mealTime}! تناول {dosage} من {medicineName} مع الطعام. يرجى تناول دوائك الآن للحفاظ على صحتك.',
      'reminder_confirmation': '{greeting} هل تناولت {dosage} من {medicineName}؟ قل نعم أو لا.',
      'reminder_emergency': 'هام جداً! لقد فوت جرعة {medicineName}. هذا دواء مهم. يرجى تناول {dosage} الآن. إذا كان لديك أي مخاوف، اتصل بطبيبك على الفور.',
      'reminder_caregiver': '{message}: تناول {dosage} من {medicineName} الآن. {greeting}',
      'congrats_7': 'تهانينا! لقد حافظت على التزامك لمدة 7 أيام متتالية! التزامك بصحتك مذهل. استمر في العمل الرائع!',
      'congrats_14': 'إنجاز مذهل! أسبوعان من الالتزام التام! أنت تبني عادات دوائية ممتازة.',
      'congrats_30': 'ممتاز! لقد أكملت شهرًا كاملاً من الالتزام التام! هذه علامة فارقة في رحلتك الصحية. يجب أن تكون فخوراً جداً!',
      'congrats_90': 'استثنائي! ثلاثة أشهر من الالتزام المستمر بالدواء! لقد بنيت روتينًا قويًا. تفانيك ملهم حقًا!',
      'congrats_365': 'ظاهرة! سنة كاملة من الالتزام التام بالدواء! هذا إنجاز لا يصدق يظهر التزامًا حقيقيًا بصحتك!',
      'congrats_default': 'عمل رائع! أنت في يومك الـ {days} على التوالي! استمر، أنت تقوم بعمل رائع!',
    }
  };
  
  /// Get localized string
  String _getString(String key, String lang, [Map<String, String>? params]) {
    final languageCode = (lang == 'ar') ? 'ar' : 'en'; // Default to English if not Arabic
    String text = _localizedStrings[languageCode]?[key] ?? _localizedStrings['en']![key]!;
    
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value);
      });
    }
    return text;
  }

  /// Send voice reminder for medication
  Future<void> sendVoiceReminder({
    required String medicineName,
    required String dosage,
    required String voiceId,
    TimeOfDay? timeOfDay,
    VoiceReminderType reminderType = VoiceReminderType.standard,
    String? mealTime,
    String? caregiverMessage,
    String? language,
  }) async {
    try {
      Logger.info('Generating voice reminder for: $medicineName (type: ${reminderType.name})');
      
      final lang = language ?? 'en';

      // Generate personalized message based on type
      String message = _generateReminderMessage(
        medicineName: medicineName,
        dosage: dosage,
        timeOfDay: timeOfDay,
        reminderType: reminderType,
        mealTime: mealTime,
        caregiverMessage: caregiverMessage,
        language: lang,
      );
      
      // Convert to speech
      final audioPath = await _elevenLabs.textToSpeech(
        text: message,
        voiceId: voiceId,
      );
      
      // Play the reminder
      await _elevenLabs.playAudio(audioPath: audioPath);
      
      Logger.info('Voice reminder played successfully');
    } catch (e) {
      Logger.error('Voice reminder error: $e');
      rethrow;
    }
  }
  
  /// Send voice reminder from ReminderModel
  Future<void> sendVoiceReminderFromModel({
    required ReminderModel reminder,
    required String voiceId,
    String language = 'en',
  }) async {
    try {
      final timeOfDay = _parseTimeOfDay(reminder.time);
      
      await sendVoiceReminder(
        medicineName: reminder.medicineName,
        dosage: reminder.dosage,
        voiceId: voiceId,
        timeOfDay: timeOfDay,
        language: language,
      );
    } catch (e) {
      Logger.error('Error sending voice reminder from model: $e');
      rethrow;
    }
  }

  /// Generate reminder audio file and save to persistent storage
  Future<String?> generateReminderAudioFile({
    required String reminderId,
    required String medicineName,
    required String dosage,
    required String voiceId,
    TimeOfDay? timeOfDay,
    VoiceReminderType reminderType = VoiceReminderType.standard,
    String? mealTime,
    String? caregiverMessage,
    String? language,
    String? modelId,
    double? clarity,
    double? styleExaggeration,
    bool? speakerBoost,
  }) async {
    try {
      final lang = language ?? 'en';

      // Generate personalized message first to create deterministic filename
      String message = _generateReminderMessage(
        medicineName: medicineName,
        dosage: dosage,
        timeOfDay: timeOfDay,
        reminderType: reminderType,
        mealTime: mealTime,
        caregiverMessage: caregiverMessage,
        language: lang,
      );

      // Create deterministic filename based on content (so we can reuse for recurring reminders)
      final effectiveModelId = modelId ?? 'eleven_flash_v2_5';
      // Note: clarity parameter removed from hash - no longer used in API
      final effectiveStyle = styleExaggeration ?? 0.0;
      final effectiveSpeakerBoost = speakerBoost ?? true;
      final contentHash = _generateContentHash(
        message, 
        voiceId, 
        effectiveModelId,
        0.75, // Keep for backward compatibility in hash, but not used in API
        effectiveStyle,
        effectiveSpeakerBoost,
        reminderType.name,
      );
      final fileName = 'reminder_${reminderId}_$contentHash.mp3';
      
      final appDocDir = await getApplicationDocumentsDirectory();
      final reminderSoundsDir = Directory('${appDocDir.path}/reminder_sounds');
      if (!await reminderSoundsDir.exists()) {
        await reminderSoundsDir.create(recursive: true);
      }
      
      final persistentPath = '${reminderSoundsDir.path}/$fileName';
      
      final existingFile = File(persistentPath);
      if (await existingFile.exists()) {
        Logger.info('Reusing existing audio file for: $medicineName (reminderId: $reminderId)', tag: 'VoiceReminder');
        return persistentPath;
      }
      
      Logger.info('Generating NEW reminder audio file for: $medicineName (reminderId: $reminderId)', tag: 'VoiceReminder');
      
      if (!_elevenLabs.isInitialized) {
        await _elevenLabs.initialize();
      }
      
      ElevenLabsModel model = ElevenLabsModel.flash;
      try {
        model = ElevenLabsModel.values.firstWhere(
          (m) => m.id == effectiveModelId,
          orElse: () => ElevenLabsModel.flash,
        );
      } catch (e) {
        Logger.warn('Could not find model $effectiveModelId, using flash', tag: 'VoiceReminder');
      }
      
      // Note: clarity parameter removed - ElevenLabs API doesn't support it
      // Voice clarity is controlled via stability and similarity_boost
      final audioPath = await _elevenLabs.textToSpeech(
        text: message,
        voiceId: voiceId,
        model: model,
        styleExaggeration: effectiveStyle,
        speakerBoost: effectiveSpeakerBoost,
      );
      
      final tempFile = File(audioPath);
      if (!await tempFile.exists()) {
        Logger.error('Generated audio file not found: $audioPath', tag: 'VoiceReminder');
        return null;
      }
      
      await tempFile.copy(persistentPath);
      
      Logger.info('Reminder audio file saved to: $persistentPath', tag: 'VoiceReminder');
      return persistentPath;
    } catch (e, stackTrace) {
      Logger.error(
        'Error generating reminder audio file: $e',
        tag: 'VoiceReminder',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  String _generateContentHash(
    String message, 
    String voiceId, 
    String modelId,
    double clarity,
    double styleExaggeration,
    bool speakerBoost,
    String reminderType,
  ) {
    final combined = '$message|$voiceId|$modelId|$clarity|$styleExaggeration|$speakerBoost|$reminderType';
    final hash = combined.hashCode.abs();
    return hash.toString().padLeft(10, '0');
  }

  Future<String?> generateReminderAudioFileFromModel({
    required ReminderModel reminder,
    required String voiceId,
    String? modelId,
    double? clarity,
    double? styleExaggeration,
    bool? speakerBoost,
    String? language,
  }) async {
    try {
      final timeOfDay = _parseTimeOfDay(reminder.time);
      
      return await generateReminderAudioFile(
        reminderId: reminder.id,
        medicineName: reminder.medicineName,
        dosage: reminder.dosage,
        voiceId: voiceId,
        timeOfDay: timeOfDay,
        modelId: modelId,
        clarity: clarity,
        styleExaggeration: styleExaggeration,
        speakerBoost: speakerBoost,
        language: language,
      );
    } catch (e) {
      Logger.error('Error generating reminder audio from model: $e', tag: 'VoiceReminder');
      return null;
    }
  }
  
  /// Send voice congratulation for streak achievement
  Future<void> sendVoiceCongratulation({
    required int streak,
    required String voiceId,
    String language = 'en',
  }) async {
    try {
      Logger.info('Generating congratulation for $streak day streak');
      
      final message = _generateCongratulationMessage(streak, language);
      
      final audioPath = await _elevenLabs.textToSpeech(
        text: message,
        voiceId: voiceId,
      );
      
      await _elevenLabs.playAudio(audioPath: audioPath);
      
      Logger.info('Congratulation played successfully');
    } catch (e) {
      Logger.error('Voice congratulation error: $e');
      rethrow;
    }
  }
  
  /// Generate reminder message text with language support
  String _generateReminderMessage({
    required String medicineName,
    required String dosage,
    TimeOfDay? timeOfDay,
    VoiceReminderType reminderType = VoiceReminderType.standard,
    String? mealTime,
    String? caregiverMessage,
    required String language,
  }) {
    final greeting = _getGreeting(timeOfDay, language);

    switch (reminderType) {
      case VoiceReminderType.mealAware:
        final mealText = _getMealText(mealTime, language);
        return _getString('reminder_meal', language, {
          'greeting': greeting,
          'mealTime': mealText,
          'dosage': dosage,
          'medicineName': medicineName,
        });

      case VoiceReminderType.confirmation:
         return _getString('reminder_confirmation', language, {
          'greeting': greeting,
          'dosage': dosage,
          'medicineName': medicineName,
        });

      case VoiceReminderType.emergency:
         return _getString('reminder_emergency', language, {
          'medicineName': medicineName,
          'dosage': dosage,
        });

      case VoiceReminderType.caregiver:
        final message = caregiverMessage ?? (language == 'ar' ? 'يريد مرافقك تذكيرك' : 'Your caregiver wants to remind you');
         return _getString('reminder_caregiver', language, {
          'message': message,
          'dosage': dosage,
          'medicineName': medicineName,
          'greeting': greeting,
        });

      case VoiceReminderType.standard:
        return _getString('reminder_standard', language, {
          'greeting': greeting,
          'dosage': dosage,
          'medicineName': medicineName,
        });
    }
  }

  /// Get meal time text
  String _getMealText(String? mealTime, String lang) {
    if (mealTime == null) return _getString('meal_bedtime', lang); // default fallback? or just empty?
    
    switch (mealTime.toLowerCase()) {
      case 'breakfast': return _getString('meal_breakfast', lang);
      case 'lunch': return _getString('meal_lunch', lang);
      case 'dinner': return _getString('meal_dinner', lang);
      case 'bedtime': return _getString('meal_bedtime', lang);
      default: return mealTime;
    }
  }
  
  /// Generate congratulation message text
  String _generateCongratulationMessage(int streak, String lang) {
    if (streak == 7) return _getString('congrats_7', lang);
    if (streak == 14) return _getString('congrats_14', lang);
    if (streak == 30) return _getString('congrats_30', lang);
    if (streak == 90) return _getString('congrats_90', lang);
    if (streak >= 365) return _getString('congrats_365', lang);
    return _getString('congrats_default', lang, {'days': streak.toString()});
  }
  
  /// Get time-appropriate greeting
  String _getGreeting(TimeOfDay? timeOfDay, String lang) {
    if (timeOfDay == null) return _getString('greeting_default', lang);
    
    final hour = timeOfDay.hour;
    
    if (hour >= 5 && hour < 12) return _getString('greeting_morning', lang);
    if (hour >= 12 && hour < 17) return _getString('greeting_afternoon', lang);
    if (hour >= 17 && hour < 21) return _getString('greeting_evening', lang);
    return _getString('greeting_default', lang);
  }
  
  TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      Logger.error('Error parsing time: $e');
    }
    return null;
  }
  
  bool get isPlaying => _elevenLabs.isPlaying;
  
  Future<void> stopPlayback() async {
    await _elevenLabs.stopPlayback();
  }
}
