import 'package:flutter/material.dart';

// String Extensions
extension StringExtensions on String {
  // Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  // Check if string is email
  bool get isEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(this);
  }
  
  // Check if string is phone
  bool get isPhone {
    final phoneRegex = RegExp(r'^\+?[\d\s-()]+$');
    return phoneRegex.hasMatch(this);
  }
  
  // Truncate string
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

// DateTime Extensions
extension DateTimeExtensions on DateTime {
  // Check if is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  // Check if is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  // Check if is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  // Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }
  
  // Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }
}

// BuildContext Extensions
extension BuildContextExtensions on BuildContext {
  // Get screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  // Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  // Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Show SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
  
  // Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
