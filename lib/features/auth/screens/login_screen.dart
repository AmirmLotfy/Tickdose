import 'package:flutter/material.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/features/auth/providers/auth_provider.dart';
import 'package:tickdose/core/services/biometric_auth_service.dart';
import 'package:tickdose/core/utils/auth_error_messages.dart';
import 'package:tickdose/features/settings/screens/privacy_settings_screen.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _isEmailFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus && _emailController.text.isNotEmpty;
      });
    });
    _emailController.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus && _emailController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      await ref.read(authProvider.notifier).signIn(email, password);

      // Store credentials for biometric login if enabled
      final biometricEnabled = ref.read(biometricEnabledProvider);
      if (biometricEnabled && mounted) {
        try {
          final biometricService = BiometricAuthService();
          await biometricService.storeCredentials(email, password);
        } catch (e) {
          // Log but don't block login if credential storage fails
          Logger.error('Failed to store credentials: $e', tag: 'LoginScreen', error: e);
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = AuthErrorMessages.getLoginErrorMessage(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() => isLoading = true);

    try {
      final biometricService = BiometricAuthService();
      
      // Check if biometric is available
      final canUse = await biometricService.canUseBiometric();
      if (!canUse) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.biometricNotAvailable),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return;
      }

      // Check if credentials are stored
      final hasCredentials = await biometricService.hasStoredCredentials();
      if (!hasCredentials) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.biometricEnablePrompt),
              backgroundColor: AppColors.warningOrange,
            ),
          );
        }
        return;
      }

      // Perform biometric authentication and get credentials
      final credentials = await biometricService.performBiometricLogin();
      if (credentials == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.biometricAuthFailed),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return;
      }

      // Sign in with stored credentials
      await ref.read(authProvider.notifier).signIn(
        credentials['email']!,
        credentials['password']!,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = AuthErrorMessages.getLoginErrorMessage(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.biometricLoginFailed(errorMessage)),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Sticky header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textPrimary(context),
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.logInTitle,
                      style: AppTextStyles.h3(context).copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      // Logo/Icon Section
                      Center(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/tickdose-logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome back to Tickdose',
                              style: AppTextStyles.h2(context).copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your meds, manage your life.',
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                color: AppColors.textSecondary(context),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        AppLocalizations.of(context)!.emailLabel,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        TextFormField(
                          key: const Key('login_email_field'),
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkCardAlt
                                : AppColors.cardColor(context),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkBorderLight
                                    : AppColors.borderLight(context),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkBorderLight
                                    : AppColors.borderLight(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGreen,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 0,
                            ),
                            constraints: const BoxConstraints(
                              minHeight: 56, // h-14
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.emailValidation;
                            }
                            return null;
                          },
                        ),
                        // Check circle icon on focus
                        if (_isEmailFocused)
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: _isEmailFocused ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
                      child: Text(
                        AppLocalizations.of(context)!.passwordLabel,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextFormField(
                      key: const Key('login_password_field'),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkCardAlt
                            : AppColors.cardColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkBorderLight
                                : AppColors.borderLight(context),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkBorderLight
                                : AppColors.borderLight(context),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 0,
                        ),
                        constraints: const BoxConstraints(
                          minHeight: 56, // h-14
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 4),
                          child: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary(context),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.passwordValidation;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.forgotPassword);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.forgotPasswordButton,
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                      const SizedBox(height: 32),
                      // Login Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.15),
                              blurRadius: 15,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          key: const Key('login_button'),
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.darkBackground,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary(context)),
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.loginButton,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                
                // DEBUG ONLY: Auto-login button for Robo Test
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    key: const Key('debug_auto_login'),
                    onPressed: isLoading ? null : () async {
                      setState(() => isLoading = true);
                      try {
                        await ref.read(authProvider.notifier).signIn(
                          'mobishopy@gmail.com',
                          '112233//Al.com',
                        );
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, Routes.home);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Auto-login failed: ${e.toString()}'),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
                    icon: Icon(AppIcons.bug()),
                    label: const Text('🤖 DEBUG AUTO-LOGIN (Test Only)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warningOrange,
                      side: const BorderSide(color: AppColors.warningOrange),
                    ),
                  ),
                ],
                      const SizedBox(height: 16),
                      // Passwordless Login Option
                      TextButton(
                        onPressed: isLoading ? null : () {
                          Navigator.pushNamed(context, Routes.passwordlessLogin);
                        },
                        child: Text(
                          'Sign in with email link (passwordless)',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.borderLight(context)
                                  : AppColors.borderLight(context),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              AppLocalizations.of(context)!.orContinueWith,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.borderLight(context)
                                  : AppColors.borderLight(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Google Sign-In Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowColor(context),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () async {
                            setState(() => isLoading = true);
                            try {
                              await ref.read(authProvider.notifier).signInWithGoogle();
                              if (!context.mounted) return;
                              
                              // Google Sign-In emails are already verified, go directly to home
                              Navigator.pushReplacementNamed(context, Routes.home);
                            } catch (e) {
                              if (!context.mounted) return;
                              final errorMessage = AuthErrorMessages.getReadableError(e);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: AppColors.errorRed,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            side: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.borderLight(context)
                                  : AppColors.borderLight(context),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkCardAlt
                                : AppColors.cardColor(context),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/google_g.svg',
                                height: 24,
                                width: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)!.continueGoogle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: '${AppLocalizations.of(context)!.newHere} ',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 14,
                            ),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, Routes.register);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.createAccount,
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.primaryGreen.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
