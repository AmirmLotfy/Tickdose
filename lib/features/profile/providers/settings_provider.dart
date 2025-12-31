import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';


// Settings Model
class SettingsModel {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String quietHoursStart; // Format: "HH:mm"
  final String quietHoursEnd; // Format: "HH:mm"
  final String language;
  final bool darkMode;

  SettingsModel({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.language = 'en',
    this.darkMode = false,
  });

  SettingsModel copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? language,
    bool? darkMode,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

// Settings Provider
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsModel>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<SettingsModel> {
  @override
  SettingsModel build() {
    _loadSettings();
    return SettingsModel();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    state = SettingsModel(
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      soundEnabled: prefs.getBool('sound_enabled') ?? true,
      vibrationEnabled: prefs.getBool('vibration_enabled') ?? true,
      quietHoursStart: prefs.getString('quiet_hours_start') ?? '22:00',
      quietHoursEnd: prefs.getString('quiet_hours_end') ?? '08:00',
      language: prefs.getString('language') ?? _getDeviceLanguage(),
      darkMode: prefs.getBool('dark_mode') ?? false,
    );
  }

  String _getDeviceLanguage() {
    try {
      final localeName = Platform.localeName; // Returns locale string like 'en_US', 'ar_SA'
      if (localeName.toLowerCase().startsWith('ar')) {
        return 'ar';
      }
    } catch (_) {}
    return 'en';
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }

  Future<void> toggleVibration(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', enabled);
  }

  Future<void> setQuietHours(String start, String end) async {
    state = state.copyWith(quietHoursStart: start, quietHoursEnd: end);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quiet_hours_start', start);
    await prefs.setString('quiet_hours_end', end);
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    state = state.copyWith(darkMode: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', enabled);
  }
}
