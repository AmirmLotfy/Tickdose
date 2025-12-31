class Routes {
  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String passwordlessLogin = '/passwordless-login';
  
  // Main App Routes
  static const String home = '/home';
  static const String todayScreen = '/today';
  
  // Medicine Routes
  static const String medicines = '/medicines';
  static const String medicinesList = '/medicines';
  static const String addMedicine = '/medicines/add';
  static const String editMedicine = '/medicines/edit';
  static const String medicineDetail = '/medicines/detail';
  
  // Reminder Routes
  static const String reminders = '/reminders';
  static const String addReminder = '/reminders/add';
  static const String editReminder = '/reminders/edit';
  
  // Tracking Routes
  static const String tracking = '/tracking';
  static const String adherence = '/tracking/adherence';
  static const String statistics = '/tracking/statistics';
  static const String history = '/tracking/history';
  
  // Pharmacy Routes
  static const String pharmacy = '/pharmacy';
  static const String pharmacyFinder = '/pharmacy';
  static const String pharmacyDetail = '/pharmacy/detail';
  static const String nearbyPharmacies = '/pharmacy/nearby';
  
  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String healthInfo = '/profile/health';
  static const String changePassword = '/profile/change-password';
  static const String deleteAccount = '/profile/delete-account';

  // I Feel Routes
  static const String iFeel = '/i-feel';
  static const String iFeelHistory = '/i-feel/history';
  
  // Settings Routes
  static const String settings = '/settings';
  static const String notificationSettings = '/settings/notifications';
  static const String privacySettings = '/settings/privacy';
  static const String about = '/settings/about';
  static const String help = '/settings/help';
  static const String privacyPolicy = '/settings/privacy-policy';
  static const String termsOfService = '/settings/terms-of-service';
  static const String timezoneSettings = '/settings/timezone';
  static const String accessibilitySettings = '/settings/accessibility';
  static const String voiceSettings = '/settings/voice';
  static const String caregiverManagement = '/profile/caregivers';
  static const String caregiverDashboard = '/caregiver/dashboard';
  static const String caregiverInvitation = '/caregiver/invitation';
  static const String caregiverInvitationQR = '/caregiver/invitation/qr';
  static const String caregiverEnterToken = '/caregiver/invitation/enter';
  static const String personalVoiceRecording = '/settings/personal-voice';
  static const String voicePersonality = '/settings/voice-personality';
  static const String providerDashboard = '/provider/dashboard';
  
  // Prevent instantiation
  Routes._();
}
