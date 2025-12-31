import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:tickdose/core/utils/logger.dart';

class TranslationService {
  final OnDeviceTranslatorModelManager _modelManager = OnDeviceTranslatorModelManager();

  /// Translates text from source language to target language.
  /// Automatically downloads the model if not present.
  Future<String?> translate({
    required String text,
    required String sourceLanguage, // e.g., 'en'
    required String targetLanguage, // e.g., 'ar'
  }) async {
    try {
      final source = TranslateLanguage.values.firstWhere(
        (l) => l.bcp47Code == sourceLanguage,
        orElse: () => TranslateLanguage.english,
      );
      final target = TranslateLanguage.values.firstWhere(
        (l) => l.bcp47Code == targetLanguage,
        orElse: () => TranslateLanguage.arabic,
      );

      // Check and download models
      final sourceCode = source.bcp47Code;
      final targetCode = target.bcp47Code;

      if (!await _modelManager.isModelDownloaded(sourceCode)) {
        Logger.info('Downloading model: $sourceCode');
        await _modelManager.downloadModel(sourceCode); // Expects String
      }
      
      if (!await _modelManager.isModelDownloaded(targetCode)) {
        Logger.info('Downloading model: $targetCode');
        await _modelManager.downloadModel(targetCode);
      }

      final translator = OnDeviceTranslator(sourceLanguage: source, targetLanguage: target);
      final result = await translator.translateText(text);
      
      await translator.close();
      return result;
    } catch (e) {
      Logger.error('Translation failed: $e');
      return null;
    }
  }

  /// Checks if a language model is downloaded
  Future<bool> isModelDownloaded(String languageCode) async {
    return await _modelManager.isModelDownloaded(languageCode);
  }

  /// Deletes a language model to free space
  Future<void> deleteModel(String languageCode) async {
    await _modelManager.deleteModel(languageCode);
  }
}

extension TranslateLanguageExtension on TranslateLanguage {
  String get bcp47Code {
    switch (this) {
      case TranslateLanguage.afrikaans: return 'af';
      case TranslateLanguage.albanian: return 'sq';
      case TranslateLanguage.arabic: return 'ar';
      case TranslateLanguage.belarusian: return 'be';
      case TranslateLanguage.bulgarian: return 'bg';
      case TranslateLanguage.bengali: return 'bn';
      case TranslateLanguage.catalan: return 'ca';
      case TranslateLanguage.chinese: return 'zh';
      case TranslateLanguage.croatian: return 'hr';
      case TranslateLanguage.czech: return 'cs';
      case TranslateLanguage.danish: return 'da';
      case TranslateLanguage.dutch: return 'nl';
      case TranslateLanguage.english: return 'en';
      case TranslateLanguage.esperanto: return 'eo';
      case TranslateLanguage.estonian: return 'et';
      case TranslateLanguage.finnish: return 'fi';
      case TranslateLanguage.french: return 'fr';
      case TranslateLanguage.galician: return 'gl';
      case TranslateLanguage.georgian: return 'ka';
      case TranslateLanguage.german: return 'de';
      case TranslateLanguage.greek: return 'el';
      case TranslateLanguage.gujarati: return 'gu';
      case TranslateLanguage.haitian: return 'ht';
      case TranslateLanguage.hebrew: return 'he';
      case TranslateLanguage.hindi: return 'hi';
      case TranslateLanguage.hungarian: return 'hu';
      case TranslateLanguage.icelandic: return 'is';
      case TranslateLanguage.indonesian: return 'id';
      case TranslateLanguage.irish: return 'ga';
      case TranslateLanguage.italian: return 'it';
      case TranslateLanguage.japanese: return 'ja';
      case TranslateLanguage.kannada: return 'kn';
      case TranslateLanguage.korean: return 'ko';
      case TranslateLanguage.lithuanian: return 'lt';
      case TranslateLanguage.latvian: return 'lv';
      case TranslateLanguage.macedonian: return 'mk';
      case TranslateLanguage.marathi: return 'mr';
      case TranslateLanguage.malay: return 'ms';
      case TranslateLanguage.maltese: return 'mt';
      case TranslateLanguage.norwegian: return 'no';
      case TranslateLanguage.persian: return 'fa';
      case TranslateLanguage.polish: return 'pl';
      case TranslateLanguage.portuguese: return 'pt';
      case TranslateLanguage.romanian: return 'ro';
      case TranslateLanguage.russian: return 'ru';
      case TranslateLanguage.slovak: return 'sk';
      case TranslateLanguage.slovenian: return 'sl';
      case TranslateLanguage.spanish: return 'es';
      case TranslateLanguage.swedish: return 'sv';
      case TranslateLanguage.swahili: return 'sw';
      case TranslateLanguage.tagalog: return 'tl';
      case TranslateLanguage.tamil: return 'ta';
      case TranslateLanguage.telugu: return 'te';
      case TranslateLanguage.thai: return 'th';
      case TranslateLanguage.turkish: return 'tr';
      case TranslateLanguage.ukrainian: return 'uk';
      case TranslateLanguage.urdu: return 'ur';
      case TranslateLanguage.vietnamese: return 'vi';
      case TranslateLanguage.welsh: return 'cy';
    }
  }
}
