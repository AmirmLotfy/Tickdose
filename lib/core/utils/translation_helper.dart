import 'dart:ui';
import 'package:tickdose/l10n/generated/app_localizations.dart';

class TranslationHelper {
  static Future<AppLocalizations> getLocalizations(Locale locale) async {
    return await AppLocalizations.delegate.load(locale);
  }

  static Future<AppLocalizations> forLanguage(String languageCode) async {
    return await AppLocalizations.delegate.load(Locale(languageCode));
  }
}
