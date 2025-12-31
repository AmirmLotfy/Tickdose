import 'package:hive_flutter/hive_flutter.dart';
import 'package:tickdose/core/models/user_model.dart';
import 'dart:convert';

class CacheService {
  static const String _userBoxName = 'user_cache';
  static const String _settingsBoxName = 'settings_cache';

  Future<void> init() async {
    // Hive.initFlutter() should be called in main.dart before this
    // Open boxes (will create if they don't exist)
    await Hive.openBox(_userBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  // User Caching
  Future<void> cacheUser(UserModel user) async {
    final box = Hive.box(_userBoxName);
    await box.put('current_user', jsonEncode(user.toMap()));
  }

  UserModel? getCachedUser() {
    final box = Hive.box(_userBoxName);
    final String? data = box.get('current_user');
    if (data != null) {
      return UserModel.fromMap(jsonDecode(data));
    }
    return null;
  }

  Future<void> clearUserCache() async {
    final box = Hive.box(_userBoxName);
    await box.delete('current_user');
  }

  // Settings Caching
  Future<void> cacheSettings(Map<String, dynamic> settings) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('app_settings', jsonEncode(settings));
  }

  Map<String, dynamic>? getCachedSettings() {
    final box = Hive.box(_settingsBoxName);
    final String? data = box.get('app_settings');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }
}
