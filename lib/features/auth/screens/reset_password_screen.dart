import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/utils/password_validator.dart';
import '../../../l10n/generated/app_localizations.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? actionCode;
  
  const ResetPasswordScreen({super.key, this.actionCode});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_validatePassword);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _newPasswordController.text;
    setState(() {
      _passwordStrength = PasswordValidator.getStrength(password);
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newPassword = _newPasswordController.text.trim();
      
      if (widget.actionCode != null) {
        // Use action code from reset link
        final authService = FirebaseAuthService();
        await authService.confirmPasswordReset(widget.actionCode!, newPassword);
      } else {
        // Try to get action code from current user or handle differently
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(newPassword);
        } else {
          throw Exception('No action code provided and no user logged in');
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordResetSuccess),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorLabel(e)}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Headline
                      Text(
                        AppLocalizations.of(context)!.createNewPassword,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Body Text
                      Text(
                        AppLocalizations.of(context)!.passwordDifferent,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // New Password Field
                      _buildPasswordField(
                        context,
                        label: AppLocalizations.of(context)!.newPassword,
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () {
                          setState(() => _obscureNewPassword = !_obscureNewPassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Password Strength Meter
                      _buildPasswordStrengthMeter(context),
                      const SizedBox(height: 20),
                      // Confirm Password Field
                      _buildPasswordField(
                        context,
                        label: AppLocalizations.of(context)!.confirmNewPassword,
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Validation Checklist
                      _buildValidationChecklist(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // Reset Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildResetButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 24),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textPrimary(context),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.resetPasswordButton,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer for centering
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderLight(context),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: '••••••••••••',
              hintStyle: TextStyle(
                color: AppColors.textSecondary(context),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary(context),
                ),
                onPressed: onToggleVisibility,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthMeter(BuildContext context) {
    final strength = _passwordStrength;
    final filledBars = strength == PasswordStrength.weak
        ? 1
        : strength == PasswordStrength.medium
            ? 2
            : strength == PasswordStrength.strong
                ? 3
                : 4;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            final isFilled = index < filledBars;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsetsDirectional.only(end: index < 3 ? 8 : 0),
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.primaryGreen
                      : Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderLight(context)
                      : AppColors.borderLight(context),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            strength == PasswordStrength.weak
                ? AppLocalizations.of(context)!.passwordWeak
                : strength == PasswordStrength.medium
                    ? AppLocalizations.of(context)!.passwordMedium
                    : strength == PasswordStrength.strong
                        ? AppLocalizations.of(context)!.passwordStrong
                        : AppLocalizations.of(context)!.passwordVeryStrong,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationChecklist(BuildContext context) {
    final password = _newPasswordController.text;
    final hasMinLength = password.length >= 8;
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.passwordRequirements,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementItem(context, hasMinLength, AppLocalizations.of(context)!.atLeast8Characters),
          const SizedBox(height: 8),
          _buildRequirementItem(context, hasNumber, AppLocalizations.of(context)!.containsNumber),
          const SizedBox(height: 8),
          _buildRequirementItem(context, hasSymbol, AppLocalizations.of(context)!.containsSymbol),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(BuildContext context, bool isMet, String text) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: isMet
              ? AppColors.primaryGreen
              : AppColors.textTertiary(context),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isMet
                ? AppColors.textSecondary(context)
                : AppColors.textTertiary(context),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 14,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.backgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBackground),
                ),
              )
            : Text(
                AppLocalizations.of(context)!.resetPasswordButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}

