import 'package:flutter/material.dart';

/// Material Symbols icon mapping
/// 
/// This file documents the mapping between Material Symbols icon names
/// (used in the design files) and their Flutter Material Icons equivalents.
/// 
/// To use actual Material Symbols icons in the future:
/// 1. Download Material Symbols font files from Google Fonts
/// 2. Add them to assets/fonts/ directory
/// 3. Configure in pubspec.yaml under fonts section
/// 4. Update icon mappings to use the Material Symbols font family
/// 
/// Current implementation uses Material Icons as substitutes which provide
/// similar visual appearance and maintain functionality.

class MaterialSymbolsMapping {
  // Icon name mappings: Material Symbols name -> Material Icons equivalent
  static const Map<String, IconData> iconMap = {
    // Health & Medical
    'vital_signs': Icons.favorite, // Heart/vital signs icon
    'ecg_heart': Icons.favorite, // ECG/heart monitor icon
    'medication': Icons.medication, // Medication/pill icon
    'local_fire_department': Icons.local_fire_department, // Fire/flame icon
    'pill': Icons.medication, // Pill icon
    'psychology': Icons.psychology, // Brain/AI icon
    
    // Navigation & UI
    'home': Icons.home,
    'notifications': Icons.notifications,
    'person': Icons.person,
    'local_pharmacy': Icons.local_pharmacy,
    'arrow_back': Icons.arrow_back_ios_new,
    'arrow_forward': Icons.arrow_forward,
    'check_circle': Icons.check_circle,
    'visibility': Icons.visibility,
    'visibility_off': Icons.visibility_off,
    
    // Settings & Preferences
    'temp_preferences_custom': Icons.tune, // Settings/custom preferences
    'settings': Icons.settings,
    'calendar_today': Icons.calendar_today,
    
    // Status & Actions
    'check': Icons.check,
    'stars': Icons.stars,
    'water_drop': Icons.water_drop,
    'mood': Icons.mood,
    'emoji_events': Icons.emoji_events,
  };

  /// Get Material Icons equivalent for a Material Symbols icon name
  /// Returns the Material Icons equivalent or a default icon if not found
  static IconData getIcon(String materialSymbolsName, {IconData? fallback}) {
    return iconMap[materialSymbolsName] ?? fallback ?? Icons.help_outline;
  }

  /// Check if a Material Symbols icon name has a mapping
  static bool hasMapping(String materialSymbolsName) {
    return iconMap.containsKey(materialSymbolsName);
  }
}

/// Extension to easily get Material Icons from Material Symbols names
extension MaterialSymbolsExtension on String {
  /// Get the Material Icons equivalent for this Material Symbols icon name
  IconData toMaterialIcon({IconData? fallback}) {
    return MaterialSymbolsMapping.getIcon(this, fallback: fallback);
  }
}

