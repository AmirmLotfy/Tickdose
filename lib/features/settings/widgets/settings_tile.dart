import 'package:flutter/material.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/icons/app_icons.dart';
import 'package:tickdose/core/constants/dimens.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(Dimens.spaceXs),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primaryGreen).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimens.radiusSm),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.primaryGreen,
          size: Dimens.iconSm,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: Dimens.fontSm,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: Dimens.fontXs,
                color: AppColors.textSecondary(context),
              ),
            )
          : null,
      trailing: trailing ??
          AppIcons.themedIcon(
            context,
            AppIcons.chevronRight(),
            color: AppColors.textSecondary(context),
            autoMirror: true,
          ),
      onTap: onTap,
    );
  }
}
