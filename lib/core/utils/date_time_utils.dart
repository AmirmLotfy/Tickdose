import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format date to string
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd', String? locale}) {
    if (locale != null) {
      return DateFormat(format, locale).format(date);
    }
    return DateFormat(format).format(date);
  }
  
  // Format time to string
  static String formatTime(DateTime time, {String? locale}) {
    if (locale != null) {
      return DateFormat('HH:mm', locale).format(time);
    }
    return DateFormat('HH:mm').format(time);
  }
  
  // Format to display format (locale-aware)
  static String formatDisplayDate(DateTime date, {String? locale}) {
    if (locale != null) {
      return DateFormat.yMMMd(locale).format(date);
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  // Format to display date and time (locale-aware)
  static String formatDisplayDateTime(DateTime dateTime, {String? locale}) {
    if (locale != null) {
      return DateFormat.yMMMd(locale).add_Hm().format(dateTime);
    }
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
  
  // Format date with context for locale
  static String formatDisplayDateWithContext(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return formatDisplayDate(date, locale: locale);
  }
  
  // Format date and time with context for locale
  static String formatDisplayDateTimeWithContext(DateTime dateTime, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return formatDisplayDateTime(dateTime, locale: locale);
  }
  
  // Format time with context for locale
  static String formatTimeWithContext(DateTime time, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return formatTime(time, locale: locale);
  }
  
  // Calculate days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  // Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }
  
  // Check if time is in quiet hours
  static bool isInQuietHours(String time, int quietStart, int quietEnd) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    
    if (quietStart < quietEnd) {
      // e.g., 22:00 - 08:00 (crosses midnight)
      return hour >= quietStart || hour < quietEnd;
    } else {
      // e.g., 08:00 - 22:00 (same day)
      return hour >= quietStart && hour < quietEnd;
    }
  }
  
  // Get time ago string
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
