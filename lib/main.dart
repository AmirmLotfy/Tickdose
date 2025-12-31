import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';

import 'package:tickdose/firebase_options.dart';
import 'package:tickdose/features/navigation/routes/app_router.dart';
import 'package:tickdose/core/services/audio_service.dart';
import 'package:tickdose/core/services/notification_service.dart';
import 'package:tickdose/core/services/firebase_messaging_service.dart';
import 'package:tickdose/core/services/remote_config_service.dart';
import 'package:tickdose/core/services/timezone_monitor_service.dart';
import 'package:tickdose/core/services/wearable_service.dart';
import 'package:tickdose/core/services/notification_action_service.dart';
import 'package:tickdose/core/services/cache_service.dart';
import 'package:tickdose/core/services/deep_link_service.dart';
import 'package:tickdose/core/services/performance_monitoring_service.dart';
import 'package:tickdose/core/services/crash_recovery_service.dart';
import 'package:tickdose/core/services/app_update_service.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:tickdose/core/theme/app_theme.dart';
import 'package:tickdose/core/constants/app_constants.dart';
import 'package:tickdose/features/profile/providers/settings_provider.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tickdose/core/services/permission_service.dart';
import 'package:tickdose/core/services/gemini_service.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load .env file for API keys
    try {
      await dotenv.load(fileName: ".env");
      Logger.info('Loaded .env file', tag: 'Main');
    } catch (e) {
      Logger.warn('Could not load .env file: $e (this is okay if running without .env)', tag: 'Main');
    }
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Enable Firestore offline persistence
    try {
      final firestore = FirebaseFirestore.instance;
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      Logger.info('Firestore offline persistence enabled', tag: 'Main');
    } catch (e) {
      Logger.warn('Failed to enable Firestore offline persistence: $e', tag: 'Main');
      // Offline persistence may already be enabled or may fail on web
    }

    // Initialize timezone database
    tz.initializeTimeZones();
    
    // Detect and set device timezone (fallback to UTC if detection fails)
    try {
      // Get the device's local timezone
      // Get the device's local timezone
      final localLocation = tz.local;
      tz.setLocalLocation(localLocation);
      Logger.info('Timezone set to device timezone: ${localLocation.name}', tag: 'Main');
    } catch (e) {
      // Fallback to UTC if timezone detection fails
      Logger.warn('Failed to detect device timezone, using UTC: $e', tag: 'Main');
      tz.setLocalLocation(tz.UTC);
    }
    
    // Initialize Remote Config (for API keys)
    try {
      await RemoteConfigService().initialize();
      Logger.info('Remote Config initialized', tag: 'Main');
    } catch (e) {
      Logger.warn('Remote Config failed: $e. API features may not work without keys in Firebase Console', tag: 'Main');
    }
    
    // Initialize Gemini service cache cleanup (runs every 6 hours)
    try {
      // Clean cache immediately on startup
      GeminiService().cleanExpiredCache();
      Logger.info('Gemini cache cleaned on startup', tag: 'Main');
      
      // Set up periodic cache cleanup (every 6 hours)
      Timer.periodic(const Duration(hours: 6), (timer) {
        GeminiService().cleanExpiredCache();
        Logger.info('Periodic Gemini cache cleanup completed', tag: 'Main');
      });
      Logger.info('Periodic Gemini cache cleanup scheduled (every 6 hours)', tag: 'Main');
    } catch (e) {
      Logger.warn('Failed to set up Gemini cache cleanup: $e', tag: 'Main');
    }
    
    // Enable Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Catch Flutter errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    
    // Set up global error widget builder for better error handling
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log error to Crashlytics
      FirebaseCrashlytics.instance.recordFlutterError(details);
      
      // Return a user-friendly error widget
      // Note: ErrorWidget.builder doesn't have access to context, so we use default theme
      // The widget will respect theme when rendered within the app
      return MaterialApp(
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: ThemeMode.system,
        home: Builder(
          builder: (context) => Scaffold(
            backgroundColor: AppColors.backgroundColor(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorRed,
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return Column(
                        children: [
                          Text(
                            l10n?.somethingWentWrong ?? 'Something went wrong',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              l10n?.errorRecoveryMessage ?? 'We\'re sorry, but an error occurred. The app will try to recover automatically.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              // Try to navigate to splash screen to restart the app flow
                              // This is a simple recovery attempt
                              try {
                                final navigator = navigatorKey.currentState;
                                if (navigator != null) {
                                  // Navigate to splash screen which will handle auth and routing
                                  navigator.pushNamedAndRemoveUntil(
                                    Routes.splash,
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                // If recovery fails, log the error
                                FirebaseCrashlytics.instance.recordError(
                                  e,
                                  StackTrace.current,
                                  reason: 'Error recovery attempt failed',
                                );
                              }
                            },
                            child: Text(l10n?.tryAgain ?? 'Try Again'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };
    
    // Initialize Hive for caching
    await Hive.initFlutter();
    
    // Note: We use Hive with JSON encoding (not type adapters) for flexibility
    // CacheService stores JSON strings in Hive boxes, so no adapters needed
    try {
      await CacheService().init();
      Logger.info('Cache service initialized', tag: 'Main');
    } catch (e) {
      Logger.warn('Failed to initialize cache service: $e', tag: 'Main');
    }
    
    // Initialize Notification Service with action handler
    await NotificationService().initializeWithCallback(_handleNotificationAction);
    
    // Initialize Audio Service
    await AudioService().initialize();

    // Initialize FCM Service
    await FirebaseMessagingService().initialize();

    // Initialize Wearable Service (optional, fails gracefully if not available)
    try {
      await WearableService().initialize();
      Logger.info('Wearable service initialized', tag: 'Main');
    } catch (e) {
      Logger.warn('Wearable service not available: $e', tag: 'Main');
    }

    // Initialize WorkManager for battery-efficient background tasks
    await Workmanager().initialize(
      TimezoneMonitorService.callbackDispatcher,
      // isInDebugMode removed (deprecated/no effect)
    );

    // Initialize and start timezone monitoring (uses WorkManager for background)
    TimezoneMonitorService().startMonitoring();

    // Initialize Performance Monitoring
    try {
      await PerformanceMonitoringService().initialize();
      Logger.info('Performance monitoring initialized', tag: 'Main');
    } catch (e) {
      Logger.warn('Performance monitoring initialization failed: $e', tag: 'Main');
    }

    // Initialize Crash Recovery Service
    try {
      final crashRecovery = CrashRecoveryService();
      await crashRecovery.checkAndRecoverData();
      await crashRecovery.restorePendingOperations();
      Logger.info('Crash recovery check completed', tag: 'Main');
    } catch (e) {
      Logger.warn('Crash recovery initialization failed: $e', tag: 'Main');
    }

    // Initialize App Update Service
    try {
      await AppUpdateService().initialize();
      Logger.info('App update service initialized', tag: 'Main');
    } catch (e) {
      Logger.warn('App update service initialization failed: $e', tag: 'Main');
    }

    // Initialize Deep Link Service
    final deepLinkService = DeepLinkService();
    await deepLinkService.initialize(
      onInvitationToken: (token) {
        // Handle invitation token from deep link
        Logger.info('Received invitation token from deep link: $token', tag: 'Main');
        // Store token for navigation after app initializes
        _pendingInvitationToken = token;
      },
      onEmailAuthLink: (email, link) {
        // Handle email authentication link (passwordless)
        Logger.info('Received email auth link for: $email', tag: 'Main');
        // Store for navigation after app initializes
        _pendingEmailAuthLink = link;
        _pendingEmailAuthEmail = email;
      },
    );

    runApp(ProviderScope(
      child: TickdoseApp(deepLinkService: deepLinkService),
    ));
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

/// Handle notification actions (yes/no buttons) and voice reminders
void _handleNotificationAction(NotificationResponse response) {
  // Delegate to NotificationActionService which handles the actual logic
  NotificationActionService().handleNotificationAction(response);
}

// Global navigator key for deep link navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Pending invitation token from deep link
String? _pendingInvitationToken;

// Pending email auth link from deep link
String? _pendingEmailAuthLink;
String? _pendingEmailAuthEmail;

class TickdoseApp extends ConsumerStatefulWidget {
  final DeepLinkService deepLinkService;

  const TickdoseApp({super.key, required this.deepLinkService});

  @override
  ConsumerState<TickdoseApp> createState() => _TickdoseAppState();
}

class _TickdoseAppState extends ConsumerState<TickdoseApp> {
  @override
  void initState() {
    super.initState();
    // Handle pending invitation token if app was opened from deep link
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingInvitationToken != null) {
        final token = _pendingInvitationToken!;
        _pendingInvitationToken = null;
        _navigateToInvitation(token);
      }
      
      // Handle pending email auth link (passwordless login)
      if (_pendingEmailAuthLink != null && _pendingEmailAuthEmail != null) {
        final link = _pendingEmailAuthLink!;
        final email = _pendingEmailAuthEmail!;
        _pendingEmailAuthLink = null;
        _pendingEmailAuthEmail = null;
        _navigateToEmailAuth(email, link);
      }
    });

    // Request notification permissions for existing users
    // This handles the case where users update the app but don't go through onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService().requestReminderPermissions();
    });
  }

  void _navigateToInvitation(String token) {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushNamed(
        Routes.caregiverInvitation,
        arguments: {'token': token},
      );
    }
  }

  void _navigateToEmailAuth(String email, String link) {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      // Navigate to a screen that handles email link authentication
      // For now, we'll handle it in the passwordless login screen
      navigator.pushNamed(
        Routes.passwordlessLogin,
        arguments: {'email': email, 'link': link},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDarkMode = settings.darkMode;
    final locale = Locale(settings.language);
    
    return MaterialApp(
      title: 'TICKDOSE',
      theme: AppTheme.getLightTheme(locale: locale),
      darkTheme: AppTheme.getDarkTheme(locale: locale),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      navigatorKey: navigatorKey,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
