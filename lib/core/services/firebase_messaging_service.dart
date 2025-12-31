import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tickdose/core/services/firebase_user_service.dart';
import 'package:tickdose/core/services/fcm_background_handler.dart';
import 'package:tickdose/core/utils/logger.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseUserService _userService = FirebaseUserService();
  String? _currentToken;

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.info('FCM: User granted permission', tag: 'FCM');
    }

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    _currentToken = token;
    Logger.info('FCM Token: $token', tag: 'FCM');

    // Update token in Firestore if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      try {
        await _userService.updateFCMToken(user.uid, token);
      } catch (e) {
        Logger.error('Error updating FCM token in Firestore: $e', tag: 'FCM');
      }
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _currentToken = newToken;
      Logger.info('FCM Token refreshed: $newToken', tag: 'FCM');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userService.updateFCMToken(user.uid, newToken).catchError((e) {
          Logger.error('Error updating refreshed FCM token: $e', tag: 'FCM');
        });
      }
    });

    // Register background message handler (must be called before other handlers)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle notification taps when app is opened from terminated state
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
    
    // Handle notification taps when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    Logger.info('Foreground message: ${message.notification?.title}', tag: 'FCM');
    
    // Check if this is an invitation notification
    if (message.data.containsKey('type') && message.data['type'] == 'caregiver_invitation') {
      Logger.info('Received caregiver invitation notification', tag: 'FCM');
      // Navigation will be handled by the app when user taps notification
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    Logger.info('Notification tapped: ${message.messageId}', tag: 'FCM');
    
    // Check if this is an invitation notification
    if (message.data.containsKey('type') && message.data['type'] == 'caregiver_invitation') {
      final token = message.data['invitationToken'];
      if (token != null) {
        Logger.info('Opening invitation screen with token: $token', tag: 'FCM');
        // Navigation will be handled by DeepLinkService or main.dart
        // For now, we'll rely on the data payload being available
      }
    }
  }

  String? get currentToken => _currentToken;
}
