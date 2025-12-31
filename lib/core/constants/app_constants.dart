class AppConstants {
  // App Info
  static const String appName = 'TICKDOSE';
  static const String appVersion = '2.4.1';
  
  // Defaults
  static const int defaultRefillReminderDays = 7;
  static const int defaultQuietHoursStart = 22; // 10 PM
  static const int defaultQuietHoursEnd = 8;    // 8 AM
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxMedicinesPerUser = 100;
  
  // Notifications
  static const int notificationChannelId = 1;
  static const String notificationChannelName = 'Medicine Reminders';
  static const String notificationChannelDescription = 'Notifications for medicine reminders';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
}
