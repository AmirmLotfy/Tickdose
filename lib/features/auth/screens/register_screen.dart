import 'package:flutter/material.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/auth_button.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/icons/app_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/utils/password_validator.dart';
import '../../../core/utils/auth_error_messages.dart';
import '../../navigation/routes/route_names.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _agreedToTerms = false;
  int _passwordStrengthPercentage = 0;
  bool _isEmailValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _emailFocusNode.addListener(() {
      setState(() {
        _validateEmail();
      });
    });
  }

  void _validateEmail() {
    final email = _emailController.text;
    setState(() {
      _isEmailValid = email.isNotEmpty && 
                      email.contains('@') && 
                      email.contains('.') &&
                      email.length > 5;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    setState(() {
      _passwordStrengthPercentage = PasswordValidator.getStrengthPercentage(password);
    });
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.termsAgreementValidation)),
        );
        return;
      }
      await ref.read(authProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
      
      final state = ref.read(authProvider);
      if (!mounted) return;

      if (state.hasError) {
        // Use user-friendly error message
        final errorMessage = AuthErrorMessages.getReadableError(state.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorRed,
          ),
        );
      } else if (!state.isLoading) {
        // Send email verification
        await ref.read(authProvider.notifier).sendEmailVerification();
        
        if (!mounted) return;

        // Navigate to Email Verification screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registrationSuccess),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pushReplacementNamed(context, Routes.emailVerification);
      }
    }
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) return const SizedBox.shrink();
    
    final strength = _passwordStrengthPercentage;
    // Map strength (0-100) to bars (0-4)
    final bars = (strength / 25).ceil().clamp(0, 4);
    final label = PasswordValidator.getStrengthLabel(strength);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // 4-bar strength meter
        Row(
          children: List.generate(4, (index) {
            final isActive = index < bars;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsetsDirectional.only(end: index < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryGreen
                      : AppColors.borderLight(context),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    if (_passwordController.text.isEmpty) return const SizedBox.shrink();
    
    final requirements = PasswordValidator.getRequirements(_passwordController.text);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        ...requirements.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  entry.value ? AppIcons.check() : AppIcons.close(),
                  size: 16,
                  color: entry.value ? AppColors.successGreen : AppColors.errorRed,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12,
                    color: entry.value ? AppColors.textPrimary(context) : AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.createAccount,
          style: AppTextStyles.h3(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Logo Section
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/tickdose-logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.joinTickdo,
                  style: AppTextStyles.h1(context).copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.startManagingHealth,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _nameController,
                  label: AppLocalizations.of(context)!.nameLabel,
                  hint: AppLocalizations.of(context)!.nameHint,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.nameValidation;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.emailLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
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
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.emailValidation;
                            }
                            if (!value.contains('@')) {
                              return AppLocalizations.of(context)!.emailInvalid;
                            }
                            return null;
                          },
                        ),
                        // Check circle icon when email is valid
                        if (_isEmailValid)
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Icon(
                                Icons.check_circle,
                                color: AppColors.primaryGreen,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _passwordController,
                  label: AppLocalizations.of(context)!.passwordLabel,
                  hint: AppLocalizations.of(context)!.passwordHint,
                  isPassword: true,
                  onChanged: _updatePasswordStrength,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.passwordEmpty;
                    }
                    // Use password validator
                    final error = PasswordValidator.validate(value);
                    return error; // Returns null if valid
                  },
                ),
                _buildPasswordStrengthIndicator(),
                _buildPasswordRequirements(),
                const SizedBox(height: 20),
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: AppLocalizations.of(context)!.confirmPasswordLabel,
                  hint: AppLocalizations.of(context)!.confirmPasswordHint,
                  isPassword: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return AppLocalizations.of(context)!.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.termsAgreementPrefix,
                            style: const TextStyle(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, Routes.termsOfService),
                            child: Text(
                              AppLocalizations.of(context)!.termsOfService,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.termsAgreementAnd,
                            style: const TextStyle(fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, Routes.privacyPolicy),
                            child: Text(
                              AppLocalizations.of(context)!.privacyPolicy,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryGreen,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Create Account Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: AuthButton(
                    text: AppLocalizations.of(context)!.signUpButton,
                    isLoading: isLoading,
                    onPressed: _handleRegister,
                  ),
                ),
                const SizedBox(height: 24),
                
                // OR divider
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
                
                // Social Sign-In Buttons (2-column grid)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkBorderLight
                                : AppColors.borderLight(context),
                          ),
                        ),
                        child: OutlinedButton(
                          onPressed: (_isLoading || isLoading) ? null : () async {
                            setState(() => _isLoading = true);
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
                                setState(() => _isLoading = false);
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkBorderLight
                                  : AppColors.borderLight(context),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkCardAlt
                                : AppColors.cardColor(context),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/google_g.svg',
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Google',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkBorderLight
                                : AppColors.borderLight(context),
                          ),
                        ),
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () {
                            // Apple sign-in not implemented yet
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Apple Sign-In coming soon'),
                                backgroundColor: AppColors.warningOrange,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.transparent
                                : AppColors.surfaceColor(context),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.apple,
                                size: 20,
                                color: AppColors.textPrimary(context),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Apple',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: '${AppLocalizations.of(context)!.alreadyHaveAccount ?? 'Already have an account?'} ',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.logInTitle,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
