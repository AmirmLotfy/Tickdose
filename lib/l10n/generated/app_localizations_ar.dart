// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تيك دوس';

  @override
  String get yesAction => 'نعم';

  @override
  String get noAction => 'لا';

  @override
  String get refillReminderTitle => 'تذكير إعادة التعبئة';

  @override
  String refillReminderBody(String medicineName) {
    return 'حان وقت إعادة تعبئة $medicineName.';
  }

  @override
  String get home => 'الرئيسية';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get tracking => 'المتابعة';

  @override
  String get pharmacy => 'الصيدلية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsSoundEffects => 'تأثيرات صوتية';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get onboardingTitle1 => 'لا تفوت موعد دوائك أبداً';

  @override
  String get onboardingDesc1 =>
      'احصل على تذكيرات في الوقت المناسب لجميع أدويتك وحافظ على صحتك في المسار الصحيح.';

  @override
  String get onboardingTitle2 => 'تتبع التزامك';

  @override
  String get onboardingDesc2 =>
      'راقب تقدمك باستخدام إحصائيات مفصلة وسجلات التاريخ.';

  @override
  String get onboardingTitle3 => 'اعثر على الصيدليات القريبة';

  @override
  String get onboardingDesc3 =>
      'حدد موقع أقرب الصيدليات وتحقق من توفرها فوراً.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get splashTagline => 'لا تفوت موعد دوائك أبداً';

  @override
  String get reminderTitle => 'حان وقت تناول الدواء';

  @override
  String reminderBody(String dosage, String medicineName) {
    return 'تناول $medicineName الآن.';
  }

  @override
  String voiceReminderStandard(String dosage, String medicineName) {
    return 'حان وقت تناول $dosage من $medicineName. يرجى تناول دوائك الآن للحفاظ على صحتك.';
  }

  @override
  String voiceReminderMeal(
      String mealTime, String dosage, String medicineName) {
    return 'إنه وقت $mealTime! تناول $dosage من $medicineName مع الطعام. يرجى تناول دوائك الآن للحفاظ على صحتك.';
  }

  @override
  String get goodMorning => 'صباح الخير!';

  @override
  String get goodAfternoon => 'طاب مساؤك!';

  @override
  String get goodEvening => 'مساء الخير!';

  @override
  String get hello => 'مرحباً!';

  @override
  String get medicineDetailsTitle => 'تفاصيل الدواء';

  @override
  String get deleteMedicineTitle => 'حذف الدواء';

  @override
  String get deleteMedicineQuestion => 'حذف الدواء؟';

  @override
  String get deleteMedicineContent => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get dialogCancel => 'إلغاء';

  @override
  String get dialogDelete => 'حذف';

  @override
  String get tabDetails => 'التفاصيل';

  @override
  String get tabSideEffects => 'الآثار الجانبية';

  @override
  String get tabInteractions => 'تفاعلات الأدوية';

  @override
  String get logSideEffect => 'تسجيل أثر جانبي';

  @override
  String genericName(String name) {
    return 'الاسم العلمي: $name';
  }

  @override
  String get imageNotAvailable => 'الصورة غير متوفرة';

  @override
  String get dosageInfo => 'معلومات الجرعة';

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
  String get manufacturerInfo => 'الشركة المصنعة';

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
  String get prescriptionDetails => 'تفاصيل الوصفة';

  @override
  String prescribedByValue(String name) {
    return 'Prescribed by: $name';
  }

  @override
  String dateValue(String date) {
    return 'Date: $date';
  }

  @override
  String get knownSideEffects => 'الآثار الجانبية المعروفة';

  @override
  String get remindersLabel => 'التذكيرات';

  @override
  String refillReminderValue(int days) {
    return 'Refill reminder: $days days before';
  }

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String get expiringSoonWarning => 'هذا الدواء سينتهي قريباً!';

  @override
  String get expiredWarning => 'هذا الدواء منتهي الصلاحية!';

  @override
  String get interactionsTitle => 'التفاعلات الدوائية';

  @override
  String get noInteractions => 'لا توجد تفاعلات معروفة.';

  @override
  String get healthProfileCheck => 'فحص الملف الصحي';

  @override
  String get safeForHealth => 'آمن بالنسبة لملفك الصحي';

  @override
  String get foodInteractionsTitle => 'تفاعلات الطعام';

  @override
  String get noFoodInteractions => 'لا توجد تفاعلات طعام معروفة.';

  @override
  String get myMedicinesTitle => 'أدويتي';

  @override
  String get noMedicinesAdded => 'لم تتم إضافة أدوية بعد';

  @override
  String helloUser(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get homeTagline => 'لنحافظ على صحتك اليوم!';

  @override
  String get todaysMedicines => 'أدوية اليوم';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get noMedicinesToday => 'لا توجد أدوية مجدولة لليوم';

  @override
  String get addReminder => 'إضافة تذكير';

  @override
  String get editReminder => 'تعديل تذكير';

  @override
  String get errorLoadingReminders => 'خطأ في تحميل التذكيرات';

  @override
  String markedAsTaken(String medicine) {
    return '✓ تم تحديد $medicine كـ مأخوذ';
  }

  @override
  String skippedMedicine(String medicine) {
    return 'تخطي $medicine';
  }

  @override
  String get takeAction => 'تناول';

  @override
  String get skipAction => 'تخطي';

  @override
  String get adherenceLabel => 'الالتزام';

  @override
  String get streakLabel => 'السلسلة';

  @override
  String streakDays(int days) {
    return '$days أيام';
  }

  @override
  String get iFeelTitle => 'أشعر بـ';

  @override
  String get iFeelSubtitle => 'افحص الأعراض - نص أو صوت';

  @override
  String get trackingTitle => 'تتبع';

  @override
  String get analyzingReport => 'جاري إنشاء تقرير PDF...';

  @override
  String get reportSuccess => 'تم إنشاء التقرير بنجاح!';

  @override
  String reportError(Object error) {
    return 'خطأ في إنشاء التقرير: $error';
  }

  @override
  String get pleaseLogin => 'Please log in to continue';

  @override
  String get medicineAddedSuccessfully => 'Medicine added successfully!';

  @override
  String get saving => 'Saving...';

  @override
  String get historyTitle => 'السجل';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get notificationsLabel => 'الإشعارات';

  @override
  String get notificationsSubtitle => 'استلام تذكيرات الدواء';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get privacyPolicyLabel => 'سياسة الخصوصية';

  @override
  String get darkModeLabel => 'الوضع الداكن';

  @override
  String get darkModeSubtitle => 'استخدام المظهر الداكن';

  @override
  String get accountTitle => 'الحساب';

  @override
  String get caregiversLabel => 'مقدمو الرعاية';

  @override
  String get acceptInvitationLabel => 'قبول دعوة';

  @override
  String get changePasswordLabel => 'تغيير كلمة المرور';

  @override
  String get deleteAccountLabel => 'حذف الحساب';

  @override
  String get logoutLabel => 'تسجيل الخروج';

  @override
  String get findPharmacyTitle => 'ابحث عن صيدلية';

  @override
  String get locationAccessRequired => 'مطلوب إذن الموقع';

  @override
  String get locationAccessRationale =>
      'قم بتفعيل خدمات الموقع للعثور على الصيدليات القريبة';

  @override
  String get enableLocationAction => 'تفعيل الموقع';

  @override
  String pharmacyError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get noPharmaciesFound => 'لم يتم العثور على صيدليات قريبة';

  @override
  String pharmaciesFoundCount(int count) {
    return '$count صيدلية';
  }

  @override
  String get directionsAction => 'الاتجاهات';

  @override
  String get callAction => 'اتصال';

  @override
  String get websiteAction => 'الموقع الإلكتروني';

  @override
  String get showMapAction => 'عرض الخريطة';

  @override
  String get showListAction => 'عرض القائمة';

  @override
  String get myDoctorsTitle => 'أطبائي';

  @override
  String get addDoctorTitle => 'إضافة دكتور';

  @override
  String get deleteDoctorTitle => 'حذف الدكتور؟';

  @override
  String get deleteDoctorContent =>
      'هل أنت متأكد أنك تريد إزالة هذا الدكتور من قائمتك؟';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get deleteButton => 'حذف';

  @override
  String get pleaseLogIn => 'يرجى تسجيل الدخول';

  @override
  String get noDoctorsAdded => 'لم يتم إضافة أطباء بعد';

  @override
  String get tapToAddDoctor => 'اضغط على \"إضافة دكتور\" للبدء';

  @override
  String get doctorNameLabel => 'اسم الدكتور';

  @override
  String get doctorNameHint => 'مثال: د. أحمد';

  @override
  String get doctorNameRequired => 'يرجى إدخال الاسم';

  @override
  String get specializationLabel => 'التخصص';

  @override
  String get specializationRequired => 'يرجى اختيار التخصص';

  @override
  String get phoneNumberLabel => 'رقم الهاتف';

  @override
  String get phoneRequired => 'يرجى إدخال رقم هاتف صحيح';

  @override
  String get doctorAddedSuccess => 'تم إضافة الدكتور بنجاح';

  @override
  String doctorAddError(Object error) {
    return 'خطأ في إضافة الدكتور: $error';
  }

  @override
  String get specializationGeneral => 'طبيب عام';

  @override
  String get specializationCardiologist => 'طبيب قلب';

  @override
  String get specializationDermatologist => 'طبيب جلدية';

  @override
  String get specializationNeurologist => 'طبيب أعصاب';

  @override
  String get specializationPsychiatrist => 'طبيب نفسي';

  @override
  String get specializationEndocrinologist => 'طبيب غدد صماء';

  @override
  String get specializationPediatrician => 'طبيب أطفال';

  @override
  String get specializationSurgeon => 'جراح';

  @override
  String get specializationDentist => 'طبيب أسنان';

  @override
  String get specializationOther => 'آخر';

  @override
  String get caregiverDashboardTitle => 'لوحة تحكم مقدم الرعاية';

  @override
  String get patientMedicationsTitle => 'أدوية المريض';

  @override
  String get readOnlyView => 'عرض للقراءة فقط';

  @override
  String get todaysMedicationsTitle => 'أدوية اليوم';

  @override
  String get noMedicationsToday => 'لا توجد أدوية مجدولة لليوم';

  @override
  String get sendVoiceReminderTooltip => 'إرسال تذكير صوتي';

  @override
  String get voiceReminderSent => 'تم إرسال التذكير الصوتي';

  @override
  String get allMedicationsTitle => 'كل الأدوية';

  @override
  String get noMedicationsAdded => 'لم يتم إضافة أدوية';

  @override
  String errorLabel(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get acceptInvitationTitle => 'قبول الدعوة';

  @override
  String get invitationCodeLabel => 'رمز الدعوة';

  @override
  String get enterInvitationCodePrompt => 'أدخل الرمز المكون من 64 حرفاً';

  @override
  String get invitationCodeInputLabel => 'أدخل رمز الدعوة';

  @override
  String get invitationCodeInputDescription =>
      'أدخل رمز الدعوة الذي استلمته من المريض لتصبح مقدم رعاية له.';

  @override
  String get validateCodeButton => 'التحقق من الرمز';

  @override
  String get acceptInvitationButton => 'قبول الدعوة';

  @override
  String get declineButton => 'رفض';

  @override
  String get pleaseLogInToAccept => 'يرجى تسجيل الدخول أولاً لقبول الدعوة';

  @override
  String get invitationAcceptedSuccess => 'تم قبول الدعوة بنجاح!';

  @override
  String get invitationAcceptedView =>
      'تم قبول الدعوة! يمكنك الآن عرض أدوية المريض.';

  @override
  String get invitationFailed =>
      'فشل قبول الدعوة. قد يكون الرمز غير صالح أو منتهي الصلاحية.';

  @override
  String get invitationError => 'خطأ في قبول الدعوة. يرجى المحاولة مرة أخرى.';

  @override
  String get invalidInvitationFormat => 'صيغة رمز الدعوة غير صالحة';

  @override
  String get invitationNotFound => 'رمز الدعوة غير موجود';

  @override
  String get invitationUsed => 'تم استخدام هذه الدعوة مسبقاً';

  @override
  String get invitationExpired => 'انتهت صلاحية هذه الدعوة';

  @override
  String get loginRequiredNote =>
      'ملاحظة: يجب أن تكون مسجلاً للدخول لقبول الدعوة.';

  @override
  String get howToFindCodeTitle => 'كيف تجد رمز الدعوة الخاص بك:';

  @override
  String get howToFindCodeStep1 => '1. اطلب من المريض مشاركة رمز الدعوة';

  @override
  String get howToFindCodeStep2 =>
      '2. أو امسح رمز الاستجابة السريعة (QR) الذي قدموه';

  @override
  String get howToFindCodeStep3 => '3. أدخل الرمز في الحقل أعلاه';

  @override
  String get invalidInvitationTitle => 'دعوة غير صالحة';

  @override
  String get invalidInvitationMessage =>
      'هذه الدعوة غير صالحة أو منتهية الصلاحية.';

  @override
  String get invitationUsedTitle => 'الدعوة مستخدمة';

  @override
  String get invitationUsedMessage => 'تم استخدام هذه الدعوة بالفعل.';

  @override
  String get invitedTitle => 'لقد تمت دعوتك!';

  @override
  String get invitedMessage => 'لقد تمت دعوتك للمساعدة في إدارة الأدوية.';

  @override
  String get permissionsTitle => 'سيكون لديك صلاحية الوصول إلى:';

  @override
  String get invitationLinkCopied => 'تم نسخ رابط الدعوة إلى الحافظة';

  @override
  String get invitationCodeCopied => 'تم نسخ رمز الدعوة إلى الحافظة';

  @override
  String shareInvitationText(String url, String token) {
    return 'لقد تمت دعوتك لتكون مقدم رعاية على Tickdose!\n\nانقر هنا للقبول: $url\n\nأو أدخل هذا الرمز في التطبيق: $token';
  }

  @override
  String get shareInvitationSubject => 'دعوة مقدم رعاية من Tickdose';

  @override
  String errorSharing(Object error) {
    return 'خطأ في المشاركة: $error';
  }

  @override
  String get invitationTitle => 'دعوة';

  @override
  String get shareInvitationTitle => 'مشاركة الدعوة';

  @override
  String shareInvitationSubtitle(String email) {
    return 'شارك هذه الدعوة مع $email';
  }

  @override
  String get scanQrCodeTitle => 'مسح رمز QR';

  @override
  String get scanQrCodeDescription =>
      'يمكن لمقدم الرعاية مسح هذا الرمز بكاميرا الهاتف أو تطبيق Tickdose';

  @override
  String get invitationLinkTitle => 'رابط الدعوة';

  @override
  String get copyLinkTooltip => 'نسخ الرابط';

  @override
  String get ifQrNotWorking =>
      'إذا لم يعمل رمز QR، يمكن لمقدم الرعاية إدخال الرمز يدوياً:';

  @override
  String get copyCodeTooltip => 'نسخ الرمز';

  @override
  String get shareInvitationButton => 'مشاركة الدعوة';

  @override
  String get howToShareTitle => 'كيفية المشاركة:';

  @override
  String get howToShareStep1Title => '1. اعرض رمز QR لمقدم الرعاية';

  @override
  String get howToShareStep1Desc => 'يمكنهم مسحه بكاميرا هواتفهم';

  @override
  String get howToShareStep2Title => '2. شارك الرابط';

  @override
  String get howToShareStep2Desc =>
      'أرسل عبر الرسائل أو البريد الإلكتروني أو أي تطبيق مراسلة';

  @override
  String get howToShareStep3Title => '3. شارك الرمز';

  @override
  String get howToShareStep3Desc =>
      'يمكن لمقدم الرعاية إدخال الرمز يدوياً في التطبيق';

  @override
  String get microphonePermissionRequired => 'إذن الميكروفون مطلوب';

  @override
  String recordingError(Object error) {
    return 'خطأ في بدء التسجيل: $error';
  }

  @override
  String get voiceMessageSaved => 'تم حفظ الرسالة الصوتية!';

  @override
  String get recordVoiceMessageTitle => 'تسجيل رسالة صوتية';

  @override
  String voiceMessageFor(String medicineName) {
    return 'رسالة صوتية لـ $medicineName';
  }

  @override
  String get recordVoiceMessageDescription =>
      'سجل تذكيراً صوتياً شخصياً (مجرد 15 ثانية كحد أقصى)';

  @override
  String get startRecordingButton => 'بدء التسجيل';

  @override
  String get stopRecordingButton => 'إيقاف التسجيل';

  @override
  String get saveVoiceMessageButton => 'حفظ الرسالة الصوتية';

  @override
  String generatingPdfMessage(String month) {
    return 'جاري إنشاء تقرير PDF لشهر $month...';
  }

  @override
  String pdfGeneratedSuccess(String path) {
    return 'تم إنشاء التقرير! محفوظ في $path';
  }

  @override
  String pdfGenerationError(Object error) {
    return 'خطأ في إنشاء التقرير: $error';
  }

  @override
  String get exportPdfButton => 'تصدير تقرير PDF';

  @override
  String get userDataNotAvailable => 'بيانات المستخدم غير متوفرة';

  @override
  String get welcomeBack => 'مرحباً بعودتك!';

  @override
  String get signInContinue => 'سجل الدخول للمتابعة';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailValidation => 'الرجاء إدخال البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordValidation => 'الرجاء إدخال كلمة المرور';

  @override
  String get forgotPasswordButton => 'نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get continueGoogle => 'المتابعة باستخدام Google';

  @override
  String get continueApple => 'المتابعة باستخدام Apple';

  @override
  String get useBiometricLogin => 'استخدام الدخول بالبصمة';

  @override
  String get biometricNotAvailable =>
      'المصادقة البيومترية غير متوفرة على هذا الجهاز';

  @override
  String get biometricEnablePrompt =>
      'يرجى تسجيل الدخول بشكل طبيعي أولاً لتفعيل الدخول بالبصمة';

  @override
  String get biometricAuthFailed => 'فشلت المصادقة البيومترية';

  @override
  String biometricLoginFailed(Object error) {
    return 'فشل الدخول بالبصمة: $error';
  }

  @override
  String get noAccountPrompt => 'ليس لديك حساب؟ ';

  @override
  String get signUpButton => 'إنشاء حساب';

  @override
  String get createAccountTitle => 'إنشاء حساب';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get signInButton => 'تسجيل الدخول';

  @override
  String get startJourneySubtitle => 'ابدأ رحلتك نحو صحة أفضل';

  @override
  String get termsAgreementValidation =>
      'يرجى الموافقة على شروط الخدمة وسياسة الخصوصية';

  @override
  String get registrationSuccess =>
      'تم التسجيل بنجاح! يرجى التحقق من بريدك الإلكتروني.';

  @override
  String get nameHint => 'أدخل اسمك الكامل';

  @override
  String get nameValidation => 'الرجاء إدخال الاسم';

  @override
  String get emailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get emailInvalid => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get passwordHint => 'أدخل كلمة مرور قوية';

  @override
  String get passwordEmpty => 'الرجاء إدخال كلمة المرور';

  @override
  String get confirmPasswordHint => 'تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get termsAgreementPrefix => 'أوافق على ';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get termsAgreementAnd => ' و ';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get orSeparator => 'أو';

  @override
  String get loginLink => 'تسجيل الدخول';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني لاستلام رابط إعادة تعيين كلمة المرور';

  @override
  String get sendResetLinkButton => 'إرسال الرابط';

  @override
  String get passwordResetSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور! يرجى التحقق من بريدك الإلكتروني.';

  @override
  String get resetPasswordButton => 'إعادة تعيين كلمة المرور';

  @override
  String get emailVerifiedSuccess => 'تم التحقق من البريد الإلكتروني بنجاح!';

  @override
  String get emailNotVerifiedYet =>
      'لم يتم التحقق من البريد الإلكتروني بعد. يرجى التحقق من بريدك.';

  @override
  String get resendEmailButton => 'إعادة إرسال البريد الإلكتروني';

  @override
  String get verificationEmailSent =>
      'تم إرسال بريد التحقق! يرجى التحقق من بريدك الإلكتروني.';

  @override
  String get verifyEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get verifyEmailSubtitle =>
      'لقد أرسلنا رابط التحقق إلى عنوان بريدك الإلكتروني. يرجى التحقق للمتابعة.';

  @override
  String get iHaveVerifiedButton => 'لقد قمت بالتحقق';

  @override
  String get speechNotAvailable => 'خدمة التعرف على الصوت غير متوفرة';

  @override
  String get tapToAddImage => 'اضغط لإضافة صورة الدواء';

  @override
  String get cameraLabel => 'الكاميرا';

  @override
  String get galleryLabel => 'المعرض';

  @override
  String get medicineNameLabel => 'اسم الدواء';

  @override
  String get medicineNameHint => 'أدخل اسم الدواء';

  @override
  String get medicineNameRequired => 'يرجى إدخال اسم الدواء';

  @override
  String get strengthLabel => 'القوة (اختياري)';

  @override
  String get strengthHint => 'مثال: 500 ملغ';

  @override
  String get dosageLabel => 'الجرعة';

  @override
  String get dosageHint => 'مثال: 1 قرص';

  @override
  String get dosageRequired => 'يرجى إدخال الجرعة';

  @override
  String get formLabel => 'الشكل الصيدلاني';

  @override
  String get formHint => 'اختر الشكل';

  @override
  String get frequencyLabel => 'التكرار';

  @override
  String get frequencyHint => 'اختر التكرار';

  @override
  String get prescribingDoctorLabel => 'الدكتور المعالج (اختياري)';

  @override
  String get noneOption => 'لا شيء';

  @override
  String get selectDoctorHint => 'اختر الدكتور';

  @override
  String doctorLoadError(Object error) {
    return 'خطأ في تحميل الأطباء: $error';
  }

  @override
  String get refillReminderLabel => 'تذكير إعادة التعبئة';

  @override
  String get refillReminderOff => 'إيقاف';

  @override
  String refillReminderDaysBefore(int days) {
    return 'قبل $days أيام';
  }

  @override
  String get sideEffectsLabel => 'الآثار الجانبية المعروفة';

  @override
  String get addSideEffectHint => 'أضف أثر جانبي (مثال: النعاس)';

  @override
  String get notesHint => 'أضف ملاحظات...';

  @override
  String get addMedicineButton => 'إضافة الدواء';

  @override
  String get updateMedicineButton => 'تحديث الدواء';

  @override
  String get addMedicineImageTitle => 'إضافة صورة الدواء';

  @override
  String get chooseImageSource => 'اختر مصدر الصورة';

  @override
  String captureFailed(Object error) {
    return 'فشل التقاط الصورة: $error';
  }

  @override
  String pickFailed(Object error) {
    return 'فشل اختيار الصورة: $error';
  }

  @override
  String extractedText(String text) {
    return 'تم استخراج: $text';
  }

  @override
  String get extractFailed => 'تعذر استخراج النص. يرجى إدخال التفاصيل يدوياً.';

  @override
  String get extractionError => 'فشل استخراج النص. يرجى الإدخال يدوياً.';

  @override
  String medicineAutoName(String form, String time) {
    return 'دواء ($form) - $time';
  }

  @override
  String get tabletForm => 'قرص';

  @override
  String get capsuleForm => 'كبسولة';

  @override
  String get liquidForm => 'سائل';

  @override
  String get injectionForm => 'حقنة';

  @override
  String get dailyFrequency => 'يومياً';

  @override
  String get twiceDailyFrequency => 'مرتين يومياً';

  @override
  String get threeTimesDailyFrequency => '3 مرات يومياً';

  @override
  String get weeklyFrequency => 'أسبوعياً';

  @override
  String get asNeededFrequency => 'عند الحاجة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get theme => 'المظهر';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get aiHealthAssistant => 'الم مساعد صحي ذكي';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get analyze => 'تحليل';

  @override
  String get symptoms => 'الأعراض';

  @override
  String get medicines => 'الأدوية';

  @override
  String get addMedicine => 'إضافة دواء';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get aiEnrichmentInProgress => 'الذكاء الاصطناعي يجمع تفاصيل الدواء...';

  @override
  String get aiEnrichmentSuccess =>
      'تم إثراء تفاصيل الدواء بواسطة الذكاء الاصطناعي!';

  @override
  String get commonUsesLabel => 'الاستخدامات الشائعة:';

  @override
  String get mealBreakfast => 'الإفطار';

  @override
  String get mealLunch => 'الغداء';

  @override
  String get mealDinner => 'العشاء';

  @override
  String get mealSnack => 'وجبة خفيفة';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get termsOfServiceTitle => 'شروط الخدمة';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String get aboutSubtitle => 'نسخة التطبيق والمعلومات';

  @override
  String get helpSupportTitle => 'المساعدة والدعم';

  @override
  String get helpSupportSubtitle => 'الأسئلة الشائعة والاتصال';

  @override
  String get testCrashTitle => 'تجربة الانهيار';

  @override
  String get testCrashSubtitle => 'فرض انهيار (للمطورين فقط)';

  @override
  String get manageNotificationsSubtitle => 'إدارة تفضيلات الإشعارات';

  @override
  String get readPrivacyPolicySubtitle => 'قراءة سياسة الخصوصية';

  @override
  String get readTermsSubtitle => 'قراءة شروط الخدمة';

  @override
  String get showFavoritesTooltip => 'عرض المفضلة';

  @override
  String get showAllTooltip => 'عرض الكل';

  @override
  String get noFavoritePharmacies => 'لم يتم العثور على صيدليات مفضلة';

  @override
  String get timezoneUpdatedTitle => 'تم تحديث المنطقة الزمنية';

  @override
  String timezoneUpdatedBody(Object newTimezone) {
    return 'تم تحديث التذكيرات الخاصة بك إلى $newTimezone';
  }

  @override
  String get logInTitle => 'تسجيل الدخول';

  @override
  String get newHere => 'جديد هنا؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get orContinueWith => 'أو تابع مع';

  @override
  String get joinTickdo => 'انضم إلى تيك دوز';

  @override
  String get startManagingHealth => 'ابدأ إدارة رحلتك الصحية اليوم.';

  @override
  String get rememberPassword => 'تذكرت كلمة المرور؟';

  @override
  String get createNewPassword => 'إنشاء كلمة مرور جديدة';

  @override
  String get passwordDifferent =>
      'يجب أن تكون كلمة المرور الجديدة مختلفة عن كلمات المرور المستخدمة سابقاً.';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordRequirements => 'متطلبات كلمة المرور:';

  @override
  String get atLeast8Characters => '8 أحرف على الأقل';

  @override
  String get containsNumber => 'يحتوي على رقم';

  @override
  String get containsSymbol => 'يحتوي على رمز';

  @override
  String get passwordResetSuccess => 'تم إعادة تعيين كلمة المرور بنجاح';

  @override
  String get defineActiveHours => 'حدد ساعات نشاطك';

  @override
  String get wakeWindowReminders =>
      'سيقوم تيك دوس بإرسال التذكيرات فقط خلال نافذة الاستيقاظ الخاصة بك لمزامنة إيقاعك اليومي.';

  @override
  String get wakeUp => 'الاستيقاظ';

  @override
  String get bedtime => 'وقت النوم';

  @override
  String get continueButton => 'متابعة';

  @override
  String get routineSetup => 'إعداد الروتين';

  @override
  String get medicalBackground => 'الخلفية الطبية';

  @override
  String get aiAnalyzeSymptoms =>
      'يساعد هذا الذكاء الاصطناعي لدينا في تحليل أعراضك بدقة أكبر وتقديم رؤى مخصصة.';

  @override
  String get doYouHaveAllergies => 'هل لديك أي حساسية؟';

  @override
  String get currentTimeDetected => 'الوقت الحالي المكتشف';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get deleteAccountConfirmation =>
      'هل أنت متأكد من أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get feelingUnwell => 'تشعر بتوعك؟';

  @override
  String get logSideEffectButton => 'تسجيل أثر جانبي';

  @override
  String get supplyTracking => 'تتبع المخزون';

  @override
  String get requestRefill => 'طلب إعادة التعبئة';

  @override
  String get remaining => 'المتبقي';

  @override
  String get passwordWeak => 'ضعيف';

  @override
  String get passwordMedium => 'متوسط';

  @override
  String get passwordStrong => 'قوي';

  @override
  String get passwordVeryStrong => 'قوي جداً';

  @override
  String get medicationReminders => 'تذكيرات الأدوية';

  @override
  String get refillAlerts => 'تنبيهات إعادة التعبئة';

  @override
  String get healthAnalysis => 'تحليل الصحة';

  @override
  String get selectTimezone => 'اختر المنطقة الزمنية';

  @override
  String get noKnownAllergies => 'ليس لدي حساسيات معروفة';

  @override
  String get chronicConditions => 'الحالات المزمنة';

  @override
  String get logTaken => 'تسجيل تناول الدواء';

  @override
  String get interactionWarning => 'تحذير التفاعل';

  @override
  String get noInteractionsDetected => 'لم يتم اكتشاف تفاعلات';

  @override
  String get interactionsFound => 'تم العثور على تفاعلات';

  @override
  String get proceedAnyway => 'المتابعة على أي حال';

  @override
  String get thisMedicineInteracts => 'هذا الدواء يتفاعل مع أدويتك الحالية';

  @override
  String get active => 'نشط';

  @override
  String get nextDose => 'الجرعة التالية';

  @override
  String get noUpcomingDose => 'لا توجد جرعة قادمة';

  @override
  String get symptomCheck => 'فحص الأعراض';

  @override
  String get aboutThisDrug => 'حول هذا الدواء';

  @override
  String get readFullMonograph => 'قراءة النشرة الكاملة';

  @override
  String monographTitle(String medicineName) {
    return 'نشرة $medicineName';
  }

  @override
  String get close => 'إغلاق';

  @override
  String get editSchedule => 'تعديل الجدول';

  @override
  String get editMedicine => 'تعديل الدواء';

  @override
  String get shareMedicine => 'مشاركة الدواء';

  @override
  String get iFeelAssistant => 'مساعد أشعر بـ';

  @override
  String get online => 'متصل';

  @override
  String get activeContext => 'السياق النشط';

  @override
  String get noActiveMedications => 'لا توجد أدوية نشطة';

  @override
  String get viewMeds => 'عرض الأدوية';

  @override
  String get iFeelAI => 'ذكاء اصطناعي أشعر بـ';

  @override
  String get describeSymptoms => 'صف أعراضك للتحقق من الآثار الجانبية';

  @override
  String get logSymptom => 'تسجيل \"دوار\"';

  @override
  String get reportSideEffect => 'الإبلاغ عن أثر جانبي';

  @override
  String get callDoctor => 'اتصل بالطبيب';

  @override
  String get patient => 'المريض';

  @override
  String get heartRate => 'معدل ضربات القلب';

  @override
  String get voiceReminder => 'تذكير صوتي';

  @override
  String get recordNudge => 'تسجيل تذكير';

  @override
  String get viewFullList => 'عرض القائمة الكاملة';

  @override
  String get noRemindersToday => 'لا توجد تذكيرات مجدولة لليوم';

  @override
  String get overdue => 'متأخر';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get pillList => 'قائمة الأدوية';

  @override
  String get refills => 'إعادة التعبئة';

  @override
  String barcodeScanned(String code) {
    return 'تم مسح الباركود: $code';
  }

  @override
  String get noBarcodeFound => 'لم يتم العثور على باركود في الصورة';

  @override
  String get scanBarcode => 'مسح الباركود';

  @override
  String get selectUnit => 'اختر الوحدة';

  @override
  String get schedule => 'الجدول';

  @override
  String get notifyLowStock => 'إشعار عند انخفاض المخزون';

  @override
  String get translating => 'جاري الترجمة...';

  @override
  String get scanLabel => 'مسح الملصق';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get upload => 'رفع';

  @override
  String get interactionCheckActive => 'فحص التفاعل نشط';

  @override
  String get interactions => 'التفاعلات';

  @override
  String get monograph => 'دليل الدواء';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get drops => 'قطرات';

  @override
  String get loadingMedicines => 'جاري تحميل الأدوية...';

  @override
  String get apiKeyNotConfigured => 'مفتاح API غير مُكوّن';

  @override
  String get loadingSchedule => 'جاري تحميل الجدول...';

  @override
  String get more => 'المزيد';

  @override
  String get reminderSchedule => 'جدول التذكيرات';

  @override
  String get inactive => 'غير نشط';

  @override
  String get yourPrivacyMatters => 'خصوصيتك مهمة';

  @override
  String get privacyPolicyIntro =>
      'في تيك دوس، نحن ملتزمون بحماية معلوماتك الشخصية وحقك في الخصوصية.';

  @override
  String get whatDataWeCollect => '1. البيانات التي نجمعها';

  @override
  String get whatDataWeCollectContent =>
      'نجمع المعلومات التي تقدمها لنا مباشرة، بما في ذلك:\n\n• الأدوية: الأسماء والجرعات والجداول التي تضيفها.\n• التذكيرات: الأوقات والتكرارات لإشعاراتك.\n• الموقع: يُستخدم فقط عند الوصول إلى ميزة البحث عن الصيدلية.\n• الملف الصحي: الحالات والحساسيات وبيانات الصحة الأخرى التي تختار حفظها.\n• بيانات الاستخدام: تحليلات مجهولة المصدر لمساعدتنا على تحسين التطبيق.';

  @override
  String get howWeUseYourData => '2. كيفية استخدام بياناتك';

  @override
  String get howWeUseYourDataContent =>
      'نستخدم المعلومات التي نجمعها من أجل:\n\n• إرسال تذكيرات وإشعارات الأدوية في الوقت المناسب.\n• تتبع التزامك بالأدوية وتقديم إحصائيات.\n• تحسين ميزات التطبيق وتجربة المستخدم.\n• تحليل أنماط الاستخدام لإصلاح الأخطاء وتحسين الأداء.\n• الامتثال للالتزامات القانونية.';

  @override
  String get dataStorageSecurity => '3. تخزين البيانات والأمان';

  @override
  String get dataStorageSecurityContent =>
      '• جميع بياناتك الشخصية مخزنة بأمان في Google Firebase.\n• البيانات مشفرة أثناء النقل باستخدام HTTPS.\n• ننفذ إجراءات أمنية قوية لحماية معلوماتك.\n• نقوم بعمل نسخ احتياطية منتظمة لمنع فقدان البيانات.\n• نحن ملتزمون بالامتثال لـ GDPR ومعايير حماية البيانات.';

  @override
  String get yourRights => '4. حقوقك';

  @override
  String get yourRightsContent =>
      'لديك الحقوق التالية فيما يتعلق ببياناتك:\n\n• الوصول: يمكنك عرض بياناتك داخل التطبيق في أي وقت.\n• التصدير: يمكنك طلب نسخة من بياناتك.\n• الحذف: يمكنك حذف حسابك وجميع البيانات المرتبطة عبر قائمة الإعدادات.\n• إلغاء الاشتراك: يمكنك إلغاء الاشتراك في تتبع التحليلات المجهولة.';

  @override
  String get thirdPartyServices => '5. خدمات الطرف الثالث';

  @override
  String get thirdPartyServicesContent =>
      'نستخدم خدمات طرف ثالث موثوقة لتشغيل التطبيق:\n\n• Google و Apple: للمصادقة الآمنة.\n• Firebase: لقاعدة البيانات السحابية الآمنة والتخزين.\n• Google Maps / OpenStreetMap: لميزة البحث عن الصيدلية.\n• Google Generative AI: لفحص الأعراض \"أشعر بـ\" (إذا تم تفعيله).';

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
  String get contactUsPrivacy => '6. اتصل بنا';

  @override
  String get contactUsPrivacyContent =>
      'إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه، يرجى الاتصال بنا على:\n\nالبريد الإلكتروني: privacy@tickdose.app\n\nنحن نأخذ خصوصيتك على محمل الجد وسنرد على جميع الاستفسارات على الفور.';

  @override
  String get policyChanges => '7. تغييرات السياسة';

  @override
  String get policyChangesContent =>
      'قد نحدث سياسة الخصوصية هذه من وقت لآخر. سنخطرك بأي تغييرات عن طريق نشر سياسة الخصوصية الجديدة على هذه الصفحة وتحديث تاريخ \"آخر تحديث\".';

  @override
  String get lastUpdated => 'آخر تحديث: 24 نوفمبر 2024';

  @override
  String get sharePrivacyPolicyText =>
      'تحقق من سياسة خصوصية تيك دوس: https://tickdosedemo.web.app/privacy-policy';

  @override
  String get sharePrivacyPolicySubject => 'سياسة خصوصية تيك دوس';

  @override
  String get couldNotOpenPrivacyPolicy => 'تعذر فتح سياسة الخصوصية';

  @override
  String get termsOfServiceIntro =>
      'يرجى قراءة هذه الشروط بعناية قبل استخدام تطبيق تيك دوس.';

  @override
  String get licenseToUse => '1. ترخيص الاستخدام';

  @override
  String get licenseToUseContent =>
      'يمنحك تيك دوس ترخيصاً شخصياً وغير قابل للتحويل وغير حصري وقابل للإلغاء لاستخدام البرنامج لاستخدامك الشخصي وغير التجاري وفقاً لهذه الشروط. أنت تملك بياناتك الشخصية، لكننا نحتفظ بجميع الحقوق في كود التطبيق والتصميم والملكية الفكرية.';

  @override
  String get restrictions => '2. القيود';

  @override
  String get restrictionsContent =>
      'أنت توافق على عدم:\n\n• استخدام التطبيق لأي غرض غير قانوني.\n• محاولة عكس هندسة التطبيق أو فك تشفيره.\n• مشاركة بيانات اعتماد حسابك مع الآخرين.\n• استخدام التطبيق لإرسال رسائل غير مرغوب فيها أو مضايقة الآخرين.\n• محاولة اختراق إجراءات أمان التطبيق.';

  @override
  String get medicalDisclaimer => '3. إخلاء المسؤولية الطبية';

  @override
  String get medicalDisclaimerContent =>
      '⚠️ تيك دوس ليس طبيباً.\n\n• هذا التطبيق ليس بديلاً عن المشورة الطبية المهنية أو التشخيص أو العلاج.\n• لا تتجاهل أبداً المشورة الطبية المهنية أو تتأخر في طلبها بسبب شيء قرأته في هذا التطبيق.\n• البيانات المقدمة هي لأغراض إعلامية فقط.\n• في حالة الطوارئ الطبية، اتصل بطبيبك أو خدمات الطوارئ على الفور.\n• لا يمكننا تشخيص أو علاج أو شفاء أي حالة.';

  @override
  String get userResponsibilities => '4. مسؤوليات المستخدم';

  @override
  String get userResponsibilitiesContent =>
      '• أنت مسؤول عن دقة بيانات الصحة التي تدخلها.\n• أنت مسؤول عن الحفاظ على سرية حسابك.\n• أنت توافق على الامتثال لجميع القوانين واللوائح المعمول بها.\n• أنت المسؤول الوحيد عن استخدامك للتطبيق.';

  @override
  String get limitationOfLiability => '5. تحديد المسؤولية';

  @override
  String get limitationOfLiabilityContent =>
      'إلى أقصى حد يسمح به القانون، لن يكون تيك دوس مسؤولاً عن:\n\n• أي أضرار غير مباشرة أو عرضية أو خاصة أو تبعية أو عقابية.\n• أي فقدان للبيانات أو الاستخدام أو السمعة أو الخسائر غير الملموسة الأخرى.\n• أي جرعات فائتة أو تذكيرات بسبب الأعطال التقنية.\n• أي نتائج صحية سلبية ناتجة عن الاعتماد على التطبيق.\n\nمسؤوليتنا القصوى محدودة بمبلغ الذي دفعته للتطبيق، إن وجد.';

  @override
  String get termination => '6. الإنهاء';

  @override
  String get terminationContent =>
      'نحتفظ بالحق في إنهاء أو تعليق حسابك فوراً، دون إشعار مسبق أو مسؤولية، لأي سبب كان، بما في ذلك على سبيل المثال لا الحصر إذا انتهكت الشروط. عند الإنهاء، سيتوقف حقك في استخدام الخدمة فوراً.';

  @override
  String get changesToTerms => '7. تغييرات الشروط';

  @override
  String get changesToTermsContent =>
      'نحتفظ بالحق في تعديل أو استبدال هذه الشروط في أي وقت. من خلال الاستمرار في الوصول إلى خدمتنا أو استخدامها بعد أن تصبح هذه المراجعات سارية، أنت توافق على الالتزام بالشروط المنقحة.';

  @override
  String get contactUsTerms => '8. اتصل بنا';

  @override
  String get contactUsTermsContent =>
      'إذا كان لديك أي أسئلة حول هذه الشروط، يرجى الاتصال بنا على:\n\nالبريد الإلكتروني: support@tickdose.app';

  @override
  String get couldNotOpenTerms => 'تعذر فتح شروط الخدمة';

  @override
  String get deleteAccountQuestion => 'حذف الحساب؟';

  @override
  String get deleteAccountWarning =>
      'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع أدويتك وتذكيراتك وبيانات التتبع ومعلومات الحساب بشكل دائم.';

  @override
  String get deleteAccountPermanently => 'حذف حسابك وجميع البيانات بشكل دائم';

  @override
  String get accountDeletedSuccess => 'تم حذف الحساب بنجاح';

  @override
  String errorDeletingAccount(Object error) {
    return 'خطأ في حذف الحساب: $error';
  }

  @override
  String get errorGeneric => 'حدث خطأ';

  @override
  String get delete => 'حذف';

  @override
  String get yourPersonalMedicationReminder => 'تذكيرك الشخصي للأدوية';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get howToAddMedicine => 'كيف أضيف دواء؟';

  @override
  String get howToAddMedicineAnswer =>
      'اضغط على زر + في الشاشة الرئيسية لإضافة دواء جديد.';

  @override
  String get howToSetReminders => 'كيف أضبط التذكيرات؟';

  @override
  String get howToSetRemindersAnswer =>
      'انتقل إلى تبويب التذكيرات واضغط + لإنشاء تذكير جديد.';

  @override
  String get canIEditMedicines => 'هل يمكنني تعديل أدويتي؟';

  @override
  String get canIEditMedicinesAnswer =>
      'نعم، اضغط على أي دواء لعرض التفاصيل واضغط تعديل.';

  @override
  String get contactSupport => 'اتصل بالدعم';

  @override
  String get version => 'الإصدار 1.0.0';

  @override
  String get text => 'نص';

  @override
  String get voice => 'صوت';

  @override
  String get history => 'السجل';

  @override
  String get emergency => 'طوارئ';

  @override
  String get createInvitation => 'إنشاء دعوة';

  @override
  String get selectAtLeastOnePermission => 'يرجى اختيار إذن واحد على الأقل';

  @override
  String get relationship => 'العلاقة';

  @override
  String get permissions => 'الأذونات';

  @override
  String get permissionsUpdated => 'تم تحديث الأذونات';

  @override
  String get family => 'عائلة';

  @override
  String get friend => 'صديق';

  @override
  String get nurse => 'ممرض';

  @override
  String get other => 'آخر';

  @override
  String get addTime => 'إضافة وقت';

  @override
  String errorOccurred(Object error) {
    return 'خطأ: $error';
  }

  @override
  String barcodeLabel(String code) {
    return 'الرمز الشريطي: $code';
  }

  @override
  String get timesLabel => 'الأوقات';

  @override
  String doctorDisplayFormat(String name, String specialization) {
    return 'د. $name ($specialization)';
  }

  @override
  String get dosageHintExample => '10';

  @override
  String get unitMg => 'ملغ';

  @override
  String get unitG => 'جم';

  @override
  String get unitMl => 'مل';

  @override
  String get unitUnits => 'وحدات';

  @override
  String get unitTablets => 'أقراص';

  @override
  String get unitCapsules => 'كبسولات';

  @override
  String get noKnownConflicts => 'لا توجد تعارضات معروفة مع قائمتك الحالية.';

  @override
  String get addMedicineTitle => 'إضافة دواء';

  @override
  String failedToUploadImage(Object error) {
    return 'فشل رفع الصورة: $error';
  }

  @override
  String errorFailedToShare(Object error) {
    return 'خطأ: فشل المشاركة: $error';
  }

  @override
  String failedToDelete(Object error) {
    return 'فشل الحذف: $error';
  }

  @override
  String get pleaseLogInToViewSideEffects =>
      'يرجى تسجيل الدخول لعرض الآثار الجانبية';

  @override
  String errorLoadingSideEffects(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get deleteSideEffectQuestion => 'حذف الأثر الجانبي؟';

  @override
  String get deleteSideEffectWarning => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get sideEffectDeleted => 'تم حذف الأثر الجانبي';

  @override
  String get logSideEffectTitle => 'تسجيل أثر جانبي';

  @override
  String get sideEffectLoggedSuccess => 'تم تسجيل الأثر الجانبي بنجاح';

  @override
  String get effectNameLabel => 'اسم الأثر';

  @override
  String get effectNameHint => 'مثال: غثيان، صداع';

  @override
  String get whenDidThisOccur => 'متى حدث هذا؟';

  @override
  String get notesOptionalLabel => 'ملاحظات (اختياري)';

  @override
  String get notesOptionalHint => 'تفاصيل إضافية حول الأثر الجانبي';

  @override
  String get iUnderstandTheRisks => 'أفهم المخاطر';

  @override
  String get searchMedicinesHint => 'البحث عن الأدوية...';

  @override
  String get medsLabel => 'الأدوية';

  @override
  String get plusOneToday => '+1 اليوم';

  @override
  String adherencePercentage(String percentage) {
    return '$percentage% الالتزام';
  }

  @override
  String xpToNextLevel(String xp, String level) {
    return '$xp نقطة إلى المستوى $level';
  }
}
