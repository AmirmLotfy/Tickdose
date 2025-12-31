import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Top-level function for handling background FCM messages
/// This must be a top-level function (not a class method) and must be annotated
/// with @pragma('vm:entry-point') to work properly
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (background isolate)
  // Note: Firebase.initializeApp() should already be called in main.dart
  // but we may need to ensure it's initialized in the background isolate
  
  Logger.info('Background FCM message received: ${message.messageId}', tag: 'FCM-Background');
  Logger.info('Message data: ${message.data}', tag: 'FCM-Background');
  Logger.info('Message notification: ${message.notification?.title}', tag: 'FCM-Background');
  
  // Handle different message types
  if (message.data.containsKey('type')) {
    final type = message.data['type'] as String;
    
    switch (type) {
      case 'caregiver_invitation':
        Logger.info('Processing caregiver invitation notification', tag: 'FCM-Background');
        // The notification will be shown by the system
        // User interaction will be handled when app opens
        break;
        
      case 'medicine_missed':
        Logger.info('Processing medicine missed notification', tag: 'FCM-Background');
        // The notification will be shown by the system
        break;
        
      default:
        Logger.info('Unknown notification type: $type', tag: 'FCM-Background');
    }
  }
  
  // Note: We cannot show local notifications or navigate in background handler
  // The system will show the notification, and user interaction will be handled
  // when the app is opened (via onMessageOpenedApp or getInitialMessage)
}
