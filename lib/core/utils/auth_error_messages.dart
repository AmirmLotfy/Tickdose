/// Utility class for translating Firebase Auth error codes to user-friendly messages
class AuthErrorMessages {
  /// Translates Firebase Auth error codes to readable messages
  static String getReadableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Email/Password errors
    if (errorString.contains('user-not-found')) {
      return 'No account found with this email address.';
    }
    if (errorString.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }
    if (errorString.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (errorString.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (errorString.contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    
    // Account errors
    if (errorString.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    }
    if (errorString.contains('account-exists-with-different-credential')) {
      return 'An account already exists with this email using a different sign-in method.';
    }
    
    // Network errors
    if (errorString.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    
    // Verification errors
    if (errorString.contains('email-not-verified')) {
      return 'Please verify your email before continuing.';
    }
    
    // OAuth errors
    if (errorString.contains('popup-closed-by-user')) {
      return 'Sign-in was cancelled.';
    }
    if (errorString.contains('cancelled') || errorString.contains('canceled')) {
      return 'Sign-in was cancelled.';
    }
    
    // Session errors
    if (errorString.contains('requires-recent-login')) {
      return 'For security, please log in again to continue.';
    }
    if (errorString.contains('session-expired')) {
      return 'Your session has expired. Please log in again.';
    }
    
    // Unknown errors
    return 'An error occurred. Please try again.';
  }
  
  /// Gets a user-friendly message for email verification status
  static String getVerificationMessage(bool isVerified) {
    if (isVerified) {
      return 'Your email has been verified successfully!';
    }
    return 'Please verify your email to continue using the app.';
  }
  
  /// Gets a message for password reset
  static String getPasswordResetMessage(String email) {
    return 'Password reset link sent to $email. Please check your inbox.';
  }
  
  /// Alias for getReadableError (backward compatibility)
  static String getLoginErrorMessage(String error) {
    return getReadableError(error);
  }
  
  /// Alias for getReadableError (backward compatibility)
  static String getErrorMessage(String error) {
    return getReadableError(error);
  }
}
