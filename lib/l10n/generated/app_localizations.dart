import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TICKDOSE'**
  String get appTitle;

  /// No description provided for @yesAction.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesAction;

  /// No description provided for @noAction.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noAction;

  /// No description provided for @refillReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Refill Reminder'**
  String get refillReminderTitle;

  /// No description provided for @refillReminderBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to refill your {medicineName}.'**
  String refillReminderBody(String medicineName);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacy;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Never Miss Your Medicine'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Get timely reminders for all your medications and keep your health on track.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track Your Adherence'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Monitor your progress with detailed statistics and history logs.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Find Nearby Pharmacies'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Locate the nearest pharmacies and check their availability instantly.'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Never Miss Your Medicine'**
  String get splashTagline;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to take your medicine'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'Take {medicineName} now.'**
  String reminderBody(String dosage, String medicineName);

  /// No description provided for @voiceReminderStandard.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to take {dosage} of {medicineName}. Please take your medication now to stay on track with your health goals.'**
  String voiceReminderStandard(String dosage, String medicineName);

  /// No description provided for @voiceReminderMeal.
  ///
  /// In en, this message translates to:
  /// **'It\'s {mealTime} time! Take {dosage} of {medicineName} WITH FOOD. Please take your medication now to stay on track with your health goals.'**
  String voiceReminderMeal(String mealTime, String dosage, String medicineName);

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning!'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon!'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening!'**
  String get goodEvening;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @medicineDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine Details'**
  String get medicineDetailsTitle;

  /// No description provided for @deleteMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine'**
  String get deleteMedicineTitle;

  /// No description provided for @deleteMedicineQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Medicine?'**
  String get deleteMedicineQuestion;

  /// No description provided for @deleteMedicineContent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteMedicineContent;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogDelete;

  /// No description provided for @tabDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get tabDetails;

  /// No description provided for @tabSideEffects.
  ///
  /// In en, this message translates to:
  /// **'Side Effects'**
  String get tabSideEffects;

  /// No description provided for @tabInteractions.
  ///
  /// In en, this message translates to:
  /// **'Interactions'**
  String get tabInteractions;

  /// No description provided for @logSideEffect.
  ///
  /// In en, this message translates to:
  /// **'Log Side Effect'**
  String get logSideEffect;

  /// No description provided for @genericName.
  ///
  /// In en, this message translates to:
  /// **'Generic: {name}'**
  String genericName(String name);

  /// No description provided for @imageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image not available'**
  String get imageNotAvailable;

  /// No description provided for @dosageInfo.
  ///
  /// In en, this message translates to:
  /// **'Dosage Information'**
  String get dosageInfo;

  /// No description provided for @strengthValue.
  ///
  /// In en, this message translates to:
  /// **'Strength: {strength}'**
  String strengthValue(String strength);

  /// No description provided for @formValue.
  ///
  /// In en, this message translates to:
  /// **'Form: {form}'**
  String formValue(String form);

  /// No description provided for @dosageValue.
  ///
  /// In en, this message translates to:
  /// **'Dosage: {dosage}'**
  String dosageValue(String dosage);

  /// No description provided for @frequencyValue.
  ///
  /// In en, this message translates to:
  /// **'Frequency: {frequency}'**
  String frequencyValue(String frequency);

  /// No description provided for @manufacturerInfo.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer Info'**
  String get manufacturerInfo;

  /// No description provided for @manufacturerValue.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer: {name}'**
  String manufacturerValue(String name);

  /// No description provided for @batchValue.
  ///
  /// In en, this message translates to:
  /// **'Batch: {batch}'**
  String batchValue(String batch);

  /// No description provided for @expiresValue.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String expiresValue(String date);

  /// No description provided for @prescriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Prescription Details'**
  String get prescriptionDetails;

  /// No description provided for @prescribedByValue.
  ///
  /// In en, this message translates to:
  /// **'Prescribed by: {name}'**
  String prescribedByValue(String name);

  /// No description provided for @dateValue.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String dateValue(String date);

  /// No description provided for @knownSideEffects.
  ///
  /// In en, this message translates to:
  /// **'Known Side Effects'**
  String get knownSideEffects;

  /// No description provided for @remindersLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersLabel;

  /// No description provided for @refillReminderValue.
  ///
  /// In en, this message translates to:
  /// **'Refill reminder: {days} days before'**
  String refillReminderValue(int days);

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @expiringSoonWarning.
  ///
  /// In en, this message translates to:
  /// **'This medicine is expiring soon!'**
  String get expiringSoonWarning;

  /// No description provided for @expiredWarning.
  ///
  /// In en, this message translates to:
  /// **'This medicine has expired!'**
  String get expiredWarning;

  /// No description provided for @interactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine Interactions'**
  String get interactionsTitle;

  /// No description provided for @noInteractions.
  ///
  /// In en, this message translates to:
  /// **'No known interactions found.'**
  String get noInteractions;

  /// No description provided for @healthProfileCheck.
  ///
  /// In en, this message translates to:
  /// **'Health Profile Check'**
  String get healthProfileCheck;

  /// No description provided for @safeForHealth.
  ///
  /// In en, this message translates to:
  /// **'Safe for your health profile'**
  String get safeForHealth;

  /// No description provided for @foodInteractionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Interactions'**
  String get foodInteractionsTitle;

  /// No description provided for @noFoodInteractions.
  ///
  /// In en, this message translates to:
  /// **'No known food interactions.'**
  String get noFoodInteractions;

  /// No description provided for @myMedicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Medicines'**
  String get myMedicinesTitle;

  /// No description provided for @noMedicinesAdded.
  ///
  /// In en, this message translates to:
  /// **'No medicines added yet'**
  String get noMedicinesAdded;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(String name);

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Let\'s stay healthy today!'**
  String get homeTagline;

  /// No description provided for @todaysMedicines.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Medicines'**
  String get todaysMedicines;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noMedicinesToday.
  ///
  /// In en, this message translates to:
  /// **'No medicines scheduled for today'**
  String get noMedicinesToday;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @errorLoadingReminders.
  ///
  /// In en, this message translates to:
  /// **'Error loading reminders'**
  String get errorLoadingReminders;

  /// No description provided for @markedAsTaken.
  ///
  /// In en, this message translates to:
  /// **'✓ Marked {medicine} as taken'**
  String markedAsTaken(String medicine);

  /// No description provided for @skippedMedicine.
  ///
  /// In en, this message translates to:
  /// **'Skipped {medicine}'**
  String skippedMedicine(String medicine);

  /// No description provided for @takeAction.
  ///
  /// In en, this message translates to:
  /// **'Take'**
  String get takeAction;

  /// No description provided for @skipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipAction;

  /// No description provided for @adherenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherenceLabel;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get streakLabel;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String streakDays(int days);

  /// No description provided for @iFeelTitle.
  ///
  /// In en, this message translates to:
  /// **'I Feel'**
  String get iFeelTitle;

  /// No description provided for @iFeelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check symptoms - Text or Voice'**
  String get iFeelSubtitle;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get trackingTitle;

  /// No description provided for @analyzingReport.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF report...'**
  String get analyzingReport;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'PDF report generated successfully!'**
  String get reportSuccess;

  /// No description provided for @reportError.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF: {error}'**
  String reportError(Object error);

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue'**
  String get pleaseLogin;

  /// No description provided for @medicineAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Medicine added successfully!'**
  String get medicineAddedSuccessfully;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive medication reminders'**
  String get notificationsSubtitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @privacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLabel;

  /// No description provided for @darkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeLabel;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get darkModeSubtitle;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @caregiversLabel.
  ///
  /// In en, this message translates to:
  /// **'Caregivers'**
  String get caregiversLabel;

  /// No description provided for @acceptInvitationLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get acceptInvitationLabel;

  /// No description provided for @changePasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordLabel;

  /// No description provided for @deleteAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountLabel;

  /// No description provided for @logoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutLabel;

  /// No description provided for @findPharmacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Pharmacy'**
  String get findPharmacyTitle;

  /// No description provided for @locationAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Access Required'**
  String get locationAccessRequired;

  /// No description provided for @locationAccessRationale.
  ///
  /// In en, this message translates to:
  /// **'Enable location services to find nearby pharmacies'**
  String get locationAccessRationale;

  /// No description provided for @enableLocationAction.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocationAction;

  /// No description provided for @pharmacyError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String pharmacyError(Object error);

  /// No description provided for @noPharmaciesFound.
  ///
  /// In en, this message translates to:
  /// **'No pharmacies found nearby'**
  String get noPharmaciesFound;

  /// No description provided for @pharmaciesFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count} found'**
  String pharmaciesFoundCount(int count);

  /// No description provided for @directionsAction.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directionsAction;

  /// No description provided for @callAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// No description provided for @websiteAction.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get websiteAction;

  /// No description provided for @showMapAction.
  ///
  /// In en, this message translates to:
  /// **'Show Map'**
  String get showMapAction;

  /// No description provided for @showListAction.
  ///
  /// In en, this message translates to:
  /// **'Show List'**
  String get showListAction;

  /// No description provided for @myDoctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Doctors'**
  String get myDoctorsTitle;

  /// No description provided for @addDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Doctor'**
  String get addDoctorTitle;

  /// No description provided for @deleteDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Doctor?'**
  String get deleteDoctorTitle;

  /// No description provided for @deleteDoctorContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this doctor from your list?'**
  String get deleteDoctorContent;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get pleaseLogIn;

  /// No description provided for @noDoctorsAdded.
  ///
  /// In en, this message translates to:
  /// **'No doctors added yet'**
  String get noDoctorsAdded;

  /// No description provided for @tapToAddDoctor.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Doctor\" to get started'**
  String get tapToAddDoctor;

  /// No description provided for @doctorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor Name'**
  String get doctorNameLabel;

  /// No description provided for @doctorNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Smith'**
  String get doctorNameHint;

  /// No description provided for @doctorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get doctorNameRequired;

  /// No description provided for @specializationLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specializationLabel;

  /// No description provided for @specializationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a specialization'**
  String get specializationRequired;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneRequired;

  /// No description provided for @doctorAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Doctor added successfully'**
  String get doctorAddedSuccess;

  /// No description provided for @doctorAddError.
  ///
  /// In en, this message translates to:
  /// **'Error adding doctor: {error}'**
  String doctorAddError(Object error);

  /// No description provided for @specializationGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Practitioner'**
  String get specializationGeneral;

  /// No description provided for @specializationCardiologist.
  ///
  /// In en, this message translates to:
  /// **'Cardiologist'**
  String get specializationCardiologist;

  /// No description provided for @specializationDermatologist.
  ///
  /// In en, this message translates to:
  /// **'Dermatologist'**
  String get specializationDermatologist;

  /// No description provided for @specializationNeurologist.
  ///
  /// In en, this message translates to:
  /// **'Neurologist'**
  String get specializationNeurologist;

  /// No description provided for @specializationPsychiatrist.
  ///
  /// In en, this message translates to:
  /// **'Psychiatrist'**
  String get specializationPsychiatrist;

  /// No description provided for @specializationEndocrinologist.
  ///
  /// In en, this message translates to:
  /// **'Endocrinologist'**
  String get specializationEndocrinologist;

  /// No description provided for @specializationPediatrician.
  ///
  /// In en, this message translates to:
  /// **'Pediatrician'**
  String get specializationPediatrician;

  /// No description provided for @specializationSurgeon.
  ///
  /// In en, this message translates to:
  /// **'Surgeon'**
  String get specializationSurgeon;

  /// No description provided for @specializationDentist.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get specializationDentist;

  /// No description provided for @specializationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get specializationOther;

  /// No description provided for @caregiverDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Dashboard'**
  String get caregiverDashboardTitle;

  /// No description provided for @patientMedicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient Medications'**
  String get patientMedicationsTitle;

  /// No description provided for @readOnlyView.
  ///
  /// In en, this message translates to:
  /// **'Read-only view'**
  String get readOnlyView;

  /// No description provided for @todaysMedicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'\'s Medications'**
  String get todaysMedicationsTitle;

  /// No description provided for @noMedicationsToday.
  ///
  /// In en, this message translates to:
  /// **'No medications scheduled for today'**
  String get noMedicationsToday;

  /// No description provided for @sendVoiceReminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send voice reminder'**
  String get sendVoiceReminderTooltip;

  /// No description provided for @voiceReminderSent.
  ///
  /// In en, this message translates to:
  /// **'Voice reminder sent'**
  String get voiceReminderSent;

  /// No description provided for @allMedicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Medications'**
  String get allMedicationsTitle;

  /// No description provided for @noMedicationsAdded.
  ///
  /// In en, this message translates to:
  /// **'No medications added'**
  String get noMedicationsAdded;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(Object error);

  /// No description provided for @acceptInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get acceptInvitationTitle;

  /// No description provided for @invitationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCodeLabel;

  /// No description provided for @enterInvitationCodePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter 64-character code'**
  String get enterInvitationCodePrompt;

  /// No description provided for @invitationCodeInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter Invitation Code'**
  String get invitationCodeInputLabel;

  /// No description provided for @invitationCodeInputDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the invitation code you received from the patient to become their caregiver.'**
  String get invitationCodeInputDescription;

  /// No description provided for @validateCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Validate Code'**
  String get validateCodeButton;

  /// No description provided for @acceptInvitationButton.
  ///
  /// In en, this message translates to:
  /// **'Accept Invitation'**
  String get acceptInvitationButton;

  /// No description provided for @declineButton.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineButton;

  /// No description provided for @pleaseLogInToAccept.
  ///
  /// In en, this message translates to:
  /// **'Please log in first to accept an invitation'**
  String get pleaseLogInToAccept;

  /// No description provided for @invitationAcceptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted successfully!'**
  String get invitationAcceptedSuccess;

  /// No description provided for @invitationAcceptedView.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted! You can now view patient medications.'**
  String get invitationAcceptedView;

  /// No description provided for @invitationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept invitation. Code may be invalid or expired.'**
  String get invitationFailed;

  /// No description provided for @invitationError.
  ///
  /// In en, this message translates to:
  /// **'Error accepting invitation. Please try again.'**
  String get invitationError;

  /// No description provided for @invalidInvitationFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid invitation code format'**
  String get invalidInvitationFormat;

  /// No description provided for @invitationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invitation code not found'**
  String get invitationNotFound;

  /// No description provided for @invitationUsed.
  ///
  /// In en, this message translates to:
  /// **'This invitation has already been used'**
  String get invitationUsed;

  /// No description provided for @invitationExpired.
  ///
  /// In en, this message translates to:
  /// **'This invitation has expired'**
  String get invitationExpired;

  /// No description provided for @loginRequiredNote.
  ///
  /// In en, this message translates to:
  /// **'Note: You need to be logged in to accept an invitation.'**
  String get loginRequiredNote;

  /// No description provided for @howToFindCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'How to find your invitation code:'**
  String get howToFindCodeTitle;

  /// No description provided for @howToFindCodeStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Ask the patient to share the invitation code'**
  String get howToFindCodeStep1;

  /// No description provided for @howToFindCodeStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Or scan the QR code they provided'**
  String get howToFindCodeStep2;

  /// No description provided for @howToFindCodeStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Enter the code in the field above'**
  String get howToFindCodeStep3;

  /// No description provided for @invalidInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid Invitation'**
  String get invalidInvitationTitle;

  /// No description provided for @invalidInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'This invitation is invalid or has expired.'**
  String get invalidInvitationMessage;

  /// No description provided for @invitationUsedTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation Used'**
  String get invitationUsedTitle;

  /// No description provided for @invitationUsedMessage.
  ///
  /// In en, this message translates to:
  /// **'This invitation has already been used.'**
  String get invitationUsedMessage;

  /// No description provided for @invitedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited!'**
  String get invitedTitle;

  /// No description provided for @invitedMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited to help manage medications.'**
  String get invitedMessage;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'You will have access to:'**
  String get permissionsTitle;

  /// No description provided for @invitationLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invitation link copied to clipboard'**
  String get invitationLinkCopied;

  /// No description provided for @invitationCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invitation code copied to clipboard'**
  String get invitationCodeCopied;

  /// No description provided for @shareInvitationText.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited to be a caregiver on Tickdose!\n\nClick here to accept: {url}\n\nOr enter this code in the app: {token}'**
  String shareInvitationText(String url, String token);

  /// No description provided for @shareInvitationSubject.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Invitation from Tickdose'**
  String get shareInvitationSubject;

  /// No description provided for @errorSharing.
  ///
  /// In en, this message translates to:
  /// **'Error sharing: {error}'**
  String errorSharing(Object error);

  /// No description provided for @invitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation'**
  String get invitationTitle;

  /// No description provided for @shareInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Invitation'**
  String get shareInvitationTitle;

  /// No description provided for @shareInvitationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share this invitation with {email}'**
  String shareInvitationSubtitle(String email);

  /// No description provided for @scanQrCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCodeTitle;

  /// No description provided for @scanQrCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Caregiver can scan this QR code with their phone camera or Tickdose app'**
  String get scanQrCodeDescription;

  /// No description provided for @invitationLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Invitation Link'**
  String get invitationLinkTitle;

  /// No description provided for @copyLinkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLinkTooltip;

  /// No description provided for @ifQrNotWorking.
  ///
  /// In en, this message translates to:
  /// **'If QR code doesn\'t work, caregiver can enter this code manually:'**
  String get ifQrNotWorking;

  /// No description provided for @copyCodeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCodeTooltip;

  /// No description provided for @shareInvitationButton.
  ///
  /// In en, this message translates to:
  /// **'Share Invitation'**
  String get shareInvitationButton;

  /// No description provided for @howToShareTitle.
  ///
  /// In en, this message translates to:
  /// **'How to share:'**
  String get howToShareTitle;

  /// No description provided for @howToShareStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Show QR code to caregiver'**
  String get howToShareStep1Title;

  /// No description provided for @howToShareStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'They can scan it with their phone camera'**
  String get howToShareStep1Desc;

  /// No description provided for @howToShareStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Share the link'**
  String get howToShareStep2Title;

  /// No description provided for @howToShareStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Send via message, email, or any messaging app'**
  String get howToShareStep2Desc;

  /// No description provided for @howToShareStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Share the code'**
  String get howToShareStep3Title;

  /// No description provided for @howToShareStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Caregiver can enter the code manually in the app'**
  String get howToShareStep3Desc;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required'**
  String get microphonePermissionRequired;

  /// No description provided for @recordingError.
  ///
  /// In en, this message translates to:
  /// **'Error starting recording: {error}'**
  String recordingError(Object error);

  /// No description provided for @voiceMessageSaved.
  ///
  /// In en, this message translates to:
  /// **'Voice message saved!'**
  String get voiceMessageSaved;

  /// No description provided for @recordVoiceMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Voice Message'**
  String get recordVoiceMessageTitle;

  /// No description provided for @voiceMessageFor.
  ///
  /// In en, this message translates to:
  /// **'Voice Message for {medicineName}'**
  String voiceMessageFor(String medicineName);

  /// No description provided for @recordVoiceMessageDescription.
  ///
  /// In en, this message translates to:
  /// **'Record a personal voice reminder (up to 15 seconds)'**
  String get recordVoiceMessageDescription;

  /// No description provided for @startRecordingButton.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecordingButton;

  /// No description provided for @stopRecordingButton.
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get stopRecordingButton;

  /// No description provided for @saveVoiceMessageButton.
  ///
  /// In en, this message translates to:
  /// **'Save Voice Message'**
  String get saveVoiceMessageButton;

  /// No description provided for @generatingPdfMessage.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF report for {month}...'**
  String generatingPdfMessage(String month);

  /// No description provided for @pdfGeneratedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report generated! Saved to {path}'**
  String pdfGeneratedSuccess(String path);

  /// No description provided for @pdfGenerationError.
  ///
  /// In en, this message translates to:
  /// **'Error generating report: {error}'**
  String pdfGenerationError(Object error);

  /// No description provided for @exportPdfButton.
  ///
  /// In en, this message translates to:
  /// **'Export PDF Report'**
  String get exportPdfButton;

  /// No description provided for @userDataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'User data not available'**
  String get userDataNotAvailable;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInContinue;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailValidation;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordValidation;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordButton;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @continueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueApple;

  /// No description provided for @useBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Use Biometric Login'**
  String get useBiometricLogin;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication not available on this device'**
  String get biometricNotAvailable;

  /// No description provided for @biometricEnablePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please login normally first to enable biometric login'**
  String get biometricEnablePrompt;

  /// No description provided for @biometricAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get biometricAuthFailed;

  /// No description provided for @biometricLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric login failed: {error}'**
  String biometricLoginFailed(Object error);

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountPrompt;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @startJourneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey to better health'**
  String get startJourneySubtitle;

  /// No description provided for @termsAgreementValidation.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service and Privacy Policy'**
  String get termsAgreementValidation;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please verify your email.'**
  String get registrationSuccess;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get nameHint;

  /// No description provided for @nameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameValidation;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get passwordHint;

  /// No description provided for @passwordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get passwordEmpty;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordHint;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @termsAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get termsAgreementPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsAgreementAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get termsAgreementAnd;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @orSeparator.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orSeparator;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLinkButton;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Please check your inbox.'**
  String get passwordResetSent;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordButton;

  /// No description provided for @emailVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccess;

  /// No description provided for @emailNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox.'**
  String get emailNotVerifiedYet;

  /// No description provided for @resendEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmailButton;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Please check your inbox.'**
  String get verificationEmailSent;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We have sent a verification link to your email address. Please verify to continue.'**
  String get verifyEmailSubtitle;

  /// No description provided for @iHaveVerifiedButton.
  ///
  /// In en, this message translates to:
  /// **'I have verified'**
  String get iHaveVerifiedButton;

  /// No description provided for @speechNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition not available'**
  String get speechNotAvailable;

  /// No description provided for @tapToAddImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to add medicine image'**
  String get tapToAddImage;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @galleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryLabel;

  /// No description provided for @medicineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineNameLabel;

  /// No description provided for @medicineNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter medicine name'**
  String get medicineNameHint;

  /// No description provided for @medicineNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter medicine name'**
  String get medicineNameRequired;

  /// No description provided for @strengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Strength (Optional)'**
  String get strengthLabel;

  /// No description provided for @strengthHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 500mg'**
  String get strengthHint;

  /// No description provided for @dosageLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosageLabel;

  /// No description provided for @dosageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1 tablet'**
  String get dosageHint;

  /// No description provided for @dosageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter dosage'**
  String get dosageRequired;

  /// No description provided for @formLabel.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get formLabel;

  /// No description provided for @formHint.
  ///
  /// In en, this message translates to:
  /// **'Select form'**
  String get formHint;

  /// No description provided for @frequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequencyLabel;

  /// No description provided for @frequencyHint.
  ///
  /// In en, this message translates to:
  /// **'Select frequency'**
  String get frequencyHint;

  /// No description provided for @prescribingDoctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Prescribing Doctor (Optional)'**
  String get prescribingDoctorLabel;

  /// No description provided for @noneOption.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneOption;

  /// No description provided for @selectDoctorHint.
  ///
  /// In en, this message translates to:
  /// **'Select Doctor'**
  String get selectDoctorHint;

  /// No description provided for @doctorLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading doctors: {error}'**
  String doctorLoadError(Object error);

  /// No description provided for @refillReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Refill Reminder'**
  String get refillReminderLabel;

  /// No description provided for @refillReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get refillReminderOff;

  /// No description provided for @refillReminderDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{days} days before'**
  String refillReminderDaysBefore(int days);

  /// No description provided for @sideEffectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Known Side Effects'**
  String get sideEffectsLabel;

  /// No description provided for @addSideEffectHint.
  ///
  /// In en, this message translates to:
  /// **'Add side effect (e.g. Drowsiness)'**
  String get addSideEffectHint;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes...'**
  String get notesHint;

  /// No description provided for @addMedicineButton.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicineButton;

  /// No description provided for @updateMedicineButton.
  ///
  /// In en, this message translates to:
  /// **'Update Medicine'**
  String get updateMedicineButton;

  /// No description provided for @addMedicineImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine Image'**
  String get addMedicineImageTitle;

  /// No description provided for @chooseImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose image source'**
  String get chooseImageSource;

  /// No description provided for @captureFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image: {error}'**
  String captureFailed(Object error);

  /// No description provided for @pickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String pickFailed(Object error);

  /// No description provided for @extractedText.
  ///
  /// In en, this message translates to:
  /// **'Extracted: {text}'**
  String extractedText(String text);

  /// No description provided for @extractFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not extract text. Please enter details manually.'**
  String get extractFailed;

  /// No description provided for @extractionError.
  ///
  /// In en, this message translates to:
  /// **'Text extraction failed. Please enter manually.'**
  String get extractionError;

  /// No description provided for @medicineAutoName.
  ///
  /// In en, this message translates to:
  /// **'Medicine ({form}) - {time}'**
  String medicineAutoName(String form, String time);

  /// No description provided for @tabletForm.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tabletForm;

  /// No description provided for @capsuleForm.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get capsuleForm;

  /// No description provided for @liquidForm.
  ///
  /// In en, this message translates to:
  /// **'Liquid'**
  String get liquidForm;

  /// No description provided for @injectionForm.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get injectionForm;

  /// No description provided for @dailyFrequency.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailyFrequency;

  /// No description provided for @twiceDailyFrequency.
  ///
  /// In en, this message translates to:
  /// **'Twice Daily'**
  String get twiceDailyFrequency;

  /// No description provided for @threeTimesDailyFrequency.
  ///
  /// In en, this message translates to:
  /// **'Three Times Daily'**
  String get threeTimesDailyFrequency;

  /// No description provided for @weeklyFrequency.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyFrequency;

  /// No description provided for @asNeededFrequency.
  ///
  /// In en, this message translates to:
  /// **'As Needed'**
  String get asNeededFrequency;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @aiHealthAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Health Assistant'**
  String get aiHealthAssistant;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyze;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicine;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @aiEnrichmentInProgress.
  ///
  /// In en, this message translates to:
  /// **'AI is gathering medicine details...'**
  String get aiEnrichmentInProgress;

  /// No description provided for @aiEnrichmentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medicine details enriched by AI!'**
  String get aiEnrichmentSuccess;

  /// No description provided for @commonUsesLabel.
  ///
  /// In en, this message translates to:
  /// **'Common Uses:'**
  String get commonUsesLabel;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealSnack;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get aboutSubtitle;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs and contact'**
  String get helpSupportSubtitle;

  /// No description provided for @testCrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Crash'**
  String get testCrashTitle;

  /// No description provided for @testCrashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Force a crash (Dev only)'**
  String get testCrashSubtitle;

  /// No description provided for @manageNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get manageNotificationsSubtitle;

  /// No description provided for @readPrivacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get readPrivacyPolicySubtitle;

  /// No description provided for @readTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get readTermsSubtitle;

  /// No description provided for @showFavoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show Favorites'**
  String get showFavoritesTooltip;

  /// No description provided for @showAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAllTooltip;

  /// No description provided for @noFavoritePharmacies.
  ///
  /// In en, this message translates to:
  /// **'No favorite pharmacies found'**
  String get noFavoritePharmacies;

  /// No description provided for @timezoneUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Timezone Updated'**
  String get timezoneUpdatedTitle;

  /// No description provided for @timezoneUpdatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your reminders have been updated to {newTimezone}'**
  String timezoneUpdatedBody(Object newTimezone);

  /// No description provided for @logInTitle.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInTitle;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get newHere;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAccount;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @joinTickdo.
  ///
  /// In en, this message translates to:
  /// **'Join Tickdose'**
  String get joinTickdo;

  /// No description provided for @startManagingHealth.
  ///
  /// In en, this message translates to:
  /// **'Start managing your health journey today.'**
  String get startManagingHealth;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get rememberPassword;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get createNewPassword;

  /// No description provided for @passwordDifferent.
  ///
  /// In en, this message translates to:
  /// **'Your new password must be different from previous used passwords.'**
  String get passwordDifferent;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password requirements:'**
  String get passwordRequirements;

  /// No description provided for @atLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// No description provided for @containsNumber.
  ///
  /// In en, this message translates to:
  /// **'Contains a number'**
  String get containsNumber;

  /// No description provided for @containsSymbol.
  ///
  /// In en, this message translates to:
  /// **'Contains a symbol'**
  String get containsSymbol;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @defineActiveHours.
  ///
  /// In en, this message translates to:
  /// **'Define your active hours'**
  String get defineActiveHours;

  /// No description provided for @wakeWindowReminders.
  ///
  /// In en, this message translates to:
  /// **'Tickdose will only send reminders during your wake window to sync with your circadian rhythm.'**
  String get wakeWindowReminders;

  /// No description provided for @wakeUp.
  ///
  /// In en, this message translates to:
  /// **'Wake Up'**
  String get wakeUp;

  /// No description provided for @bedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get bedtime;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @routineSetup.
  ///
  /// In en, this message translates to:
  /// **'Routine Setup'**
  String get routineSetup;

  /// No description provided for @medicalBackground.
  ///
  /// In en, this message translates to:
  /// **'Medical Background'**
  String get medicalBackground;

  /// No description provided for @aiAnalyzeSymptoms.
  ///
  /// In en, this message translates to:
  /// **'This helps our AI analyze your symptoms more accurately and provide personalized insights.'**
  String get aiAnalyzeSymptoms;

  /// No description provided for @doYouHaveAllergies.
  ///
  /// In en, this message translates to:
  /// **'Do you have any allergies?'**
  String get doYouHaveAllergies;

  /// No description provided for @currentTimeDetected.
  ///
  /// In en, this message translates to:
  /// **'CURRENT TIME DETECTED'**
  String get currentTimeDetected;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @feelingUnwell.
  ///
  /// In en, this message translates to:
  /// **'Feeling unwell?'**
  String get feelingUnwell;

  /// No description provided for @logSideEffectButton.
  ///
  /// In en, this message translates to:
  /// **'Log Side Effect'**
  String get logSideEffectButton;

  /// No description provided for @supplyTracking.
  ///
  /// In en, this message translates to:
  /// **'Supply Tracking'**
  String get supplyTracking;

  /// No description provided for @requestRefill.
  ///
  /// In en, this message translates to:
  /// **'Request Refill'**
  String get requestRefill;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordMedium;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @passwordVeryStrong.
  ///
  /// In en, this message translates to:
  /// **'Very Strong'**
  String get passwordVeryStrong;

  /// No description provided for @medicationReminders.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminders'**
  String get medicationReminders;

  /// No description provided for @refillAlerts.
  ///
  /// In en, this message translates to:
  /// **'Refill Alerts'**
  String get refillAlerts;

  /// No description provided for @healthAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Health Analysis'**
  String get healthAnalysis;

  /// No description provided for @selectTimezone.
  ///
  /// In en, this message translates to:
  /// **'Select Timezone'**
  String get selectTimezone;

  /// No description provided for @noKnownAllergies.
  ///
  /// In en, this message translates to:
  /// **'I have no known allergies'**
  String get noKnownAllergies;

  /// No description provided for @chronicConditions.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get chronicConditions;

  /// No description provided for @logTaken.
  ///
  /// In en, this message translates to:
  /// **'Log Taken'**
  String get logTaken;

  /// No description provided for @interactionWarning.
  ///
  /// In en, this message translates to:
  /// **'Interaction Warning'**
  String get interactionWarning;

  /// No description provided for @noInteractionsDetected.
  ///
  /// In en, this message translates to:
  /// **'No interactions detected'**
  String get noInteractionsDetected;

  /// No description provided for @interactionsFound.
  ///
  /// In en, this message translates to:
  /// **'Interactions Found'**
  String get interactionsFound;

  /// No description provided for @proceedAnyway.
  ///
  /// In en, this message translates to:
  /// **'Proceed Anyway'**
  String get proceedAnyway;

  /// No description provided for @thisMedicineInteracts.
  ///
  /// In en, this message translates to:
  /// **'This medicine interacts with your current medications'**
  String get thisMedicineInteracts;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @nextDose.
  ///
  /// In en, this message translates to:
  /// **'NEXT DOSE'**
  String get nextDose;

  /// No description provided for @noUpcomingDose.
  ///
  /// In en, this message translates to:
  /// **'No upcoming dose'**
  String get noUpcomingDose;

  /// No description provided for @symptomCheck.
  ///
  /// In en, this message translates to:
  /// **'SYMPTOM CHECK'**
  String get symptomCheck;

  /// No description provided for @aboutThisDrug.
  ///
  /// In en, this message translates to:
  /// **'About this drug'**
  String get aboutThisDrug;

  /// No description provided for @readFullMonograph.
  ///
  /// In en, this message translates to:
  /// **'Read full monograph'**
  String get readFullMonograph;

  /// No description provided for @monographTitle.
  ///
  /// In en, this message translates to:
  /// **'{medicineName} Monograph'**
  String monographTitle(String medicineName);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine'**
  String get editMedicine;

  /// No description provided for @shareMedicine.
  ///
  /// In en, this message translates to:
  /// **'Share Medicine'**
  String get shareMedicine;

  /// No description provided for @iFeelAssistant.
  ///
  /// In en, this message translates to:
  /// **'I Feel Assistant'**
  String get iFeelAssistant;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get online;

  /// No description provided for @activeContext.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE CONTEXT'**
  String get activeContext;

  /// No description provided for @noActiveMedications.
  ///
  /// In en, this message translates to:
  /// **'No active medications'**
  String get noActiveMedications;

  /// No description provided for @viewMeds.
  ///
  /// In en, this message translates to:
  /// **'View Meds'**
  String get viewMeds;

  /// No description provided for @iFeelAI.
  ///
  /// In en, this message translates to:
  /// **'I Feel AI'**
  String get iFeelAI;

  /// No description provided for @describeSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Describe your symptoms to check for side effects'**
  String get describeSymptoms;

  /// No description provided for @logSymptom.
  ///
  /// In en, this message translates to:
  /// **'Log \"Dizziness\"'**
  String get logSymptom;

  /// No description provided for @reportSideEffect.
  ///
  /// In en, this message translates to:
  /// **'Report Side Effect'**
  String get reportSideEffect;

  /// No description provided for @callDoctor.
  ///
  /// In en, this message translates to:
  /// **'Call Doctor'**
  String get callDoctor;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'HEART RATE'**
  String get heartRate;

  /// No description provided for @voiceReminder.
  ///
  /// In en, this message translates to:
  /// **'Voice Reminder'**
  String get voiceReminder;

  /// No description provided for @recordNudge.
  ///
  /// In en, this message translates to:
  /// **'Record Nudge'**
  String get recordNudge;

  /// No description provided for @viewFullList.
  ///
  /// In en, this message translates to:
  /// **'View Full List'**
  String get viewFullList;

  /// No description provided for @noRemindersToday.
  ///
  /// In en, this message translates to:
  /// **'No reminders scheduled for today'**
  String get noRemindersToday;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @pillList.
  ///
  /// In en, this message translates to:
  /// **'Pill List'**
  String get pillList;

  /// No description provided for @refills.
  ///
  /// In en, this message translates to:
  /// **'Refills'**
  String get refills;

  /// No description provided for @barcodeScanned.
  ///
  /// In en, this message translates to:
  /// **'Barcode Scanned: {code}'**
  String barcodeScanned(String code);

  /// No description provided for @noBarcodeFound.
  ///
  /// In en, this message translates to:
  /// **'No barcode found in image'**
  String get noBarcodeFound;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @selectUnit.
  ///
  /// In en, this message translates to:
  /// **'Select Unit'**
  String get selectUnit;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @notifyLowStock.
  ///
  /// In en, this message translates to:
  /// **'Notify when stock is low'**
  String get notifyLowStock;

  /// No description provided for @translating.
  ///
  /// In en, this message translates to:
  /// **'Translating... / جاري الترجمة...'**
  String get translating;

  /// No description provided for @scanLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan Label'**
  String get scanLabel;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @interactionCheckActive.
  ///
  /// In en, this message translates to:
  /// **'Interaction Check Active'**
  String get interactionCheckActive;

  /// No description provided for @interactions.
  ///
  /// In en, this message translates to:
  /// **'Interactions'**
  String get interactions;

  /// No description provided for @monograph.
  ///
  /// In en, this message translates to:
  /// **'Monograph'**
  String get monograph;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @drops.
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get drops;

  /// No description provided for @loadingMedicines.
  ///
  /// In en, this message translates to:
  /// **'Loading medicines...'**
  String get loadingMedicines;

  /// No description provided for @apiKeyNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'API key not configured'**
  String get apiKeyNotConfigured;

  /// No description provided for @loadingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Loading schedule...'**
  String get loadingSchedule;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @reminderSchedule.
  ///
  /// In en, this message translates to:
  /// **'Reminder Schedule'**
  String get reminderSchedule;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @yourPrivacyMatters.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Matters'**
  String get yourPrivacyMatters;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'At TICKDOSE, we are committed to protecting your personal information and your right to privacy.'**
  String get privacyPolicyIntro;

  /// No description provided for @whatDataWeCollect.
  ///
  /// In en, this message translates to:
  /// **'1. What Data We Collect'**
  String get whatDataWeCollect;

  /// No description provided for @whatDataWeCollectContent.
  ///
  /// In en, this message translates to:
  /// **'We collect information that you provide directly to us, including:\n\n• Medicines: Names, dosages, and schedules you add.\n• Reminders: Times and frequencies for your notifications.\n• Location: Used only when you access the Pharmacy Finder feature.\n• Health Profile: Conditions, allergies, and other health data you choose to save.\n• Usage Data: Anonymous analytics to help us improve the app.'**
  String get whatDataWeCollectContent;

  /// No description provided for @howWeUseYourData.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Data'**
  String get howWeUseYourData;

  /// No description provided for @howWeUseYourDataContent.
  ///
  /// In en, this message translates to:
  /// **'We use the information we collect to:\n\n• Send you timely medication reminders and notifications.\n• Track your medication adherence and provide statistics.\n• Improve app features and user experience.\n• Analyze usage patterns to fix bugs and enhance performance.\n• Comply with legal obligations.'**
  String get howWeUseYourDataContent;

  /// No description provided for @dataStorageSecurity.
  ///
  /// In en, this message translates to:
  /// **'3. Data Storage & Security'**
  String get dataStorageSecurity;

  /// No description provided for @dataStorageSecurityContent.
  ///
  /// In en, this message translates to:
  /// **'• All your personal data is stored securely in Google Firebase.\n• Data is encrypted in transit using HTTPS.\n• We implement robust security measures to protect your information.\n• We perform regular backups to prevent data loss.\n• We are committed to GDPR compliance and data protection standards.'**
  String get dataStorageSecurityContent;

  /// No description provided for @yourRights.
  ///
  /// In en, this message translates to:
  /// **'4. Your Rights'**
  String get yourRights;

  /// No description provided for @yourRightsContent.
  ///
  /// In en, this message translates to:
  /// **'You have the following rights regarding your data:\n\n• Access: You can view your data within the app at any time.\n• Export: You can request a copy of your data.\n• Deletion: You can delete your account and all associated data via the Settings menu.\n• Opt-out: You can opt-out of anonymous analytics tracking.'**
  String get yourRightsContent;

  /// No description provided for @thirdPartyServices.
  ///
  /// In en, this message translates to:
  /// **'5. Third-Party Services'**
  String get thirdPartyServices;

  /// No description provided for @thirdPartyServicesContent.
  ///
  /// In en, this message translates to:
  /// **'We use trusted third-party services to operate the app:\n\n• Google & Apple: For secure authentication.\n• Firebase: For secure cloud database and storage.\n• Google Maps / OpenStreetMap: For the pharmacy finder feature.\n• Google Generative AI (Gemini): For the \"I Feel\" symptom checker and medication information enrichment (optional, can be disabled in settings).'**
  String get thirdPartyServicesContent;

  /// No description provided for @aiUsageDisclosure.
  ///
  /// In en, this message translates to:
  /// **'AI Usage Disclosure'**
  String get aiUsageDisclosure;

  /// No description provided for @aiUsageDisclosureContent.
  ///
  /// In en, this message translates to:
  /// **'TICKDOSE uses Google Generative AI (Gemini) for the following features:\n\n• Symptom Analysis: The \"I Feel\" feature uses AI to analyze your symptoms and provide general health information. This is NOT medical diagnosis.\n• Medication Enrichment: AI may be used to enrich medication information when you add medicines.\n\nIMPORTANT:\n• AI features are OPTIONAL and can be disabled in Settings.\n• AI responses are for informational purposes only and are NOT a substitute for professional medical advice.\n• Your health data is processed securely and is not used to train AI models.\n• You can opt-out of AI features at any time.\n• AI usage requires internet connection.\n\nFor more details, see our Privacy Policy.'**
  String get aiUsageDisclosureContent;

  /// No description provided for @aiUsageOptIn.
  ///
  /// In en, this message translates to:
  /// **'Enable AI Features'**
  String get aiUsageOptIn;

  /// No description provided for @aiUsageOptOut.
  ///
  /// In en, this message translates to:
  /// **'Disable AI Features'**
  String get aiUsageOptOut;

  /// No description provided for @aiUsageStatus.
  ///
  /// In en, this message translates to:
  /// **'AI Features: {status}'**
  String aiUsageStatus(String status);

  /// No description provided for @contactUsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'6. Contact Us'**
  String get contactUsPrivacy;

  /// No description provided for @contactUsPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@tickdose.app\n\nWe take your privacy seriously and will respond to all inquiries promptly.'**
  String get contactUsPrivacyContent;

  /// No description provided for @policyChanges.
  ///
  /// In en, this message translates to:
  /// **'7. Policy Changes'**
  String get policyChanges;

  /// No description provided for @policyChangesContent.
  ///
  /// In en, this message translates to:
  /// **'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the \"Last Updated\" date.'**
  String get policyChangesContent;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: November 24, 2024'**
  String get lastUpdated;

  /// No description provided for @sharePrivacyPolicyText.
  ///
  /// In en, this message translates to:
  /// **'Check out Tickdose Privacy Policy: https://tickdosedemo.web.app/privacy-policy'**
  String get sharePrivacyPolicyText;

  /// No description provided for @sharePrivacyPolicySubject.
  ///
  /// In en, this message translates to:
  /// **'Tickdose Privacy Policy'**
  String get sharePrivacyPolicySubject;

  /// No description provided for @couldNotOpenPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Could not open privacy policy'**
  String get couldNotOpenPrivacyPolicy;

  /// No description provided for @termsOfServiceIntro.
  ///
  /// In en, this message translates to:
  /// **'Please read these terms carefully before using the TICKDOSE application.'**
  String get termsOfServiceIntro;

  /// No description provided for @licenseToUse.
  ///
  /// In en, this message translates to:
  /// **'1. License to Use'**
  String get licenseToUse;

  /// No description provided for @licenseToUseContent.
  ///
  /// In en, this message translates to:
  /// **'TICKDOSE grants you a personal, non-transferable, non-exclusive, revocable license to use the software for your personal, non-commercial use in accordance with these Terms. You own your personal data, but we retain all rights to the application code, design, and intellectual property.'**
  String get licenseToUseContent;

  /// No description provided for @restrictions.
  ///
  /// In en, this message translates to:
  /// **'2. Restrictions'**
  String get restrictions;

  /// No description provided for @restrictionsContent.
  ///
  /// In en, this message translates to:
  /// **'You agree not to:\n\n• Use the app for any illegal purpose.\n• Attempt to reverse engineer or decompile the app.\n• Share your account credentials with others.\n• Use the app to spam or harass others.\n• Attempt to breach the app\'s security measures.'**
  String get restrictionsContent;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'3. Medical Disclaimer'**
  String get medicalDisclaimer;

  /// No description provided for @medicalDisclaimerContent.
  ///
  /// In en, this message translates to:
  /// **'⚠️ TICKDOSE IS NOT A DOCTOR.\n\n• This app is not a substitute for professional medical advice, diagnosis, or treatment.\n• Never disregard professional medical advice or delay in seeking it because of something you have read on this app.\n• The data provided is for informational purposes only.\n• In case of a medical emergency, call your doctor or emergency services immediately.\n• We cannot diagnose, treat, or cure any condition.'**
  String get medicalDisclaimerContent;

  /// No description provided for @userResponsibilities.
  ///
  /// In en, this message translates to:
  /// **'4. User Responsibilities'**
  String get userResponsibilities;

  /// No description provided for @userResponsibilitiesContent.
  ///
  /// In en, this message translates to:
  /// **'• You are responsible for the accuracy of the health data you enter.\n• You are responsible for maintaining the confidentiality of your account.\n• You agree to comply with all applicable laws and regulations.\n• You are solely liable for your use of the application.'**
  String get userResponsibilitiesContent;

  /// No description provided for @limitationOfLiability.
  ///
  /// In en, this message translates to:
  /// **'5. Limitation of Liability'**
  String get limitationOfLiability;

  /// No description provided for @limitationOfLiabilityContent.
  ///
  /// In en, this message translates to:
  /// **'To the maximum extent permitted by law, TICKDOSE shall NOT be liable for:\n\n• Any indirect, incidental, special, consequential, or punitive damages.\n• Any loss of data, use, goodwill, or other intangible losses.\n• Any missed doses or reminders due to technical failures.\n• Any adverse health outcomes resulting from reliance on the app.\n\nOur maximum liability is limited to the amount you paid for the app, if any.'**
  String get limitationOfLiabilityContent;

  /// No description provided for @termination.
  ///
  /// In en, this message translates to:
  /// **'6. Termination'**
  String get termination;

  /// No description provided for @terminationContent.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination, your right to use the Service will immediately cease.'**
  String get terminationContent;

  /// No description provided for @changesToTerms.
  ///
  /// In en, this message translates to:
  /// **'7. Changes to Terms'**
  String get changesToTerms;

  /// No description provided for @changesToTermsContent.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify or replace these Terms at any time. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.'**
  String get changesToTermsContent;

  /// No description provided for @contactUsTerms.
  ///
  /// In en, this message translates to:
  /// **'8. Contact Us'**
  String get contactUsTerms;

  /// No description provided for @contactUsTermsContent.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about these Terms, please contact us at:\n\nEmail: support@tickdose.app'**
  String get contactUsTermsContent;

  /// No description provided for @couldNotOpenTerms.
  ///
  /// In en, this message translates to:
  /// **'Could not open terms of service'**
  String get couldNotOpenTerms;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your medicines, reminders, tracking data, and account information will be permanently deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountPermanently.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all data'**
  String get deleteAccountPermanently;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccess;

  /// No description provided for @errorDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String errorDeletingAccount(Object error);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorGeneric;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @yourPersonalMedicationReminder.
  ///
  /// In en, this message translates to:
  /// **'Your personal medication reminder'**
  String get yourPersonalMedicationReminder;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @howToAddMedicine.
  ///
  /// In en, this message translates to:
  /// **'How do I add a medicine?'**
  String get howToAddMedicine;

  /// No description provided for @howToAddMedicineAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button on the home screen to add a new medicine.'**
  String get howToAddMedicineAnswer;

  /// No description provided for @howToSetReminders.
  ///
  /// In en, this message translates to:
  /// **'How do I set reminders?'**
  String get howToSetReminders;

  /// No description provided for @howToSetRemindersAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Reminders tab and tap + to create a new reminder.'**
  String get howToSetRemindersAnswer;

  /// No description provided for @canIEditMedicines.
  ///
  /// In en, this message translates to:
  /// **'Can I edit my medicines?'**
  String get canIEditMedicines;

  /// No description provided for @canIEditMedicinesAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, tap on any medicine to view details and tap Edit.'**
  String get canIEditMedicinesAnswer;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @createInvitation.
  ///
  /// In en, this message translates to:
  /// **'Create Invitation'**
  String get createInvitation;

  /// No description provided for @selectAtLeastOnePermission.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one permission'**
  String get selectAtLeastOnePermission;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @permissionsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Permissions updated'**
  String get permissionsUpdated;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get friend;

  /// No description provided for @nurse.
  ///
  /// In en, this message translates to:
  /// **'Nurse'**
  String get nurse;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add Time'**
  String get addTime;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @barcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode: {code}'**
  String barcodeLabel(String code);

  /// No description provided for @timesLabel.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get timesLabel;

  /// No description provided for @doctorDisplayFormat.
  ///
  /// In en, this message translates to:
  /// **'Dr. {name} ({specialization})'**
  String doctorDisplayFormat(String name, String specialization);

  /// No description provided for @dosageHintExample.
  ///
  /// In en, this message translates to:
  /// **'10'**
  String get dosageHintExample;

  /// No description provided for @unitMg.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get unitMg;

  /// No description provided for @unitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitUnits.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get unitUnits;

  /// No description provided for @unitTablets.
  ///
  /// In en, this message translates to:
  /// **'tablets'**
  String get unitTablets;

  /// No description provided for @unitCapsules.
  ///
  /// In en, this message translates to:
  /// **'capsules'**
  String get unitCapsules;

  /// No description provided for @noKnownConflicts.
  ///
  /// In en, this message translates to:
  /// **'No known conflicts with your current list.'**
  String get noKnownConflicts;

  /// No description provided for @addMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicineTitle;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image: {error}'**
  String failedToUploadImage(Object error);

  /// No description provided for @errorFailedToShare.
  ///
  /// In en, this message translates to:
  /// **'Error: Failed to share: {error}'**
  String errorFailedToShare(Object error);

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDelete(Object error);

  /// No description provided for @pleaseLogInToViewSideEffects.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view side effects'**
  String get pleaseLogInToViewSideEffects;

  /// No description provided for @errorLoadingSideEffects.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLoadingSideEffects(Object error);

  /// No description provided for @deleteSideEffectQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Side Effect?'**
  String get deleteSideEffectQuestion;

  /// No description provided for @deleteSideEffectWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteSideEffectWarning;

  /// No description provided for @sideEffectDeleted.
  ///
  /// In en, this message translates to:
  /// **'Side effect deleted'**
  String get sideEffectDeleted;

  /// No description provided for @logSideEffectTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Side Effect'**
  String get logSideEffectTitle;

  /// No description provided for @sideEffectLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Side effect logged successfully'**
  String get sideEffectLoggedSuccess;

  /// No description provided for @effectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Effect Name'**
  String get effectNameLabel;

  /// No description provided for @effectNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Nausea, Headache'**
  String get effectNameHint;

  /// No description provided for @whenDidThisOccur.
  ///
  /// In en, this message translates to:
  /// **'When did this occur?'**
  String get whenDidThisOccur;

  /// No description provided for @notesOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptionalLabel;

  /// No description provided for @notesOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Additional details about the side effect'**
  String get notesOptionalHint;

  /// No description provided for @iUnderstandTheRisks.
  ///
  /// In en, this message translates to:
  /// **'I understand the risks'**
  String get iUnderstandTheRisks;

  /// No description provided for @searchMedicinesHint.
  ///
  /// In en, this message translates to:
  /// **'Search medicines...'**
  String get searchMedicinesHint;

  /// No description provided for @medsLabel.
  ///
  /// In en, this message translates to:
  /// **'MEDS'**
  String get medsLabel;

  /// No description provided for @plusOneToday.
  ///
  /// In en, this message translates to:
  /// **'+1 today'**
  String get plusOneToday;

  /// No description provided for @adherencePercentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% adherence'**
  String adherencePercentage(String percentage);

  /// No description provided for @xpToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to Level {level}'**
  String xpToNextLevel(String xp, String level);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
