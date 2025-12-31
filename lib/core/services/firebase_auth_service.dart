import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_user_service.dart';
import 'biometric_auth_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUserService _userService = FirebaseUserService();
  // GoogleSignIn configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Creates user profile in Firestore (called after registration)
  Future<void> createUserProfile(User user, String displayName) async {
    await _userService.createUserProfile(user, displayName);
  }

  Future<void> signOut() async {
    // Sign out from Google Sign-In (if user signed in with Google)
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore if not signed in with Google or if sign out fails
    }
    
    // Sign out from Firebase Auth
    await _auth.signOut();
    
    // Clear all Hive boxes to remove cached data
    try {
      final boxes = Hive.box('userPrefs');
      await boxes.clear();
    } catch (e) {
      // Box might not exist, ignore
    }
    
    // Clear biometric credentials on sign out
    try {
      final biometricService = BiometricAuthService();
      await biometricService.clearStoredCredentials();
    } catch (e) {
      // Ignore if biometric service fails
    }
  }

  // OAuth Methods
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the auth flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign-In cancelled by user');
      }
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      // Note: accessToken is deprecated/removed in newer google_sign_in_platform_interface
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken, 
      );
      
      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create user profile in Firestore if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await createUserProfile(
          userCredential.user!,
          googleUser.displayName ?? 'User',
        );
      }
      
      return userCredential;
    } catch (e) {
      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      // Check if running on iOS
      if (!Platform.isIOS) {
        throw Exception('Apple Sign-In is only available on iOS devices');
      }

      // Use Firebase Auth's native Apple Sign-In (iOS 13+)
      // This uses the native Sign in with Apple flow
      final appleProvider = OAuthProvider("apple.com");
      
      // Trigger the sign-in flow
      // On iOS, this will show the native Apple Sign-In dialog
      final userCredential = await _auth.signInWithProvider(appleProvider);
      
      // Create user profile in Firestore if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final displayName = userCredential.user?.displayName ?? 
                           userCredential.user?.email?.split('@').first ?? 
                           'User';
        await createUserProfile(
          userCredential.user!,
          displayName,
        );
      }
      
      return userCredential;
    } catch (e) {
      if (e.toString().contains('cancelled') || e.toString().contains('canceled')) {
        throw Exception('Apple Sign-In was cancelled');
      }
      throw Exception('Apple Sign-In failed: ${e.toString()}');
    }
  }

  // Email Verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> confirmPasswordReset(String code, String newPassword) async {
    await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }

  // Passwordless Authentication (Magic Links)
  Future<void> sendSignInLinkToEmail(String email, {String? url, String? handleCodeInApp}) async {
    final actionCodeSettings = ActionCodeSettings(
      url: url ?? 'https://tickdose.app/complete-signin',
      handleCodeInApp: handleCodeInApp != null ? handleCodeInApp == 'true' : true,
      androidPackageName: 'com.tickdose.app',
      iOSBundleId: 'com.tickdose.app',
    );
    
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  Future<UserCredential> signInWithEmailLink(String email, String link) async {
    // Verify the link is valid
    if (_auth.isSignInWithEmailLink(link)) {
      // Sign in with the link
      final userCredential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: link,
      );
      
      // Create user profile in Firestore if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final displayName = userCredential.user?.displayName ?? 
                           userCredential.user?.email?.split('@').first ?? 
                           'User';
        await createUserProfile(
          userCredential.user!,
          displayName,
        );
      }
      
      return userCredential;
    } else {
      throw Exception('Invalid sign-in link');
    }
  }

  // Check if link is a sign-in with email link
  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  // In-app password reset (requires reauthentication)
  Future<void> updatePasswordInApp(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    
    if (user.email == null) {
      throw Exception('User email not available');
    }
    
    // Reauthenticate user
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    
    await user.reauthenticateWithCredential(credential);
    
    // Update password
    await user.updatePassword(newPassword);
  }
}
