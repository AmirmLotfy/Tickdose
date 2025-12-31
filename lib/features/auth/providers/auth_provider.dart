import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_auth_service.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

final authProvider = AsyncNotifierProvider<AuthNotifier, void>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<void> {
  late final FirebaseAuthService _authService;

  @override
  Future<void> build() async {
    _authService = ref.read(firebaseAuthServiceProvider);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signInWithEmailAndPassword(email, password));
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Create user in Firebase Auth
      final credential = await _authService.createUserWithEmailAndPassword(email, password);
      
      // Update display name in Firebase Auth
      await credential.user?.updateDisplayName(fullName);
      
      // CRITICAL: Create user profile in Firestore
      if (credential.user != null) {
        await _authService.createUserProfile(credential.user!, fullName);
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signOut());
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signInWithGoogle());
  }



  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.sendPasswordResetEmail(email));
  }

  Future<bool> checkEmailVerified() async {
    await _authService.reloadUser();
    return _authService.isEmailVerified;
  }

  Future<void> sendSignInLinkToEmail(String email, {String? url, String? handleCodeInApp}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.sendSignInLinkToEmail(
      email,
      url: url,
      handleCodeInApp: handleCodeInApp,
    ));
  }

  Future<void> signInWithEmailLink(String email, String link) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signInWithEmailLink(email, link));
  }

  Future<void> updatePasswordInApp(String currentPassword, String newPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.updatePasswordInApp(currentPassword, newPassword));
  }
}
