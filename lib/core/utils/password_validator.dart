/// Password strength enum
enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// Utility class for validating password strength
class PasswordValidator {
  /// Validates password strength and returns error message if invalid
  /// Returns null if password is valid
  static String? validate(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (password.length > 64) {
      return 'Password must be less than 64 characters';
    }
    
    // Check for uppercase
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for lowercase
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null; // Password is valid
  }
  
  /// Returns password strength enum
  static PasswordStrength getStrength(String password) {
    final strength = getStrengthPercentage(password);
    if (strength < 30) return PasswordStrength.weak;
    if (strength < 60) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
  
  /// Returns password strength as percentage (0-100)
  static int getStrengthPercentage(String password) {
    int strength = 0;
    
    if (password.isEmpty) return 0;
    
    // Length score (max 40 points)
    if (password.length >= 8) strength += 10;
    if (password.length >= 12) strength += 10;
    if (password.length >= 16) strength += 10;
    if (password.length >= 20) strength += 10;
    
    // Character variety (max 60 points)
    if (password.contains(RegExp(r'[a-z]'))) strength += 15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 15;
    
    return strength.clamp(0, 100);
  }
  
  /// Returns password strength label
  static String getStrengthLabel(int strength) {
    if (strength < 30) return 'Weak';
    if (strength < 60) return 'Fair';
    if (strength < 80) return 'Good';
    return 'Strong';
  }
  
  /// Gets list of requirements with their status
  static Map<String, bool> getRequirements(String password) {
    return {
      'At least 8 characters': password.length >= 8,
      'One uppercase letter': password.contains(RegExp(r'[A-Z]')),
      'One lowercase letter': password.contains(RegExp(r'[a-z]')),
      'One number': password.contains(RegExp(r'[0-9]')),
      'One special character': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };
  }
}
