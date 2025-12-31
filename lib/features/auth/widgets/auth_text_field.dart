import 'package:flutter/material.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/constants/dimens.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? hint; // Alias for hintText for backward compatibility
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool? isPassword; // Alias for obscureText for backward compatibility
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.hint, // Support both for backward compatibility
    this.keyboardType,
    this.obscureText = false,
    this.isPassword, // Support both for backward compatibility
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimens.fontSm,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: Dimens.spaceXs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ?? obscureText, // Use isPassword if provided, otherwise obscureText
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint ?? hintText, // Use hint if provided, otherwise hintText
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCardAlt // Use input-specific dark color
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorderLight
                    : AppColors.borderLight(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorderLight
                    : AppColors.borderLight(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimens.spaceMd,
              vertical: 0,
            ),
            constraints: const BoxConstraints(
              minHeight: 56, // h-14
            ),
          ),
        ),
      ],
    );
  }
}
