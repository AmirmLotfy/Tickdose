// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TICKDOSE';

  @override
  String get yesAction => 'Yes';

  @override
  String get noAction => 'No';

  @override
  String get refillReminderTitle => 'Refill Reminder';

  @override
  String refillReminderBody(String medicineName) {
    return 'It\'s time to refill your $medicineName.';
  }

  @override
  String get home => 'Home';

  @override
  String get reminders => 'Reminders';

  @override
  String get tracking => 'Tracking';

  @override
  String get pharmacy => 'Pharmacy';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSoundEffects => 'Sound Effects';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get onboardingTitle1 => 'Never Miss Your Medicine';

  @override
  String get onboardingDesc1 =>
      'Get timely reminders for all your medications and keep your health on track.';

  @override
  String get onboardingTitle2 => 'Track Your Adherence';

  @override
  String get onboardingDesc2 =>
      'Monitor your progress with detailed statistics and history logs.';

  @override
  String get onboardingTitle3 => 'Find Nearby Pharmacies';

  @override
  String get onboardingDesc3 =>
      'Locate the nearest pharmacies and check their availability instantly.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get splashTagline => 'Never Miss Your Medicine';

  @override
  String get reminderTitle => 'Time to take your medicine';

  @override
  String reminderBody(String dosage, String medicineName) {
    return 'Take $medicineName now.';
  }

  @override
  String voiceReminderStandard(String dosage, String medicineName) {
    return 'It\'s time to take $dosage of $medicineName. Please take your medication now to stay on track with your health goals.';
  }

  @override
  String voiceReminderMeal(
      String mealTime, String dosage, String medicineName) {
    return 'It\'s $mealTime time! Take $dosage of $medicineName WITH FOOD. Please take your medication now to stay on track with your health goals.';
  }

  @override
  String get goodMorning => 'Good morning!';

  @override
  String get goodAfternoon => 'Good afternoon!';

  @override
  String get goodEvening => 'Good evening!';

  @override
  String get hello => 'Hello!';

  @override
  String get medicineDetailsTitle => 'Medicine Details';

  @override
  String get deleteMedicineTitle => 'Delete Medicine';

  @override
  String get deleteMedicineQuestion => 'Delete Medicine?';

  @override
  String get deleteMedicineContent => 'This action cannot be undone.';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogDelete => 'Delete';

  @override
  String get tabDetails => 'Details';

  @override
  String get tabSideEffects => 'Side Effects';

  @override
  String get tabInteractions => 'Interactions';

  @override
  String get logSideEffect => 'Log Side Effect';

  @override
  String genericName(String name) {
    return 'Generic: $name';
  }

  @override
  String get imageNotAvailable => 'Image not available';

  @override
  String get dosageInfo => 'Dosage Information';

  @override
  String strengthValue(String strength) {
    return 'Strength: $strength';
  }

  @override
  String formValue(String form) {
    return 'Form: $form';
  }

  @override
  String dosageValue(String dosage) {
    return 'Dosage: $dosage';
  }

  @override
  String frequencyValue(String frequency) {
    return 'Frequency: $frequency';
  }

  @override
  String get manufacturerInfo => 'Manufacturer Info';

  @override
  String manufacturerValue(String name) {
    return 'Manufacturer: $name';
  }

  @override
  String batchValue(String batch) {
    return 'Batch: $batch';
  }

  @override
  String expiresValue(String date) {
    return 'Expires: $date';
  }

  @override
  String get prescriptionDetails => 'Prescription Details';

  @override
  String prescribedByValue(String name) {
    return 'Prescribed by: $name';
  }

  @override
  String dateValue(String date) {
    return 'Date: $date';
  }

  @override
  String get knownSideEffects => 'Known Side Effects';

  @override
  String get remindersLabel => 'Reminders';

  @override
  String refillReminderValue(int days) {
    return 'Refill reminder: $days days before';
  }

  @override
  String get notesLabel => 'Notes';

  @override
  String get expiringSoonWarning => 'This medicine is expiring soon!';

  @override
  String get expiredWarning => 'This medicine has expired!';

  @override
  String get interactionsTitle => 'Medicine Interactions';

  @override
  String get noInteractions => 'No known interactions found.';

  @override
  String get healthProfileCheck => 'Health Profile Check';

  @override
  String get safeForHealth => 'Safe for your health profile';

  @override
  String get foodInteractionsTitle => 'Food Interactions';

  @override
  String get noFoodInteractions => 'No known food interactions.';

  @override
  String get myMedicinesTitle => 'My Medicines';

  @override
  String get noMedicinesAdded => 'No medicines added yet';

  @override
  String helloUser(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeTagline => 'Let\'s stay healthy today!';

  @override
  String get todaysMedicines => 'Today\'s Medicines';

  @override
  String get seeAll => 'See All';

  @override
  String get noMedicinesToday => 'No medicines scheduled for today';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get errorLoadingReminders => 'Error loading reminders';

  @override
  String markedAsTaken(String medicine) {
    return '✓ Marked $medicine as taken';
  }

  @override
  String skippedMedicine(String medicine) {
    return 'Skipped $medicine';
  }

  @override
  String get takeAction => 'Take';

  @override
  String get skipAction => 'Skip';

  @override
  String get adherenceLabel => 'Adherence';

  @override
  String get streakLabel => 'STREAK';

  @override
  String streakDays(int days) {
    return '$days days';
  }

  @override
  String get iFeelTitle => 'I Feel';

  @override
  String get iFeelSubtitle => 'Check symptoms - Text or Voice';

  @override
  String get trackingTitle => 'Tracking';

  @override
  String get analyzingReport => 'Generating PDF report...';

  @override
  String get reportSuccess => 'PDF report generated successfully!';

  @override
  String reportError(Object error) {
    return 'Error generating PDF: $error';
  }

  @override
  String get pleaseLogin => 'Please log in to continue';

  @override
  String get medicineAddedSuccessfully => 'Medicine added successfully!';

  @override
  String get saving => 'Saving...';

  @override
  String get historyTitle => 'History';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get notificationsSubtitle => 'Receive medication reminders';

  @override
  String get languageLabel => 'Language';

  @override
  String get privacyPolicyLabel => 'Privacy Policy';

  @override
  String get darkModeLabel => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Use dark theme';

  @override
  String get accountTitle => 'Account';

  @override
  String get caregiversLabel => 'Caregivers';

  @override
  String get acceptInvitationLabel => 'Accept Invitation';

  @override
  String get changePasswordLabel => 'Change Password';

  @override
  String get deleteAccountLabel => 'Delete Account';

  @override
  String get logoutLabel => 'Log Out';

  @override
  String get findPharmacyTitle => 'Find Pharmacy';

  @override
  String get locationAccessRequired => 'Location Access Required';

  @override
  String get locationAccessRationale =>
      'Enable location services to find nearby pharmacies';

  @override
  String get enableLocationAction => 'Enable Location';

  @override
  String pharmacyError(Object error) {
    return 'Error: $error';
  }

  @override
  String get noPharmaciesFound => 'No pharmacies found nearby';

  @override
  String pharmaciesFoundCount(int count) {
    return '$count found';
  }

  @override
  String get directionsAction => 'Directions';

  @override
  String get callAction => 'Call';

  @override
  String get websiteAction => 'Website';

  @override
  String get showMapAction => 'Show Map';

  @override
  String get showListAction => 'Show List';

  @override
  String get myDoctorsTitle => 'My Doctors';

  @override
  String get addDoctorTitle => 'Add Doctor';

  @override
  String get deleteDoctorTitle => 'Delete Doctor?';

  @override
  String get deleteDoctorContent =>
      'Are you sure you want to remove this doctor from your list?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get pleaseLogIn => 'Please log in';

  @override
  String get noDoctorsAdded => 'No doctors added yet';

  @override
  String get tapToAddDoctor => 'Tap \"Add Doctor\" to get started';

  @override
  String get doctorNameLabel => 'Doctor Name';

  @override
  String get doctorNameHint => 'e.g. Dr. Smith';

  @override
  String get doctorNameRequired => 'Please enter a name';

  @override
  String get specializationLabel => 'Specialization';

  @override
  String get specializationRequired => 'Please select a specialization';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get phoneRequired => 'Please enter a valid phone number';

  @override
  String get doctorAddedSuccess => 'Doctor added successfully';

  @override
  String doctorAddError(Object error) {
    return 'Error adding doctor: $error';
  }

  @override
  String get specializationGeneral => 'General Practitioner';

  @override
  String get specializationCardiologist => 'Cardiologist';

  @override
  String get specializationDermatologist => 'Dermatologist';

  @override
  String get specializationNeurologist => 'Neurologist';

  @override
  String get specializationPsychiatrist => 'Psychiatrist';

  @override
  String get specializationEndocrinologist => 'Endocrinologist';

  @override
  String get specializationPediatrician => 'Pediatrician';

  @override
  String get specializationSurgeon => 'Surgeon';

  @override
  String get specializationDentist => 'Dentist';

  @override
  String get specializationOther => 'Other';

  @override
  String get caregiverDashboardTitle => 'Caregiver Dashboard';

  @override
  String get patientMedicationsTitle => 'Patient Medications';

  @override
  String get readOnlyView => 'Read-only view';

  @override
  String get todaysMedicationsTitle => 'Today\'\'s Medications';

  @override
  String get noMedicationsToday => 'No medications scheduled for today';

  @override
  String get sendVoiceReminderTooltip => 'Send voice reminder';

  @override
  String get voiceReminderSent => 'Voice reminder sent';

  @override
  String get allMedicationsTitle => 'All Medications';

  @override
  String get noMedicationsAdded => 'No medications added';

  @override
  String errorLabel(Object error) {
    return 'Error: $error';
  }

  @override
  String get acceptInvitationTitle => 'Accept Invitation';

  @override
  String get invitationCodeLabel => 'Invitation Code';

  @override
  String get enterInvitationCodePrompt => 'Enter 64-character code';

  @override
  String get invitationCodeInputLabel => 'Enter Invitation Code';

  @override
  String get invitationCodeInputDescription =>
      'Enter the invitation code you received from the patient to become their caregiver.';

  @override
  String get validateCodeButton => 'Validate Code';

  @override
  String get acceptInvitationButton => 'Accept Invitation';

  @override
  String get declineButton => 'Decline';

  @override
  String get pleaseLogInToAccept =>
      'Please log in first to accept an invitation';

  @override
  String get invitationAcceptedSuccess => 'Invitation accepted successfully!';

  @override
  String get invitationAcceptedView =>
      'Invitation accepted! You can now view patient medications.';

  @override
  String get invitationFailed =>
      'Failed to accept invitation. Code may be invalid or expired.';

  @override
  String get invitationError => 'Error accepting invitation. Please try again.';

  @override
  String get invalidInvitationFormat => 'Invalid invitation code format';

  @override
  String get invitationNotFound => 'Invitation code not found';

  @override
  String get invitationUsed => 'This invitation has already been used';

  @override
  String get invitationExpired => 'This invitation has expired';

  @override
  String get loginRequiredNote =>
      'Note: You need to be logged in to accept an invitation.';

  @override
  String get howToFindCodeTitle => 'How to find your invitation code:';

  @override
  String get howToFindCodeStep1 =>
      '1. Ask the patient to share the invitation code';

  @override
  String get howToFindCodeStep2 => '2. Or scan the QR code they provided';

  @override
  String get howToFindCodeStep3 => '3. Enter the code in the field above';

  @override
  String get invalidInvitationTitle => 'Invalid Invitation';

  @override
  String get invalidInvitationMessage =>
      'This invitation is invalid or has expired.';

  @override
  String get invitationUsedTitle => 'Invitation Used';

  @override
  String get invitationUsedMessage => 'This invitation has already been used.';

  @override
  String get invitedTitle => 'You\'ve been invited!';

  @override
  String get invitedMessage =>
      'You\'ve been invited to help manage medications.';

  @override
  String get permissionsTitle => 'You will have access to:';

  @override
  String get invitationLinkCopied => 'Invitation link copied to clipboard';

  @override
  String get invitationCodeCopied => 'Invitation code copied to clipboard';

  @override
  String shareInvitationText(String url, String token) {
    return 'You\'ve been invited to be a caregiver on Tickdose!\n\nClick here to accept: $url\n\nOr enter this code in the app: $token';
  }

  @override
  String get shareInvitationSubject => 'Caregiver Invitation from Tickdose';

  @override
  String errorSharing(Object error) {
    return 'Error sharing: $error';
  }

  @override
  String get invitationTitle => 'Invitation';

  @override
  String get shareInvitationTitle => 'Share Invitation';

  @override
  String shareInvitationSubtitle(String email) {
    return 'Share this invitation with $email';
  }

  @override
  String get scanQrCodeTitle => 'Scan QR Code';

  @override
  String get scanQrCodeDescription =>
      'Caregiver can scan this QR code with their phone camera or Tickdose app';

  @override
  String get invitationLinkTitle => 'Invitation Link';

  @override
  String get copyLinkTooltip => 'Copy link';

  @override
  String get ifQrNotWorking =>
      'If QR code doesn\'t work, caregiver can enter this code manually:';

  @override
  String get copyCodeTooltip => 'Copy code';

  @override
  String get shareInvitationButton => 'Share Invitation';

  @override
  String get howToShareTitle => 'How to share:';

  @override
  String get howToShareStep1Title => '1. Show QR code to caregiver';

  @override
  String get howToShareStep1Desc => 'They can scan it with their phone camera';

  @override
  String get howToShareStep2Title => '2. Share the link';

  @override
  String get howToShareStep2Desc =>
      'Send via message, email, or any messaging app';

  @override
  String get howToShareStep3Title => '3. Share the code';

  @override
  String get howToShareStep3Desc =>
      'Caregiver can enter the code manually in the app';

  @override
  String get microphonePermissionRequired => 'Microphone permission required';

  @override
  String recordingError(Object error) {
    return 'Error starting recording: $error';
  }

  @override
  String get voiceMessageSaved => 'Voice message saved!';

  @override
  String get recordVoiceMessageTitle => 'Record Voice Message';

  @override
  String voiceMessageFor(String medicineName) {
    return 'Voice Message for $medicineName';
  }

  @override
  String get recordVoiceMessageDescription =>
      'Record a personal voice reminder (up to 15 seconds)';

  @override
  String get startRecordingButton => 'Start Recording';

  @override
  String get stopRecordingButton => 'Stop Recording';

  @override
  String get saveVoiceMessageButton => 'Save Voice Message';

  @override
  String generatingPdfMessage(String month) {
    return 'Generating PDF report for $month...';
  }

  @override
  String pdfGeneratedSuccess(String path) {
    return 'Report generated! Saved to $path';
  }

  @override
  String pdfGenerationError(Object error) {
    return 'Error generating report: $error';
  }

  @override
  String get exportPdfButton => 'Export PDF Report';

  @override
  String get userDataNotAvailable => 'User data not available';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInContinue => 'Sign in to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailValidation => 'Please enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordValidation => 'Please enter your password';

  @override
  String get forgotPasswordButton => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get continueApple => 'Continue with Apple';

  @override
  String get useBiometricLogin => 'Use Biometric Login';

  @override
  String get biometricNotAvailable =>
      'Biometric authentication not available on this device';

  @override
  String get biometricEnablePrompt =>
      'Please login normally first to enable biometric login';

  @override
  String get biometricAuthFailed => 'Biometric authentication failed';

  @override
  String biometricLoginFailed(Object error) {
    return 'Biometric login failed: $error';
  }

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get nameLabel => 'Name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signInButton => 'Sign In';

  @override
  String get startJourneySubtitle => 'Start your journey to better health';

  @override
  String get termsAgreementValidation =>
      'Please agree to the Terms of Service and Privacy Policy';

  @override
  String get registrationSuccess =>
      'Registration successful! Please verify your email.';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get nameValidation => 'Please enter your name';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordHint => 'Create a strong password';

  @override
  String get passwordEmpty => 'Please enter a password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get termsAgreementPrefix => 'I agree to the ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsAgreementAnd => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get orSeparator => 'OR';

  @override
  String get loginLink => 'Login';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email to receive a password reset link';

  @override
  String get sendResetLinkButton => 'Send Reset Link';

  @override
  String get passwordResetSent =>
      'Password reset email sent! Please check your inbox.';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get emailVerifiedSuccess => 'Email verified successfully!';

  @override
  String get emailNotVerifiedYet =>
      'Email not verified yet. Please check your inbox.';

  @override
  String get resendEmailButton => 'Resend Email';

  @override
  String get verificationEmailSent =>
      'Verification email sent! Please check your inbox.';

  @override
  String get verifyEmailTitle => 'Verify Your Email';

  @override
  String get verifyEmailSubtitle =>
      'We have sent a verification link to your email address. Please verify to continue.';

  @override
  String get iHaveVerifiedButton => 'I have verified';

  @override
  String get speechNotAvailable => 'Speech recognition not available';

  @override
  String get tapToAddImage => 'Tap to add medicine image';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get galleryLabel => 'Gallery';

  @override
  String get medicineNameLabel => 'Medicine Name';

  @override
  String get medicineNameHint => 'Enter medicine name';

  @override
  String get medicineNameRequired => 'Please enter medicine name';

  @override
  String get strengthLabel => 'Strength (Optional)';

  @override
  String get strengthHint => 'e.g., 500mg';

  @override
  String get dosageLabel => 'Dosage';

  @override
  String get dosageHint => 'e.g., 1 tablet';

  @override
  String get dosageRequired => 'Please enter dosage';

  @override
  String get formLabel => 'Form';

  @override
  String get formHint => 'Select form';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get frequencyHint => 'Select frequency';

  @override
  String get prescribingDoctorLabel => 'Prescribing Doctor (Optional)';

  @override
  String get noneOption => 'None';

  @override
  String get selectDoctorHint => 'Select Doctor';

  @override
  String doctorLoadError(Object error) {
    return 'Error loading doctors: $error';
  }

  @override
  String get refillReminderLabel => 'Refill Reminder';

  @override
  String get refillReminderOff => 'Off';

  @override
  String refillReminderDaysBefore(int days) {
    return '$days days before';
  }

  @override
  String get sideEffectsLabel => 'Known Side Effects';

  @override
  String get addSideEffectHint => 'Add side effect (e.g. Drowsiness)';

  @override
  String get notesHint => 'Add notes...';

  @override
  String get addMedicineButton => 'Add Medicine';

  @override
  String get updateMedicineButton => 'Update Medicine';

  @override
  String get addMedicineImageTitle => 'Add Medicine Image';

  @override
  String get chooseImageSource => 'Choose image source';

  @override
  String captureFailed(Object error) {
    return 'Failed to capture image: $error';
  }

  @override
  String pickFailed(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String extractedText(String text) {
    return 'Extracted: $text';
  }

  @override
  String get extractFailed =>
      'Could not extract text. Please enter details manually.';

  @override
  String get extractionError =>
      'Text extraction failed. Please enter manually.';

  @override
  String medicineAutoName(String form, String time) {
    return 'Medicine ($form) - $time';
  }

  @override
  String get tabletForm => 'Tablet';

  @override
  String get capsuleForm => 'Capsule';

  @override
  String get liquidForm => 'Liquid';

  @override
  String get injectionForm => 'Injection';

  @override
  String get dailyFrequency => 'Daily';

  @override
  String get twiceDailyFrequency => 'Twice Daily';

  @override
  String get threeTimesDailyFrequency => 'Three Times Daily';

  @override
  String get weeklyFrequency => 'Weekly';

  @override
  String get asNeededFrequency => 'As Needed';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get aiHealthAssistant => 'AI Health Assistant';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get analyze => 'Analyze';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get medicines => 'Medicines';

  @override
  String get addMedicine => 'Add Medicine';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get aiEnrichmentInProgress => 'AI is gathering medicine details...';

  @override
  String get aiEnrichmentSuccess => 'Medicine details enriched by AI!';

  @override
  String get commonUsesLabel => 'Common Uses:';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSubtitle => 'App version and information';

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get helpSupportSubtitle => 'FAQs and contact';

  @override
  String get testCrashTitle => 'Test Crash';

  @override
  String get testCrashSubtitle => 'Force a crash (Dev only)';

  @override
  String get manageNotificationsSubtitle => 'Manage notification preferences';

  @override
  String get readPrivacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get readTermsSubtitle => 'Read our terms of service';

  @override
  String get showFavoritesTooltip => 'Show Favorites';

  @override
  String get showAllTooltip => 'Show All';

  @override
  String get noFavoritePharmacies => 'No favorite pharmacies found';

  @override
  String get timezoneUpdatedTitle => 'Timezone Updated';

  @override
  String timezoneUpdatedBody(Object newTimezone) {
    return 'Your reminders have been updated to $newTimezone';
  }

  @override
  String get logInTitle => 'Log In';

  @override
  String get newHere => 'New here?';

  @override
  String get createAccount => 'Create an Account';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get joinTickdo => 'Join Tickdose';

  @override
  String get startManagingHealth => 'Start managing your health journey today.';

  @override
  String get rememberPassword => 'Remember your password?';

  @override
  String get createNewPassword => 'Create new password';

  @override
  String get passwordDifferent =>
      'Your new password must be different from previous used passwords.';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordRequirements => 'Password requirements:';

  @override
  String get atLeast8Characters => 'At least 8 characters';

  @override
  String get containsNumber => 'Contains a number';

  @override
  String get containsSymbol => 'Contains a symbol';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get defineActiveHours => 'Define your active hours';

  @override
  String get wakeWindowReminders =>
      'Tickdose will only send reminders during your wake window to sync with your circadian rhythm.';

  @override
  String get wakeUp => 'Wake Up';

  @override
  String get bedtime => 'Bedtime';

  @override
  String get continueButton => 'Continue';

  @override
  String get routineSetup => 'Routine Setup';

  @override
  String get medicalBackground => 'Medical Background';

  @override
  String get aiAnalyzeSymptoms =>
      'This helps our AI analyze your symptoms more accurately and provide personalized insights.';

  @override
  String get doYouHaveAllergies => 'Do you have any allergies?';

  @override
  String get currentTimeDetected => 'CURRENT TIME DETECTED';

  @override
  String get preferences => 'Preferences';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get feelingUnwell => 'Feeling unwell?';

  @override
  String get logSideEffectButton => 'Log Side Effect';

  @override
  String get supplyTracking => 'Supply Tracking';

  @override
  String get requestRefill => 'Request Refill';

  @override
  String get remaining => 'Remaining';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordMedium => 'Medium';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get passwordVeryStrong => 'Very Strong';

  @override
  String get medicationReminders => 'Medication Reminders';

  @override
  String get refillAlerts => 'Refill Alerts';

  @override
  String get healthAnalysis => 'Health Analysis';

  @override
  String get selectTimezone => 'Select Timezone';

  @override
  String get noKnownAllergies => 'I have no known allergies';

  @override
  String get chronicConditions => 'Chronic Conditions';

  @override
  String get logTaken => 'Log Taken';

  @override
  String get interactionWarning => 'Interaction Warning';

  @override
  String get noInteractionsDetected => 'No interactions detected';

  @override
  String get interactionsFound => 'Interactions Found';

  @override
  String get proceedAnyway => 'Proceed Anyway';

  @override
  String get thisMedicineInteracts =>
      'This medicine interacts with your current medications';

  @override
  String get active => 'ACTIVE';

  @override
  String get nextDose => 'NEXT DOSE';

  @override
  String get noUpcomingDose => 'No upcoming dose';

  @override
  String get symptomCheck => 'SYMPTOM CHECK';

  @override
  String get aboutThisDrug => 'About this drug';

  @override
  String get readFullMonograph => 'Read full monograph';

  @override
  String monographTitle(String medicineName) {
    return '$medicineName Monograph';
  }

  @override
  String get close => 'Close';

  @override
  String get editSchedule => 'Edit Schedule';

  @override
  String get editMedicine => 'Edit Medicine';

  @override
  String get shareMedicine => 'Share Medicine';

  @override
  String get iFeelAssistant => 'I Feel Assistant';

  @override
  String get online => 'ONLINE';

  @override
  String get activeContext => 'ACTIVE CONTEXT';

  @override
  String get noActiveMedications => 'No active medications';

  @override
  String get viewMeds => 'View Meds';

  @override
  String get iFeelAI => 'I Feel AI';

  @override
  String get describeSymptoms =>
      'Describe your symptoms to check for side effects';

  @override
  String get logSymptom => 'Log \"Dizziness\"';

  @override
  String get reportSideEffect => 'Report Side Effect';

  @override
  String get callDoctor => 'Call Doctor';

  @override
  String get patient => 'Patient';

  @override
  String get heartRate => 'HEART RATE';

  @override
  String get voiceReminder => 'Voice Reminder';

  @override
  String get recordNudge => 'Record Nudge';

  @override
  String get viewFullList => 'View Full List';

  @override
  String get noRemindersToday => 'No reminders scheduled for today';

  @override
  String get overdue => 'Overdue';

  @override
  String get pending => 'Pending';

  @override
  String get pillList => 'Pill List';

  @override
  String get refills => 'Refills';

  @override
  String barcodeScanned(String code) {
    return 'Barcode Scanned: $code';
  }

  @override
  String get noBarcodeFound => 'No barcode found in image';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get selectUnit => 'Select Unit';

  @override
  String get schedule => 'Schedule';

  @override
  String get notifyLowStock => 'Notify when stock is low';

  @override
  String get translating => 'Translating... / جاري الترجمة...';

  @override
  String get scanLabel => 'Scan Label';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get upload => 'Upload';

  @override
  String get interactionCheckActive => 'Interaction Check Active';

  @override
  String get interactions => 'Interactions';

  @override
  String get monograph => 'Monograph';

  @override
  String get viewDetails => 'View Details';

  @override
  String get drops => 'Drops';

  @override
  String get loadingMedicines => 'Loading medicines...';

  @override
  String get apiKeyNotConfigured => 'API key not configured';

  @override
  String get loadingSchedule => 'Loading schedule...';

  @override
  String get more => 'More';

  @override
  String get reminderSchedule => 'Reminder Schedule';

  @override
  String get inactive => 'Inactive';

  @override
  String get yourPrivacyMatters => 'Your Privacy Matters';

  @override
  String get privacyPolicyIntro =>
      'At TICKDOSE, we are committed to protecting your personal information and your right to privacy.';

  @override
  String get whatDataWeCollect => '1. What Data We Collect';

  @override
  String get whatDataWeCollectContent =>
      'We collect information that you provide directly to us, including:\n\n• Medicines: Names, dosages, and schedules you add.\n• Reminders: Times and frequencies for your notifications.\n• Location: Used only when you access the Pharmacy Finder feature.\n• Health Profile: Conditions, allergies, and other health data you choose to save.\n• Usage Data: Anonymous analytics to help us improve the app.';

  @override
  String get howWeUseYourData => '2. How We Use Your Data';

  @override
  String get howWeUseYourDataContent =>
      'We use the information we collect to:\n\n• Send you timely medication reminders and notifications.\n• Track your medication adherence and provide statistics.\n• Improve app features and user experience.\n• Analyze usage patterns to fix bugs and enhance performance.\n• Comply with legal obligations.';

  @override
  String get dataStorageSecurity => '3. Data Storage & Security';

  @override
  String get dataStorageSecurityContent =>
      '• All your personal data is stored securely in Google Firebase.\n• Data is encrypted in transit using HTTPS.\n• We implement robust security measures to protect your information.\n• We perform regular backups to prevent data loss.\n• We are committed to GDPR compliance and data protection standards.';

  @override
  String get yourRights => '4. Your Rights';

  @override
  String get yourRightsContent =>
      'You have the following rights regarding your data:\n\n• Access: You can view your data within the app at any time.\n• Export: You can request a copy of your data.\n• Deletion: You can delete your account and all associated data via the Settings menu.\n• Opt-out: You can opt-out of anonymous analytics tracking.';

  @override
  String get thirdPartyServices => '5. Third-Party Services';

  @override
  String get thirdPartyServicesContent =>
      'We use trusted third-party services to operate the app:\n\n• Google & Apple: For secure authentication.\n• Firebase: For secure cloud database and storage.\n• Google Maps / OpenStreetMap: For the pharmacy finder feature.\n• Google Generative AI (Gemini): For the \"I Feel\" symptom checker and medication information enrichment (optional, can be disabled in settings).';

  @override
  String get aiUsageDisclosure => 'AI Usage Disclosure';

  @override
  String get aiUsageDisclosureContent =>
      'TICKDOSE uses Google Generative AI (Gemini) for the following features:\n\n• Symptom Analysis: The \"I Feel\" feature uses AI to analyze your symptoms and provide general health information. This is NOT medical diagnosis.\n• Medication Enrichment: AI may be used to enrich medication information when you add medicines.\n\nIMPORTANT:\n• AI features are OPTIONAL and can be disabled in Settings.\n• AI responses are for informational purposes only and are NOT a substitute for professional medical advice.\n• Your health data is processed securely and is not used to train AI models.\n• You can opt-out of AI features at any time.\n• AI usage requires internet connection.\n\nFor more details, see our Privacy Policy.';

  @override
  String get aiUsageOptIn => 'Enable AI Features';

  @override
  String get aiUsageOptOut => 'Disable AI Features';

  @override
  String aiUsageStatus(String status) {
    return 'AI Features: $status';
  }

  @override
  String get contactUsPrivacy => '6. Contact Us';

  @override
  String get contactUsPrivacyContent =>
      'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@tickdose.app\n\nWe take your privacy seriously and will respond to all inquiries promptly.';

  @override
  String get policyChanges => '7. Policy Changes';

  @override
  String get policyChangesContent =>
      'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the \"Last Updated\" date.';

  @override
  String get lastUpdated => 'Last Updated: November 24, 2024';

  @override
  String get sharePrivacyPolicyText =>
      'Check out Tickdose Privacy Policy: https://tickdosedemo.web.app/privacy-policy';

  @override
  String get sharePrivacyPolicySubject => 'Tickdose Privacy Policy';

  @override
  String get couldNotOpenPrivacyPolicy => 'Could not open privacy policy';

  @override
  String get termsOfServiceIntro =>
      'Please read these terms carefully before using the TICKDOSE application.';

  @override
  String get licenseToUse => '1. License to Use';

  @override
  String get licenseToUseContent =>
      'TICKDOSE grants you a personal, non-transferable, non-exclusive, revocable license to use the software for your personal, non-commercial use in accordance with these Terms. You own your personal data, but we retain all rights to the application code, design, and intellectual property.';

  @override
  String get restrictions => '2. Restrictions';

  @override
  String get restrictionsContent =>
      'You agree not to:\n\n• Use the app for any illegal purpose.\n• Attempt to reverse engineer or decompile the app.\n• Share your account credentials with others.\n• Use the app to spam or harass others.\n• Attempt to breach the app\'s security measures.';

  @override
  String get medicalDisclaimer => '3. Medical Disclaimer';

  @override
  String get medicalDisclaimerContent =>
      '⚠️ TICKDOSE IS NOT A DOCTOR.\n\n• This app is not a substitute for professional medical advice, diagnosis, or treatment.\n• Never disregard professional medical advice or delay in seeking it because of something you have read on this app.\n• The data provided is for informational purposes only.\n• In case of a medical emergency, call your doctor or emergency services immediately.\n• We cannot diagnose, treat, or cure any condition.';

  @override
  String get userResponsibilities => '4. User Responsibilities';

  @override
  String get userResponsibilitiesContent =>
      '• You are responsible for the accuracy of the health data you enter.\n• You are responsible for maintaining the confidentiality of your account.\n• You agree to comply with all applicable laws and regulations.\n• You are solely liable for your use of the application.';

  @override
  String get limitationOfLiability => '5. Limitation of Liability';

  @override
  String get limitationOfLiabilityContent =>
      'To the maximum extent permitted by law, TICKDOSE shall NOT be liable for:\n\n• Any indirect, incidental, special, consequential, or punitive damages.\n• Any loss of data, use, goodwill, or other intangible losses.\n• Any missed doses or reminders due to technical failures.\n• Any adverse health outcomes resulting from reliance on the app.\n\nOur maximum liability is limited to the amount you paid for the app, if any.';

  @override
  String get termination => '6. Termination';

  @override
  String get terminationContent =>
      'We reserve the right to terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination, your right to use the Service will immediately cease.';

  @override
  String get changesToTerms => '7. Changes to Terms';

  @override
  String get changesToTermsContent =>
      'We reserve the right to modify or replace these Terms at any time. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.';

  @override
  String get contactUsTerms => '8. Contact Us';

  @override
  String get contactUsTermsContent =>
      'If you have any questions about these Terms, please contact us at:\n\nEmail: support@tickdose.app';

  @override
  String get couldNotOpenTerms => 'Could not open terms of service';

  @override
  String get deleteAccountQuestion => 'Delete Account?';

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone. All your medicines, reminders, tracking data, and account information will be permanently deleted.';

  @override
  String get deleteAccountPermanently =>
      'Permanently delete your account and all data';

  @override
  String get accountDeletedSuccess => 'Account deleted successfully';

  @override
  String errorDeletingAccount(Object error) {
    return 'Error deleting account: $error';
  }

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get delete => 'Delete';

  @override
  String get yourPersonalMedicationReminder =>
      'Your personal medication reminder';

  @override
  String get faq => 'FAQ';

  @override
  String get howToAddMedicine => 'How do I add a medicine?';

  @override
  String get howToAddMedicineAnswer =>
      'Tap the + button on the home screen to add a new medicine.';

  @override
  String get howToSetReminders => 'How do I set reminders?';

  @override
  String get howToSetRemindersAnswer =>
      'Go to Reminders tab and tap + to create a new reminder.';

  @override
  String get canIEditMedicines => 'Can I edit my medicines?';

  @override
  String get canIEditMedicinesAnswer =>
      'Yes, tap on any medicine to view details and tap Edit.';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get text => 'Text';

  @override
  String get voice => 'Voice';

  @override
  String get history => 'History';

  @override
  String get emergency => 'Emergency';

  @override
  String get createInvitation => 'Create Invitation';

  @override
  String get selectAtLeastOnePermission =>
      'Please select at least one permission';

  @override
  String get relationship => 'Relationship';

  @override
  String get permissions => 'Permissions';

  @override
  String get permissionsUpdated => 'Permissions updated';

  @override
  String get family => 'Family';

  @override
  String get friend => 'Friend';

  @override
  String get nurse => 'Nurse';

  @override
  String get other => 'Other';

  @override
  String get addTime => 'Add Time';

  @override
  String errorOccurred(Object error) {
    return 'Error: $error';
  }

  @override
  String barcodeLabel(String code) {
    return 'Barcode: $code';
  }

  @override
  String get timesLabel => 'Times';

  @override
  String doctorDisplayFormat(String name, String specialization) {
    return 'Dr. $name ($specialization)';
  }

  @override
  String get dosageHintExample => '10';

  @override
  String get unitMg => 'mg';

  @override
  String get unitG => 'g';

  @override
  String get unitMl => 'ml';

  @override
  String get unitUnits => 'units';

  @override
  String get unitTablets => 'tablets';

  @override
  String get unitCapsules => 'capsules';

  @override
  String get noKnownConflicts => 'No known conflicts with your current list.';

  @override
  String get addMedicineTitle => 'Add Medicine';

  @override
  String failedToUploadImage(Object error) {
    return 'Failed to upload image: $error';
  }

  @override
  String errorFailedToShare(Object error) {
    return 'Error: Failed to share: $error';
  }

  @override
  String failedToDelete(Object error) {
    return 'Failed to delete: $error';
  }

  @override
  String get pleaseLogInToViewSideEffects =>
      'Please log in to view side effects';

  @override
  String errorLoadingSideEffects(Object error) {
    return 'Error: $error';
  }

  @override
  String get deleteSideEffectQuestion => 'Delete Side Effect?';

  @override
  String get deleteSideEffectWarning => 'This action cannot be undone.';

  @override
  String get sideEffectDeleted => 'Side effect deleted';

  @override
  String get logSideEffectTitle => 'Log Side Effect';

  @override
  String get sideEffectLoggedSuccess => 'Side effect logged successfully';

  @override
  String get effectNameLabel => 'Effect Name';

  @override
  String get effectNameHint => 'e.g., Nausea, Headache';

  @override
  String get whenDidThisOccur => 'When did this occur?';

  @override
  String get notesOptionalLabel => 'Notes (optional)';

  @override
  String get notesOptionalHint => 'Additional details about the side effect';

  @override
  String get iUnderstandTheRisks => 'I understand the risks';

  @override
  String get searchMedicinesHint => 'Search medicines...';

  @override
  String get medsLabel => 'MEDS';

  @override
  String get plusOneToday => '+1 today';

  @override
  String adherencePercentage(String percentage) {
    return '$percentage% adherence';
  }

  @override
  String xpToNextLevel(String xp, String level) {
    return '$xp XP to Level $level';
  }

  @override
  String get noChatHistoryYet => 'No chat history yet';

  @override
  String get noPatientsFound => 'No patients found';

  @override
  String get noLogsForThisDay => 'No logs for this day';

  @override
  String get errorOccurredMessage => 'An error occurred';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get errorRecoveryMessage =>
      'We\'re sorry, but an error occurred. The app will try to recover automatically.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get enableLocationServices => 'Enable Location Services';

  @override
  String get locationServicesDescription =>
      'Find nearby pharmacies and get location-based reminders';

  @override
  String get locationServicesDetailedDescription =>
      'We use your location to help you find the nearest pharmacies and provide accurate medication reminders based on your location.';

  @override
  String get enableCameraAccess => 'Enable Camera Access';

  @override
  String get cameraAccessDescription =>
      'Scan medication labels and capture health information';

  @override
  String get enableMicrophoneAccess => 'Enable Microphone Access';

  @override
  String get microphoneAccessDescription =>
      'Use voice commands and record symptoms';

  @override
  String get youCanChangeAnytimeInSettings =>
      'You can change this anytime in Settings';

  @override
  String get notNow => 'Not Now';

  @override
  String get allow => 'Allow';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noActivityForThisDate => 'No activity for this date';

  @override
  String get open24Hours => '24/7';

  @override
  String get errorTitle => 'Error';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String todayAt(String time) {
    return 'Today, $time';
  }

  @override
  String get missedMedicationAlert => 'Missed Medication Alert';

  @override
  String patientMissedMedicationAt(
      String patientOrUser, String medicineName, String time) {
    return '$patientOrUser missed $medicineName at $time';
  }

  @override
  String get user => 'User';

  @override
  String adherenceSummaryTitle(String type) {
    return '$type Adherence Summary';
  }

  @override
  String adherenceSummaryBody(
      String rate, String taken, String missed, String skipped) {
    return 'Adherence: $rate% | Taken: $taken | Missed: $missed | Skipped: $skipped';
  }

  @override
  String get sideEffectAlert => 'Side Effect Alert';

  @override
  String sideEffectBody(String medicineName, String symptom, String severity) {
    return '$medicineName: $symptom ($severity)';
  }

  @override
  String get urgentHealthConcern => 'URGENT Health Concern';

  @override
  String get healthConcernAlert => 'Health Concern Alert';

  @override
  String get noRemindersSet => 'No reminders set';

  @override
  String get noDoctorsFound => 'No doctors found';

  @override
  String get errorLoadingPatients => 'Error loading patients';

  @override
  String get patientsWillAppearHere =>
      'Patients will appear here when they\ngrant you access as their caregiver';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get describeSymptomsByVoiceOrText =>
      'Describe your symptoms by voice or text';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get pleaseLogInAgainBeforeDeletingAccount =>
      'Please log out and log in again before deleting account';

  @override
  String get genericNameLabel => 'Generic Name:';

  @override
  String get manufacturerLabel => 'Manufacturer:';

  @override
  String get translationLabel => '[Translation]';

  @override
  String get couldNotMakeCall => 'Could not make call';

  @override
  String get resetSettingsTitle => 'Reset Settings';

  @override
  String get resetSettingsConfirmation =>
      'Are you sure you want to reset all voice settings to defaults?';

  @override
  String get settingsResetToDefaults => 'Settings reset to defaults';

  @override
  String get resetButton => 'Reset';

  @override
  String get apiRateLimitExceeded =>
      'API rate limit exceeded. Please try again later.';

  @override
  String get apiInitializationFailed =>
      'API initialization failed. Please check your configuration.';

  @override
  String get apiGenericError => 'An error occurred. Please try again.';
}
