import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../theme/app_theme.dart';

/// Centralized icon system using Ionicons with medical theme
/// All icons respect dark/light mode through theme-aware colors
class AppIcons {
  // Navigation Icons
  static IconData home({bool filled = false}) => filled ? Ionicons.home : Ionicons.home_outline;
  static IconData reminders({bool filled = false}) => filled ? Ionicons.calendar : Ionicons.calendar_outline;
  static IconData tracking({bool filled = false}) => filled ? Ionicons.stats_chart : Ionicons.stats_chart_outline;
  static IconData pharmacy({bool filled = false}) => filled ? Ionicons.medical : Ionicons.medical_outline;
  static IconData profile({bool filled = false}) => filled ? Ionicons.person : Ionicons.person_outline;

  // Medicine Icons
  static IconData medicine({bool filled = false}) => filled ? Ionicons.medical : Ionicons.medical_outline;
  static IconData medication({bool filled = false}) => filled ? Ionicons.medical : Ionicons.medical_outline;
  static IconData add({bool filled = false}) => filled ? Ionicons.add_circle : Ionicons.add_circle_outline;
  static IconData delete({bool filled = false}) => filled ? Ionicons.trash : Ionicons.trash_outline;
  static IconData edit({bool filled = false}) => filled ? Ionicons.create : Ionicons.create_outline;

  // Reminder Icons
  static IconData alarm({bool filled = false}) => filled ? Ionicons.alarm : Ionicons.alarm_outline;
  static IconData time({bool filled = false}) => filled ? Ionicons.time : Ionicons.time_outline;
  static IconData notifications({bool filled = false}) => filled ? Ionicons.notifications : Ionicons.notifications_outline;

  // Health & Medical Icons
  static IconData medical({bool filled = false}) => filled ? Ionicons.medical : Ionicons.medical_outline;
  static IconData hospital({bool filled = false}) => filled ? Ionicons.medical : Ionicons.medical_outline;
  static IconData bandage({bool filled = false}) => filled ? Ionicons.bandage : Ionicons.bandage_outline;

  // Location Icons
  static IconData location({bool filled = false}) => filled ? Ionicons.location : Ionicons.location_outline;
  static IconData navigate({bool filled = false}) => filled ? Ionicons.navigate : Ionicons.navigate_outline;
  static IconData locationOff({bool filled = false}) => filled ? Ionicons.location : Ionicons.location_outline;

  // I Feel / Symptoms Icons
  static IconData symptoms({bool filled = false}) => filled ? Ionicons.medical : Ionicons.medical_outline;
  static IconData mic({bool filled = false}) => filled ? Ionicons.mic : Ionicons.mic_outline;
  static IconData stop({bool filled = false}) => filled ? Ionicons.stop : Ionicons.stop_outline;

  // Tracking Icons
  static IconData pieChart({bool filled = false}) => filled ? Ionicons.pie_chart : Ionicons.pie_chart_outline;
  static IconData statsChart({bool filled = false}) => filled ? Ionicons.stats_chart : Ionicons.stats_chart_outline;
  static IconData trendingUp({bool filled = false}) => filled ? Ionicons.trending_up : Ionicons.trending_up_outline;
  static IconData flame({bool filled = false}) => filled ? Ionicons.flame : Ionicons.flame_outline;

  // Action Icons
  static IconData check({bool filled = false}) => filled ? Ionicons.checkmark_circle : Ionicons.checkmark_circle_outline;
  static IconData close({bool filled = false}) => filled ? Ionicons.close_circle : Ionicons.close_circle_outline;
  static IconData chevronRight({bool filled = false}) => filled ? Ionicons.chevron_forward : Ionicons.chevron_forward_outline;
  static IconData arrowForward({bool filled = false}) => filled ? Ionicons.arrow_forward : Ionicons.arrow_forward_outline;

  // Auth Icons
  static IconData email({bool filled = false}) => filled ? Ionicons.mail : Ionicons.mail_outline;
  static IconData lock({bool filled = false}) => filled ? Ionicons.lock_closed : Ionicons.lock_closed_outline;
  static IconData visibility({bool filled = false}) => filled ? Ionicons.eye : Ionicons.eye_outline;
  static IconData visibilityOff({bool filled = false}) => filled ? Ionicons.eye_off : Ionicons.eye_off_outline;
  static IconData fingerprint({bool filled = false}) => filled ? Ionicons.finger_print : Ionicons.finger_print_outline;

  // Settings Icons
  static IconData settings({bool filled = false}) => filled ? Ionicons.settings : Ionicons.settings_outline;
  static IconData privacy({bool filled = false}) => filled ? Ionicons.shield_checkmark : Ionicons.shield_checkmark_outline;
  static IconData help({bool filled = false}) => filled ? Ionicons.help_circle : Ionicons.help_circle_outline;
  static IconData info({bool filled = false}) => filled ? Ionicons.information_circle : Ionicons.information_circle_outline;

  // Emergency & Warning Icons
  static IconData warning({bool filled = false}) => filled ? Ionicons.warning : Ionicons.warning_outline;
  static IconData emergency({bool filled = false}) => filled ? Ionicons.warning : Ionicons.warning_outline;

  // Other Icons
  static IconData phone({bool filled = false}) => filled ? Ionicons.call : Ionicons.call_outline;
  static IconData language({bool filled = false}) => filled ? Ionicons.language : Ionicons.language_outline;
  static IconData directions({bool filled = false}) => filled ? Ionicons.navigate : Ionicons.navigate_outline;
  static IconData map({bool filled = false}) => filled ? Ionicons.map : Ionicons.map_outline;
  static IconData list({bool filled = false}) => filled ? Ionicons.list : Ionicons.list_outline;
  static IconData history({bool filled = false}) => filled ? Ionicons.time : Ionicons.time_outline;
  static IconData share({bool filled = false}) => filled ? Ionicons.share : Ionicons.share_outline;
  static IconData send({bool filled = false}) => filled ? Ionicons.send : Ionicons.send_outline;
  static IconData pdf({bool filled = false}) => filled ? Ionicons.document : Ionicons.document_outline;
  static IconData note({bool filled = false}) => filled ? Ionicons.document_text : Ionicons.document_text_outline;
  static IconData business({bool filled = false}) => filled ? Ionicons.business : Ionicons.business_outline;
  static IconData person({bool filled = false}) => filled ? Ionicons.person : Ionicons.person_outline;
  static IconData swipe({bool filled = false}) => filled ? Ionicons.swap_horizontal : Ionicons.swap_horizontal_outline;
  static IconData play({bool filled = false}) => filled ? Ionicons.play_circle : Ionicons.play_circle_outline;
  static IconData restore({bool filled = false}) => filled ? Ionicons.refresh : Ionicons.refresh_outline;
  static IconData bug({bool filled = false}) => filled ? Ionicons.bug : Ionicons.bug_outline;
  static IconData gavel({bool filled = false}) => filled ? Ionicons.hammer : Ionicons.hammer_outline;
  static IconData camera({bool filled = false}) => filled ? Ionicons.camera : Ionicons.camera_outline;
  static IconData image({bool filled = false}) => filled ? Ionicons.image : Ionicons.image_outline;
  static IconData brokenImage({bool filled = false}) => filled ? Ionicons.image : Ionicons.image_outline;
  static IconData speed({bool filled = false}) => filled ? Ionicons.speedometer : Ionicons.speedometer_outline;
  static IconData volume({bool filled = false}) => filled ? Ionicons.volume_high : Ionicons.volume_high_outline;
  static IconData sentiment({bool filled = false}) => filled ? Ionicons.happy : Ionicons.happy_outline;
  static IconData celebration({bool filled = false}) => filled ? Ionicons.balloon : Ionicons.balloon_outline;
  static IconData sound({bool filled = false}) => filled ? Ionicons.musical_notes : Ionicons.musical_notes_outline;
  static IconData flash({bool filled = false}) => filled ? Ionicons.flash : Ionicons.flash_outline;

  /// Helper method to get theme-aware icon color
  static Color iconColor(BuildContext context, {Color? override}) {
    if (override != null) return override;
    return Theme.of(context).iconTheme.color ?? AppColors.textPrimary(context);
  }

  /// Helper method to get secondary icon color (theme-aware)
  static Color iconSecondaryColor(BuildContext context) {
    return AppColors.textSecondary(context);
  }

  /// Helper method to create an Icon widget with theme-aware color
  static Widget themedIcon(
    BuildContext context,
    IconData icon, {
    double? size,
    Color? color,
    bool autoMirror = false,
  }) {
    final widget = Icon(
      icon,
      size: size ?? 24,
      color: color ?? iconColor(context),
    );

    if (autoMirror && Directionality.of(context) == TextDirection.rtl) {
      return Transform.flip(flipX: true, child: widget);
    }
    return widget;
  }
}
