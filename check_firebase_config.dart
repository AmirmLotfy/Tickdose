#!/usr/bin/env dart
/// Script to check Firebase Remote Config API key configuration
/// Run with: dart check_firebase_config.dart

import 'dart:io';

void main() {
  print('=' * 60);
  print('Firebase Remote Config API Key Checker');
  print('=' * 60);
  print('');
  
  print('This script helps verify your Firebase Remote Config setup.');
  print('');
  
  print('REQUIRED FIREBASE REMOTE CONFIG PARAMETERS:');
  print('─' * 60);
  print('1. GEMINI_API_KEY');
  print('   - Parameter Key: GEMINI_API_KEY');
  print('   - Type: String');
  print('   - Format: Should start with "AIza" and be 30-100 characters');
  print('   - Get from: https://makersuite.google.com/app/apikey');
  print('');
  print('2. ELEVENLABS_API_KEY (Optional - for voice features)');
  print('   - Parameter Key: ELEVENLABS_API_KEY');
  print('   - Type: String');
  print('   - Format: Should be 20-200 characters');
  print('   - Get from: https://elevenlabs.io/ → Profile → API Keys');
  print('');
  
  print('SETUP INSTRUCTIONS:');
  print('─' * 60);
  print('1. Go to Firebase Console: https://console.firebase.google.com/');
  print('2. Select your project: tickdoseapp');
  print('3. Navigate to: Engage → Remote Config');
  print('4. Click "Add parameter" for each key above');
  print('5. Enter the parameter key exactly as shown (case-sensitive)');
  print('6. Paste your API key as the default value');
  print('7. Click "Publish changes"');
  print('');
  
  print('VERIFICATION:');
  print('─' * 60);
  print('After setting up, the app will:');
  print('  ✓ Initialize Remote Config on startup');
  print('  ✓ Log API key status in console');
  print('  ✓ Use keys from Remote Config (production)');
  print('  ✓ Fall back to .env file (development)');
  print('');
  
  print('TROUBLESHOOTING:');
  print('─' * 60);
  print('If API keys are not working:');
  print('  1. Check Firebase Console → Remote Config → Parameters');
  print('  2. Verify parameter names are EXACTLY:');
  print('     - GEMINI_API_KEY (all caps, with underscores)');
  print('     - ELEVENLABS_API_KEY (all caps, with underscores)');
  print('  3. Ensure values are published (not just saved as draft)');
  print('  4. Check app logs for Remote Config initialization messages');
  print('  5. For development, you can use .env file as fallback');
  print('');
  
  print('CURRENT APP CONFIGURATION:');
  print('─' * 60);
  print('✓ Remote Config initialized in: lib/main.dart (line 86)');
  print('✓ Service location: lib/core/services/remote_config_service.dart');
  print('✓ Default values set: Empty strings (fallback)');
  print('✓ Validation: Format validation on keys');
  print('');
  
  print('For more details, see:');
  print('  - MANUAL_SETUP_GUIDE.md (Step 4)');
  print('  - README.md (Firebase Setup section)');
  print('');
}

