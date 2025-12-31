import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static const String _tag = 'TICKDOSE';
  
  // Log debug message
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }
  
  // Log info message
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }
  
  // Log warning message
  static void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }
  
  // Alias for warning (backward compatibility)
  static void warn(String message, {String? tag, Object? error}) {
    warning(message, tag: tag, error: error);
  }
  
  // Log error message
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  // Internal log method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final levelStr = level.name.toUpperCase();
      final tagStr = tag ?? _tag;
      final timestamp = DateTime.now().toString().substring(11, 19);
      
      print('[$timestamp] [$levelStr] [$tagStr] $message');
      
      if (error != null) {
        print('Error: $error');
      }
      
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }
}
