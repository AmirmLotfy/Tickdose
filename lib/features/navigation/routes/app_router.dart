import 'package:flutter/material.dart';
import 'package:tickdose/features/navigation/routes/route_names.dart';
import 'package:tickdose/core/widgets/standard_error_widget.dart';
import 'package:tickdose/l10n/generated/app_localizations.dart';
import 'package:tickdose/features/splash/screens/splash_screen.dart';
import 'package:tickdose/features/onboarding/screens/onboarding_screen.dart';
import 'package:tickdose/features/auth/screens/login_screen.dart';
import 'package:tickdose/features/auth/screens/register_screen.dart';
import 'package:tickdose/features/auth/screens/forgot_password_screen.dart';
import 'package:tickdose/features/auth/screens/email_verification_screen.dart';
import 'package:tickdose/features/auth/screens/passwordless_login_screen.dart';
import 'package:tickdose/features/home/screens/home_screen.dart';
import 'package:tickdose/features/home/screens/today_screen.dart';
import 'package:tickdose/features/medicines/screens/medicines_list_screen.dart';
import 'package:tickdose/features/medicines/screens/add_medicine_screen.dart';
import 'package:tickdose/features/medicines/screens/medicine_detail_screen.dart';
import 'package:tickdose/features/medicines/screens/edit_medicine_screen.dart';
import 'package:tickdose/features/reminders/screens/add_reminder_screen.dart';
import 'package:tickdose/features/reminders/screens/edit_reminder_screen.dart';
import 'package:tickdose/features/reminders/screens/reminders_screen.dart';
import 'package:tickdose/features/tracking/screens/tracking_screen.dart';
import 'package:tickdose/features/pharmacy/screens/pharmacy_finder_screen.dart';
import 'package:tickdose/features/profile/screens/profile_screen.dart';
import 'package:tickdose/features/profile/screens/edit_profile_screen.dart';
import 'package:tickdose/features/profile/screens/health_info_screen.dart';
import 'package:tickdose/features/profile/screens/change_password_screen.dart';
import 'package:tickdose/features/profile/screens/delete_account_screen.dart';
import 'package:tickdose/features/settings/screens/settings_screen.dart';
import 'package:tickdose/features/settings/screens/notification_settings_screen.dart';
import 'package:tickdose/features/settings/screens/privacy_settings_screen.dart';
import 'package:tickdose/features/settings/screens/about_screen.dart';
import 'package:tickdose/features/settings/screens/help_screen.dart';
import 'package:tickdose/features/settings/screens/privacy_policy_screen.dart';
import 'package:tickdose/features/settings/screens/terms_of_service_screen.dart';
import 'package:tickdose/features/i_feel/screens/chat_history_screen.dart';
import 'package:tickdose/features/i_feel/screens/i_feel_screen.dart';
import 'package:tickdose/features/settings/screens/voice_settings_screen.dart';
import 'package:tickdose/features/settings/screens/timezone_settings_screen.dart';
import 'package:tickdose/features/settings/screens/accessibility_settings_screen.dart';
import 'package:tickdose/features/profile/screens/caregiver_management_screen.dart';
import 'package:tickdose/features/caregiver/screens/caregiver_dashboard_screen.dart';
import 'package:tickdose/features/caregiver/screens/caregiver_invitation_screen.dart';
import 'package:tickdose/features/caregiver/screens/invitation_qr_screen.dart';
import 'package:tickdose/features/caregiver/screens/enter_invitation_token_screen.dart';
import 'package:tickdose/features/settings/screens/personal_voice_recording_screen.dart';
import 'package:tickdose/features/settings/screens/voice_personality_screen.dart';
import 'package:tickdose/features/provider/screens/provider_dashboard_screen.dart';



class AppRouter {
  // Use Routes constants
  static const String splash = Routes.splash;
  static const String onboarding = Routes.onboarding;
  static const String login = Routes.login;
  static const String register = Routes.register;
  static const String forgotPassword = Routes.forgotPassword;
  static const String emailVerification = Routes.emailVerification;
  static const String home = Routes.home;
  static const String medicines = Routes.medicines;
  static const String addMedicine = Routes.addMedicine;
  static const String medicineDetail = Routes.medicineDetail;
  static const String editMedicine = Routes.editMedicine;
  static const String reminders = Routes.reminders;
  static const String addReminder = Routes.addReminder;
  static const String editReminder = Routes.editReminder;
  static const String tracking = Routes.tracking;
  static const String pharmacy = Routes.pharmacy;
  static const String profile = Routes.profile;
  static const String editProfile = Routes.editProfile;
  static const String healthInfo = Routes.healthInfo;
  static const String settings = Routes.settings;
  static const String notificationSettings = Routes.notificationSettings;
  static const String privacySettings = Routes.privacySettings;
  static const String about = Routes.about;
  static const String help = Routes.help;
  static const String privacyPolicy = Routes.privacyPolicy;
  static const String termsOfService = Routes.termsOfService;
  static const String iFeel = Routes.iFeel;
  static const String iFeelHistory = Routes.iFeelHistory;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case Routes.emailVerification:
        return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
      
      case Routes.passwordlessLogin:
        return MaterialPageRoute(builder: (_) => const PasswordlessLoginScreen());
      
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case Routes.todayScreen:
        return MaterialPageRoute(builder: (_) => const TodayScreen());
      
      case Routes.medicinesList:
        return MaterialPageRoute(builder: (_) => const MedicinesListScreen());
      
      case Routes.addMedicine:
        return MaterialPageRoute(builder: (_) => const AddMedicineScreen());
      
      case Routes.editMedicine:
        return MaterialPageRoute(
          builder: (_) => EditMedicineScreen(medicine: settings.arguments as dynamic),
        );
      
      case Routes.medicineDetail:
        return MaterialPageRoute(
          builder: (_) => MedicineDetailScreen(medicine: settings.arguments as dynamic),
        );
      
      case Routes.reminders:
        return MaterialPageRoute(builder: (_) => const RemindersScreen());
      
      case Routes.addReminder:
        return MaterialPageRoute(builder: (_) => const AddReminderScreen());
      
      case Routes.editReminder:
        return MaterialPageRoute(
          builder: (_) => EditReminderScreen(reminder: settings.arguments as dynamic),
        );
      
      case Routes.tracking:
        return MaterialPageRoute(builder: (_) => const TrackingScreen());
      
      // Tracking sub-routes - all route to TrackingScreen (they're views within the same screen)
      case Routes.adherence:
      case Routes.statistics:
      case Routes.history:
        return MaterialPageRoute(builder: (_) => const TrackingScreen());
      
      case Routes.pharmacyFinder:
        return MaterialPageRoute(builder: (_) => const PharmacyFinderScreen());
      
      // Pharmacy sub-routes - route to PharmacyFinderScreen (detail/nearby are views within)
      case Routes.pharmacyDetail:
      case Routes.nearbyPharmacies:
        return MaterialPageRoute(builder: (_) => const PharmacyFinderScreen());
      
      // Profile Routes
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case Routes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case Routes.healthInfo:
        return MaterialPageRoute(builder: (_) => const HealthInfoScreen());
      
      case Routes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      
      case Routes.deleteAccount:
        return MaterialPageRoute(builder: (_) => const DeleteAccountScreen());
      
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case Routes.notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
      
      case Routes.privacySettings:
        return MaterialPageRoute(builder: (_) => const PrivacySettingsScreen());
      
      case Routes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      
      case Routes.help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());

      case Routes.privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());

      case Routes.termsOfService:
        return MaterialPageRoute(builder: (_) => const TermsOfServiceScreen());

      case Routes.iFeel:
        // Check if there's an initialIndex argument for voice mode
        final args = settings.arguments as Map<String, dynamic>?;
        final initialIndex = args?['initialIndex'] as int? ?? 0;
        return MaterialPageRoute(builder: (_) => IFeelScreen(initialIndex: initialIndex));
      
      case Routes.iFeelHistory:
        return MaterialPageRoute(builder: (_) => const ChatHistoryScreen());

      case Routes.voiceSettings:
        return MaterialPageRoute(builder: (_) => const VoiceSettingsScreen());

      case Routes.timezoneSettings:
        return MaterialPageRoute(builder: (_) => const TimezoneSettingsScreen());

      case Routes.accessibilitySettings:
        return MaterialPageRoute(builder: (_) => const AccessibilitySettingsScreen());

      case Routes.caregiverManagement:
        return MaterialPageRoute(builder: (_) => const CaregiverManagementScreen());

      case Routes.caregiverDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CaregiverDashboardScreen(
            patientUserId: args?['patientUserId'] ?? '',
          ),
        );

      case Routes.caregiverInvitation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CaregiverInvitationScreen(
            invitationToken: args?['token'] ?? '',
          ),
        );

      case Routes.caregiverInvitationQR:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InvitationQRScreen(
            invitationToken: args?['token'] ?? '',
            caregiverEmail: args?['caregiverEmail'] ?? '',
          ),
        );

      case Routes.caregiverEnterToken:
        return MaterialPageRoute(
          builder: (_) => const EnterInvitationTokenScreen(),
        );

      case Routes.personalVoiceRecording:
        return MaterialPageRoute(builder: (_) => const PersonalVoiceRecordingScreen());

      case Routes.voicePersonality:
        return MaterialPageRoute(builder: (_) => const VoicePersonalityScreen());

      case Routes.providerDashboard:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProviderDashboardScreen(
            patientUserId: args?['patientUserId'],
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.errorTitle),
              ),
              body: StandardErrorWidget(
                title: l10n.errorTitle,
                subtitle: l10n.pageNotFound,
              ),
            );
          },
        );
    }
  }
}
