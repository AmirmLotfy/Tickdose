import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../settings/screens/privacy_settings_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_constants.dart';
import '../../navigation/routes/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    Logger.info('Splash screen initialized');
    _initAnimations();
    _checkAuthStatus();
  }

  void _initAnimations() {
    // Logo fade and scale animation (1.0s)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    // Progress bar animation (1.5s infinite)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for animations and tagline to finish (min 3 seconds total)
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    try {
      // Check current Firebase Auth state using currentUser (synchronous)
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // User is logged in
        if (!user.emailVerified) {
          Logger.info('User not verified, showing verification screen');
          Navigator.pushReplacementNamed(context, Routes.emailVerification);
        } else {
          Logger.info('User verified, going to home');
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      } else {
        // No user logged in - check for biometric login
        final biometricEnabled = ref.read(biometricEnabledProvider);
        if (biometricEnabled) {
          await _attemptBiometricLogin();
        } else {
          Logger.info('No user, showing onboarding');
          Navigator.pushReplacementNamed(context, Routes.onboarding);
        }
      }
    } catch (e) {
      Logger.error('Auth check error: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.onboarding);
      }
    }
  }

  Future<void> _attemptBiometricLogin() async {
    try {
      final biometricService = BiometricAuthService();
      
      // Check if credentials are stored
      final hasCredentials = await biometricService.hasStoredCredentials();
      if (!hasCredentials) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, Routes.onboarding);
        }
        return;
      }

      // Perform biometric authentication and get credentials
      final credentials = await biometricService.performBiometricLogin();
      if (credentials == null) {
        // Biometric failed or cancelled, go to login
        if (mounted) {
          Navigator.pushReplacementNamed(context, Routes.login);
        }
        return;
      }

      // Sign in with stored credentials
      await ref.read(authProvider.notifier).signIn(
        credentials['email']!,
        credentials['password']!,
      );

      // Check if login was successful
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        if (!user.emailVerified) {
          Navigator.pushReplacementNamed(context, Routes.emailVerification);
        } else {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      } else if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    } catch (e) {
      Logger.error('Error initializing app: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with simple scale animation
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    final logoSize = screenWidth * 0.3;
                    final logoSizeClamped = logoSize.clamp(120.0, 160.0);
                    
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: logoSizeClamped,
                        height: logoSizeClamped,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowColor(context).withValues(alpha: 0.2),
                              blurRadius: 24,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/tickdose-logo.png',
                            width: logoSizeClamped,
                            height: logoSizeClamped,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Subtle loading indicator
                SizedBox(
                  width: 120,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight(context),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        double progress;
                        if (_progressAnimation.value < 0.5) {
                          progress = _progressAnimation.value * 2;
                        } else {
                          progress = 1.0 - ((_progressAnimation.value - 0.5) * 2);
                        }
                        
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                // Version number at bottom
                Text(
                  'v${AppConstants.appVersion}',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


