import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:tickdose/core/utils/logger.dart';

/// Service for handling deep links and universal links
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  /// Visible for testing purposes
  @visibleForTesting
  DeepLinkService.test();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  
  Function(String token)? onInvitationLinkReceived;
  Function(String email, String link)? onEmailAuthLinkReceived;
  
  bool _initialized = false;

  /// Initialize deep link listener
  /// 
  /// [onInvitationToken] - Callback when invitation token is extracted from link
  /// [onEmailAuthLink] - Callback when email authentication link is received
  Future<void> initialize({
    Function(String token)? onInvitationToken,
    Function(String email, String link)? onEmailAuthLink,
  }) async {
    if (_initialized) {
      Logger.warn('DeepLinkService already initialized', tag: 'DeepLinkService');
      return;
    }

    onInvitationLinkReceived = onInvitationToken;
    onEmailAuthLinkReceived = onEmailAuthLink;

    try {
      // Handle initial link (if app was opened from closed state)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        Logger.info('Initial deep link: $initialLink', tag: 'DeepLinkService');
        _handleDeepLink(initialLink);
      }

      // Listen for incoming links (when app is already running)
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          Logger.info('Deep link received: $uri', tag: 'DeepLinkService');
          _handleDeepLink(uri);
        },
        onError: (err) {
          Logger.error('Deep link error: $err', tag: 'DeepLinkService');
        },
      );

      _initialized = true;
      Logger.info('DeepLinkService initialized', tag: 'DeepLinkService');
    } catch (e) {
      Logger.error('Error initializing DeepLinkService: $e', tag: 'DeepLinkService');
    }
  }

  /// Handle deep link URI
  void _handleDeepLink(Uri uri) {
    try {
      // Check if this is an email authentication link (passwordless)
      if (uri.queryParameters.containsKey('oobCode') && uri.queryParameters.containsKey('mode')) {
        final mode = uri.queryParameters['mode'];
        final email = uri.queryParameters['email'];
        final oobCode = uri.queryParameters['oobCode'];
        
        if (mode == 'signIn' && email != null && oobCode != null) {
          Logger.info('Email authentication link received: $email', tag: 'DeepLinkService');
          onEmailAuthLinkReceived?.call(email, uri.toString());
          return;
        }
      }
      
      // Check if this is an invitation link
      if (uri.pathSegments.contains('invite') || uri.scheme == 'tickdose') {
        final token = uri.queryParameters['token'];
        
        if (token != null && token.isNotEmpty) {
          Logger.info('Extracted invitation token from deep link: $token', tag: 'DeepLinkService');
          onInvitationLinkReceived?.call(token);
        } else {
          Logger.warn('Deep link missing token parameter: $uri', tag: 'DeepLinkService');
        }
      } else {
        Logger.info('Deep link is not an invitation or email auth link: $uri', tag: 'DeepLinkService');
      }
    } catch (e) {
      Logger.error('Error handling deep link: $e', tag: 'DeepLinkService');
    }
  }

  /// Dispose of the service
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _initialized = false;
    Logger.info('DeepLinkService disposed', tag: 'DeepLinkService');
  }
}
