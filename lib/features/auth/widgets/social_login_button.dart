import 'package:flutter/material.dart';
import 'package:tickdose/core/constants/dimens.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimens.buttonHeightMd,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath.endsWith('.svg'))
              SvgPicture.asset(
                iconPath,
                height: Dimens.iconSm,
                width: Dimens.iconSm,
              )
            else
              Image.asset(
                iconPath,
                height: Dimens.iconSm,
                width: Dimens.iconSm,
              ),
            const SizedBox(width: Dimens.spaceSm),
            Text(
              text,
              style: TextStyle(
                fontSize: Dimens.fontSm,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
