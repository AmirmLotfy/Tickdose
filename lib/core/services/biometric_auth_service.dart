import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _emailKey = 'biometric_email';
  static const String _passwordKey = 'biometric_password';

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      Logger.error('Error checking biometrics availability: $e', tag: 'BiometricAuth');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      Logger.error('Error getting available biometrics: $e', tag: 'BiometricAuth');
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to login to TICKDOSE',
      );
    } on PlatformException catch (e) {
      Logger.error('Error authenticating: $e', tag: 'BiometricAuth');
      return false;
    }
  }

  /// Store credentials securely for biometric login
  Future<void> storeCredentials(String email, String password) async {
    try {
      await _secureStorage.write(key: _emailKey, value: email);
      await _secureStorage.write(key: _passwordKey, value: password);
      Logger.info('Credentials stored securely', tag: 'BiometricAuth');
    } catch (e) {
      Logger.error('Error storing credentials: $e', tag: 'BiometricAuth');
      rethrow;
    }
  }

  /// Retrieve stored credentials
  Future<Map<String, String>?> getStoredCredentials() async {
    try {
      final email = await _secureStorage.read(key: _emailKey);
      final password = await _secureStorage.read(key: _passwordKey);
      
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
      return null;
    } catch (e) {
      Logger.error('Error retrieving credentials: $e', tag: 'BiometricAuth');
      return null;
    }
  }

  /// Check if credentials are stored
  Future<bool> hasStoredCredentials() async {
    final credentials = await getStoredCredentials();
    return credentials != null;
  }

  /// Clear stored credentials
  Future<void> clearStoredCredentials() async {
    try {
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _passwordKey);
      Logger.info('Credentials cleared', tag: 'BiometricAuth');
    } catch (e) {
      Logger.error('Error clearing credentials: $e', tag: 'BiometricAuth');
    }
  }

  /// Perform biometric login - authenticates and returns stored credentials
  Future<Map<String, String>?> performBiometricLogin() async {
    try {
      // Check if credentials are stored
      final credentials = await getStoredCredentials();
      if (credentials == null) {
        Logger.warning('No stored credentials found', tag: 'BiometricAuth');
        return null;
      }

      // Perform biometric authentication
      final authenticated = await authenticate();
      if (!authenticated) {
        Logger.warning('Biometric authentication failed', tag: 'BiometricAuth');
        return null;
      }

      // Return credentials if authentication successful
      return credentials;
    } catch (e) {
      Logger.error('Error performing biometric login: $e', tag: 'BiometricAuth');
      return null;
    }
  }
  
  /// Alias for isBiometricAvailable (backward compatibility)
  Future<bool> canUseBiometric() async {
    return await isBiometricAvailable();
  }
}
