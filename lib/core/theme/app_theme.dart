import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

/// Theme-aware color system that adapts to light and dark modes
class AppColors {
  // Primary Colors - New Green Theme
  static const Color primaryGreen = Color(0xFF13ec37); // Bright green
  static const Color primaryDark = Color(0xFF0fa827); // Darker green variant
  static const Color primaryBlue = Color(0xFF3B82F6); // Keep for backward compatibility
  static const Color primaryTeal = Color(0xFF14B8A6); // Keep for backward compatibility
  static const Color secondaryPurple = Color(0xFF8B5CF6); // Modern purple
  static const Color accentOrange = Color(0xFFF97316); // Warmer orange
  
  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF3B82F6);
  
  // Light Theme Colors - Green-tinted
  static const Color lightBackground = Color(0xFFf6f8f6); // Green-tinted light background
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF9CA3AF);
  static const Color lightTextTertiary = Color(0xFFD1D5DB);
  static const Color lightBorderLight = Color(0xFFE5E7EB);
  static const Color lightBorderMedium = Color(0xFFD1D5DB);
  static const Color lightBorderDark = Color(0xFF9CA3AF);
  
  // Dark Theme Colors - Green-tinted
  static const Color darkBackground = Color(0xFF102213); // Dark green background
  static const Color darkSurface = Color(0xFF162618); // Surface dark
  static const Color darkCard = Color(0xFF1A2C1D); // Card dark
  static const Color darkCardAlt = Color(0xFF19331e); // Alternative card color (for inputs)
  static const Color darkCardSecondary = Color(0xFF234829); // Secondary card color
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF92c99b); // Green-tinted secondary text
  static const Color darkTextTertiary = Color(0xFFB3B3B3);
  static const Color darkBorderLight = Color(0xFF32673b); // Green-tinted border
  static const Color darkBorderMedium = Color(0xFF4A4A4A);
  static const Color darkBorderDark = Color(0xFF5A5A5A);
  
  // Status Colors (same in both themes)
  static const Color taken = primaryGreen; // Use primary green for taken
  static const Color missed = errorRed;
  static const Color skipped = warningOrange;
  static const Color scheduled = primaryGreen; // Use primary green for scheduled
  
  // Theme-aware getters
  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }
  
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }
  
  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : lightCard;
  }
  
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }
  
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }
  
  static Color textTertiary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextTertiary
        : lightTextTertiary;
  }
  
  static Color borderLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderLight
        : lightBorderLight;
  }
  
  static Color borderMedium(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderMedium
        : lightBorderMedium;
  }
  
  static Color borderDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorderDark
        : lightBorderDark;
  }
  
  // Shadow color helpers - 2025 Multi-layer shadows
  static Color shadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.1);
  }
  
  static Color shadowColorLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.06);
  }
  
  static Color shadowColorSoft(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.04);
  }
  
  // Gradients - New Green Theme
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF13ec37), Color(0xFF054f28)], // Green gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient vibrantGradient = const LinearGradient(
    colors: [Color(0xFF13ec37), Color(0xFF0a3d20)], // Vibrant green gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient purpleGradient = const LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient successGradient = const LinearGradient(
    colors: [Color(0xFF13ec37), Color(0xFF0fa827)], // Use primary green
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static LinearGradient errorGradient = const LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  // Glassmorphism colors
  static Color glassBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF152a1a).withValues(alpha: 0.8) // Green-tinted glass
        : Colors.white.withValues(alpha: 0.7);
  }
  
  static Color glassBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.1) // More visible border
        : Colors.white.withValues(alpha: 0.2);
  }
  
  // Green glow shadow helper
  static BoxShadow greenGlowShadow = BoxShadow(
    color: primaryGreen.withValues(alpha: 0.3),
    blurRadius: 20,
    spreadRadius: 0,
  );
  
  static BoxShadow greenGlowShadowSmall = BoxShadow(
    color: primaryGreen.withValues(alpha: 0.15),
    blurRadius: 15,
    spreadRadius: 0,
  );
}

/// Theme-aware text styles
class AppTextStyles {
  static TextStyle h1(BuildContext context) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary(context),
    );
  }
  
  static TextStyle h2(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary(context),
    );
  }
  
  static TextStyle h3(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary(context),
    );
  }
  
  static TextStyle bodyLarge(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary(context),
    );
  }
  
  static TextStyle bodyMedium(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary(context),
    );
  }
  
  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary(context),
    );
  }
}

/// App theme configuration with light and dark modes
class AppTheme {
  /// Get light theme with accessibility options
  static ThemeData getLightTheme({
    bool largeText = false,
    bool highContrast = false,
    bool simplified = false,
    double textSizeMultiplier = 1.0,
    Locale? locale,
  }) {
    final baseTheme = _buildLightThemeBase(locale);

    // Apply text size multiplier
    final textTheme = baseTheme.textTheme.apply(
      fontSizeFactor: textSizeMultiplier.clamp(1.0, 3.0),
    );

    // Apply large text mode (minimum 48pt)
    final largeTextTheme = largeText
        ? textTheme.copyWith(
            bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 48),
            bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 40),
            bodySmall: textTheme.bodySmall?.copyWith(fontSize: 36),
          )
        : textTheme;

    // Apply high contrast
    ColorScheme colorScheme = baseTheme.colorScheme;
    if (highContrast) {
      colorScheme = colorScheme.copyWith(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryDark,
        error: AppColors.errorRed,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onError: Colors.white,
        // WCAG AAA requires 7:1 contrast ratio
        onSurface: Colors.white,
        surface: Colors.black,
      );
    }

    // Apply simplified mode (larger buttons, more spacing)
    final buttonStyle = simplified
        ? ElevatedButton.styleFrom(
            minimumSize: const Size(88, 56), // Larger touch targets
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          )
        : baseTheme.elevatedButtonTheme.style;

    return baseTheme.copyWith(
      textTheme: largeTextTheme,
      colorScheme: colorScheme,
      elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
    );
  }

  static ThemeData get lightTheme {
    return getLightTheme();
  }

  static ThemeData _buildLightThemeBase(Locale? locale) {
    // Determine font family based on locale
    // We use a base text theme to apply GoogleFonts to
    TextTheme baseTextTheme = Typography.material2021().black;
    
    if (locale?.languageCode == 'ar') {
      try {
        baseTextTheme = GoogleFonts.cairoTextTheme(baseTextTheme);
      } catch (e) {
        // Fallback if GoogleFonts fails to load or package missing
        baseTextTheme = baseTextTheme.apply(fontFamily: 'Cairo');
      }
    } else {
      try {
        baseTextTheme = GoogleFonts.interTextTheme(baseTextTheme);
      } catch (e) {
        baseTextTheme = baseTextTheme.apply(fontFamily: 'Inter');
      }
    }

    return ThemeData(
      useMaterial3: true,
      // fontFamily is less reliable than textTheme for GoogleFonts
      typography: Typography.material2021(), 
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryDark,
        error: AppColors.errorRed,
        surface: AppColors.lightSurface,
        onPrimary: Colors.black, // Black text on green background
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: AppColors.lightTextPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.lightTextPrimary),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: AppColors.lightTextPrimary),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: AppColors.lightTextPrimary),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: AppColors.lightTextPrimary),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.lightTextPrimary),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: AppColors.lightTextPrimary),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.lightTextPrimary),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.lightTextPrimary),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.lightTextPrimary),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.lightTextPrimary),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.lightTextSecondary),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.lightTextPrimary),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: AppColors.lightTextSecondary),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: AppColors.lightTextSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightTextPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.black, // Black text on green
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.lightBorderMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderLight,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.lightTextSecondary,
        elevation: 8,
      ),
    );
  }

  /// Get dark theme with accessibility options
  static ThemeData getDarkTheme({
    bool largeText = false,
    bool highContrast = false,
    bool simplified = false,
    double textSizeMultiplier = 1.0,
    Locale? locale,
  }) {
    final baseTheme = _buildDarkThemeBase(locale);

    // Apply text size multiplier
    final textTheme = baseTheme.textTheme.apply(
      fontSizeFactor: textSizeMultiplier.clamp(1.0, 3.0),
    );

    // Apply large text mode
    final largeTextTheme = largeText
        ? textTheme.copyWith(
            bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 48),
            bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 40),
            bodySmall: textTheme.bodySmall?.copyWith(fontSize: 36),
          )
        : textTheme;

    // Apply high contrast
    ColorScheme colorScheme = baseTheme.colorScheme;
    if (highContrast) {
      colorScheme = colorScheme.copyWith(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryDark,
        error: AppColors.errorRed,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: Colors.white,
        surface: const Color(0xFF1A1A1A),
      );
    }

    // Apply simplified mode
    final buttonStyle = simplified
        ? ElevatedButton.styleFrom(
            minimumSize: const Size(88, 56),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          )
        : baseTheme.elevatedButtonTheme.style;

    return baseTheme.copyWith(
      textTheme: largeTextTheme,
      colorScheme: colorScheme,
      elevatedButtonTheme: ElevatedButtonThemeData(style: buttonStyle),
    );
  }
  
  static ThemeData get darkTheme {
    return getDarkTheme();
  }

  static ThemeData _buildDarkThemeBase(Locale? locale) {
    // Determine font family based on locale
    TextTheme baseTextTheme = Typography.material2021().white;

    if (locale?.languageCode == 'ar') {
      try {
        baseTextTheme = GoogleFonts.cairoTextTheme(baseTextTheme);
      } catch (e) {
        baseTextTheme = baseTextTheme.apply(fontFamily: 'Cairo');
      }
    } else {
      try {
        baseTextTheme = GoogleFonts.interTextTheme(baseTextTheme);
      } catch (e) {
        baseTextTheme = baseTextTheme.apply(fontFamily: 'Inter');
      }
    }

    return ThemeData(
      useMaterial3: true,
      typography: Typography.material2021(),
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryDark,
        error: AppColors.errorRed,
        surface: AppColors.darkSurface,
        onPrimary: Colors.black, // Black text on green background
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.darkTextPrimary),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: AppColors.darkTextPrimary),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: AppColors.darkTextPrimary),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: AppColors.darkTextPrimary),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: AppColors.darkTextPrimary),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.darkTextPrimary),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: AppColors.darkTextSecondary),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.darkTextPrimary),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: AppColors.darkTextSecondary),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: AppColors.darkTextSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardAlt, // Use input-specific dark color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.black, // Black text on green
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.darkBorderMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderLight,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.darkTextSecondary,
        elevation: 8,
      ),
    );
  }
}
