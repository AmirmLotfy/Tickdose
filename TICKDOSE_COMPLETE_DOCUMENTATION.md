# TICKDOSE - Complete Application Documentation

> **Version**: 1.0.0+1  
> **Last Updated**: 2024  
> **Platforms**: Android, iOS, Web (Limited)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture Overview](#architecture-overview)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Core Features](#core-features)
6. [Services & Components](#services--components)
7. [Data Models](#data-models)
8. [State Management](#state-management)
9. [Firebase Integration](#firebase-integration)
10. [AI & Voice Features](#ai--voice-features)
11. [Localization & Internationalization](#localization--internationalization)
12. [Theming & UI](#theming--ui)
13. [Security & Permissions](#security--permissions)
14. [Setup & Installation](#setup--installation)
15. [Configuration](#configuration)
16. [Build & Deployment](#build--deployment)
17. [Testing](#testing)
18. [Troubleshooting](#troubleshooting)
19. [API References](#api-references)
20. [Contributing](#contributing)

---

## Executive Summary

**TICKDOSE** is a comprehensive, production-ready medication reminder and health tracking application built with Flutter. It helps users manage medications, track adherence, receive intelligent reminders, and interact with AI-powered health assistance.

### Key Highlights

- **Multi-Platform**: Android, iOS, and Web support
- **AI-Powered**: Google Gemini for symptom analysis and health insights
- **Voice-First**: ElevenLabs integration for personalized voice reminders
- **Offline-First**: Full offline support with Firestore persistence
- **Accessible**: Biometric authentication, voice commands, and dark mode
- **Global**: Multi-language support (English, Arabic) with RTL layout support
- **Caregiver Support**: Family members can monitor and assist with medication management

### App Statistics

- **Package Name**: `com.tickdose.app`
- **Firebase Project**: `tickdoseapp`
- **Default Timezone**: Device timezone (Africa/Cairo as fallback)
- **Supported Languages**: English (en), Arabic (ar)
- **Minimum SDK**: Android 21 (Lollipop 5.0), iOS 13.0

---

## Architecture Overview

### Architecture Pattern

**Feature-Based Modular Architecture** with clean separation of concerns:

```
┌─────────────────────────────────────┐
│         UI Layer (Screens)          │
│  (Flutter Widgets & Stateful)       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      State Management (Riverpod)     │
│    (Providers, Notifiers, Watchers)  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│       Services Layer                 │
│  (Business Logic & API Calls)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Data Layer                      │
│  (Firestore, Storage, Local DB)      │
└──────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns**: UI, business logic, and data layers are strictly separated
2. **Dependency Injection**: Riverpod provides dependency injection throughout the app
3. **Reactive Programming**: Stream-based data flow for real-time updates
4. **Offline-First**: All data operations work offline with sync when online
5. **Error Handling**: Comprehensive error handling with user-friendly messages
6. **Type Safety**: Strong typing with Dart's type system

### Design Patterns Used

- **Provider Pattern**: For dependency injection and state management
- **Repository Pattern**: Service layer abstracts data sources
- **Singleton Pattern**: Services like `GeminiService`, `ElevenLabsService`
- **Factory Pattern**: Error creation (`ApiError.fromException`)
- **Observer Pattern**: Stream-based reactive programming

---

## Technology Stack

### Frontend Framework

- **Flutter**: 3.0+ (Latest stable)
- **Dart**: 3.0.0+
- **Material Design**: Primary UI framework
- **Cupertino**: iOS-specific widgets where needed

### Backend Services

#### Firebase Suite
- **Firebase Authentication**: Email/password, Google, Apple Sign-In
- **Cloud Firestore**: NoSQL database with real-time sync
- **Firebase Storage**: Image and file storage
- **Cloud Functions**: Serverless backend functions (Node.js 20+)
- **Firebase Cloud Messaging (FCM)**: Push notifications
- **Firebase Remote Config**: Feature flags and API key management
- **Firebase Crashlytics**: Crash reporting and analytics
- **Firebase Analytics**: User behavior tracking
- **Firebase Performance Monitoring**: App performance metrics

### State Management

- **Riverpod**: Primary state management (v3.0.3)
- **Provider**: Legacy support where needed (v6.1.1)
- **flutter_riverpod**: Flutter integration for Riverpod

### Local Storage

- **Hive**: Fast, lightweight NoSQL database
- **SharedPreferences**: Key-value storage for app settings
- **flutter_secure_storage**: Encrypted storage for sensitive data
- **SQLite (sqflite)**: Structured data storage (legacy)

### AI & ML Services

- **Google Gemini AI**: Symptom analysis, medication information, health insights
- **Google ML Kit**:
  - Text Recognition (OCR)
  - Barcode Scanning
  - Translation

### Voice Services

- **ElevenLabs**: Text-to-speech synthesis for voice reminders
- **speech_to_text**: Speech recognition for voice input
- **flutter_tts**: Local text-to-speech (fallback)
- **just_audio**: Audio playback
- **record**: Audio recording

### UI & UX Libraries

- **cached_network_image**: Image caching and loading
- **shimmer**: Loading placeholders
- **smooth_page_indicator**: Page indicators
- **flutter_svg**: SVG rendering
- **table_calendar**: Calendar widget
- **fl_chart**: Charts and graphs
- **flutter_map**: Map rendering
- **google_fonts**: Custom fonts
- **flutter_markdown**: Markdown rendering

### Utilities

- **intl**: Internationalization and date formatting
- **url_launcher**: Deep linking and external URLs
- **geolocator**: Location services
- **permission_handler**: Runtime permissions
- **timezone**: Timezone handling
- **uuid**: Unique ID generation
- **workmanager**: Background tasks
- **flutter_local_notifications**: Local notifications
- **path_provider**: File system paths
- **image_picker**: Camera and gallery access

### Development Tools

- **build_runner**: Code generation
- **flutter_lints**: Linting rules
- **flutter_test**: Unit and widget testing

---

## Project Structure

```
Tickdo/
├── android/                    # Android platform files
│   ├── app/
│   │   ├── build.gradle.kts   # App build configuration
│   │   ├── google-services.json
│   │   └── src/
│   └── gradle/
├── ios/                        # iOS platform files
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── GoogleService-Info.plist
│   └── Runner.xcodeproj/
├── lib/                        # Main application code
│   ├── core/                   # Shared/core functionality
│   │   ├── constants/         # App constants
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   └── dimens.dart
│   │   ├── icons/             # Custom icons
│   │   │   └── app_icons.dart
│   │   ├── models/            # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── medicine_model.dart
│   │   │   ├── reminder_model.dart
│   │   │   ├── medicine_log_model.dart
│   │   │   ├── side_effect_log_model.dart
│   │   │   ├── caregiver_model.dart
│   │   │   ├── pharmacy_model.dart
│   │   │   ├── voice_model.dart
│   │   │   ├── i_feel_models.dart
│   │   │   └── gamification_models.dart
│   │   ├── providers/         # Global providers
│   │   │   └── voice_settings_provider.dart
│   │   ├── services/          # Core services
│   │   │   ├── firebase_auth_service.dart
│   │   │   ├── firestore_service.dart
│   │   │   ├── firebase_messaging_service.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── gemini_service.dart
│   │   │   ├── elevenlabs_service.dart
│   │   │   ├── medicine_service.dart
│   │   │   ├── reminder_service.dart
│   │   │   ├── tracking_service.dart
│   │   │   ├── caregiver_service.dart
│   │   │   ├── pharmacy_service.dart
│   │   │   ├── location_service.dart
│   │   │   ├── speech_service.dart
│   │   │   ├── audio_service.dart
│   │   │   ├── biometric_auth_service.dart
│   │   │   ├── remote_config_service.dart
│   │   │   ├── api_rate_limiter.dart
│   │   │   ├── api_error.dart
│   │   │   └── ... (40+ services)
│   │   ├── theme/             # App theming
│   │   │   ├── app_theme.dart
│   │   │   └── text_styles.dart
│   │   ├── utils/             # Utility functions
│   │   │   ├── logger.dart
│   │   │   ├── date_time_utils.dart
│   │   │   ├── validators.dart
│   │   │   ├── auth_error_messages.dart
│   │   │   └── ...
│   │   └── widgets/           # Reusable widgets
│   │       ├── standard_error_widget.dart
│   │       ├── permission_dialog.dart
│   │       └── ...
│   ├── features/              # Feature modules
│   │   ├── auth/             # Authentication
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   ├── forgot_password_screen.dart
│   │   │   │   └── email_verification_screen.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── widgets/
│   │   ├── home/             # Home screen
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── today_screen.dart
│   │   │   ├── providers/
│   │   │   └── widgets/
│   │   ├── medicines/        # Medicine management
│   │   │   ├── screens/
│   │   │   │   ├── medicines_list_screen.dart
│   │   │   │   ├── add_medicine_screen.dart
│   │   │   │   ├── edit_medicine_screen.dart
│   │   │   │   ├── medicine_detail_screen.dart
│   │   │   │   └── log_side_effect_screen.dart
│   │   │   ├── providers/
│   │   │   ├── services/
│   │   │   │   ├── medicine_service.dart
│   │   │   │   ├── side_effect_service.dart
│   │   │   │   ├── barcode_service.dart
│   │   │   │   └── medicine_camera_service.dart
│   │   │   └── widgets/
│   │   ├── reminders/        # Reminder management
│   │   │   ├── screens/
│   │   │   │   ├── reminders_screen.dart
│   │   │   │   ├── add_reminder_screen.dart
│   │   │   │   └── edit_reminder_screen.dart
│   │   │   ├── providers/
│   │   │   ├── services/
│   │   │   └── widgets/
│   │   ├── tracking/         # Medication tracking
│   │   │   ├── screens/
│   │   │   │   └── tracking_screen.dart
│   │   │   ├── providers/
│   │   │   ├── services/
│   │   │   │   ├── tracking_service.dart
│   │   │   │   └── pdf_service.dart
│   │   │   └── widgets/
│   │   ├── i_feel/          # AI symptom checker
│   │   │   ├── screens/
│   │   │   │   ├── i_feel_screen.dart
│   │   │   │   ├── i_feel_chat_screen.dart
│   │   │   │   ├── i_feel_voice_screen.dart
│   │   │   │   └── chat_history_screen.dart
│   │   │   └── widgets/
│   │   ├── profile/         # User profile
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── edit_profile_screen.dart
│   │   │   │   ├── health_info_screen.dart
│   │   │   │   ├── change_password_screen.dart
│   │   │   │   ├── delete_account_screen.dart
│   │   │   │   └── caregiver_management_screen.dart
│   │   │   ├── providers/
│   │   │   └── widgets/
│   │   ├── caregiver/       # Caregiver features
│   │   │   ├── screens/
│   │   │   │   ├── caregiver_dashboard_screen.dart
│   │   │   │   ├── caregiver_invitation_screen.dart
│   │   │   │   └── invitation_qr_screen.dart
│   │   │   └── widgets/
│   │   ├── pharmacy/        # Pharmacy finder
│   │   │   ├── screens/
│   │   │   │   └── pharmacy_finder_screen.dart
│   │   │   ├── providers/
│   │   │   ├── services/
│   │   │   └── widgets/
│   │   ├── doctors/         # Doctor management
│   │   │   ├── screens/
│   │   │   │   ├── doctors_list_screen.dart
│   │   │   │   └── add_doctor_screen.dart
│   │   │   ├── providers/
│   │   │   └── models/
│   │   ├── settings/        # App settings
│   │   │   ├── screens/
│   │   │   │   ├── settings_screen.dart
│   │   │   │   ├── notification_settings_screen.dart
│   │   │   │   ├── voice_settings_screen.dart
│   │   │   │   ├── privacy_settings_screen.dart
│   │   │   │   └── ...
│   │   │   └── widgets/
│   │   ├── onboarding/      # Onboarding flow
│   │   │   ├── screens/
│   │   │   │   ├── onboarding_screen.dart
│   │   │   │   ├── health_profile_screen.dart
│   │   │   │   ├── routine_setup_screen.dart
│   │   │   │   └── timezone_screen.dart
│   │   │   └── widgets/
│   │   ├── navigation/      # Navigation
│   │   │   ├── routes/
│   │   │   │   ├── app_router.dart
│   │   │   │   └── route_names.dart
│   │   │   └── widgets/
│   │   │       └── bottom_nav_bar.dart
│   │   ├── provider/        # Provider dashboard
│   │   │   └── screens/
│   │   │       └── provider_dashboard_screen.dart
│   │   └── splash/          # Splash screen
│   │       └── screens/
│   │           └── splash_screen.dart
│   ├── l10n/                # Localization
│   │   ├── app_en.arb       # English strings
│   │   ├── app_ar.arb       # Arabic strings
│   │   └── generated/       # Generated localization files
│   ├── generated/           # Generated code
│   ├── firebase_options.dart # Firebase configuration
│   └── main.dart            # App entry point
├── functions/                # Cloud Functions
│   ├── index.js
│   └── package.json
├── assets/                   # Static assets
│   ├── images/
│   ├── icons/
│   └── sounds/
├── firebase.json             # Firebase configuration
├── firestore.rules           # Firestore security rules
├── firestore.indexes.json    # Firestore indexes
├── storage.rules             # Storage security rules
├── pubspec.yaml              # Flutter dependencies
├── l10n.yaml                 # Localization configuration
└── README.md                 # Quick start guide
```

---

## Core Features

### 1. Authentication & User Management

#### Authentication Methods
- **Email/Password**: Traditional email-based authentication
- **Google Sign-In**: One-click Google authentication
- **Apple Sign-In**: iOS native authentication (iOS 13+)
- **Biometric Authentication**: Fingerprint/Face ID with secure credential storage
- **Passwordless Login**: Email-based magic link authentication

#### User Profile Features
- Edit personal information (name, email, phone)
- Health profile management (age, gender, weight, height, conditions, allergies)
- Profile photo upload and management
- Change password with secure validation
- Account deletion with data cleanup
- Email verification workflow

#### Security Features
- Secure credential storage using `flutter_secure_storage`
- Biometric authentication integration
- Password strength validation
- Session management
- Automatic logout on security events

### 2. Medicine Management

#### Adding Medicines
- **Manual Entry**: Full form-based medicine entry
- **Camera OCR**: Text recognition from medicine labels using Google ML Kit
- **Barcode Scanning**: Scan medicine barcodes for quick lookup
- **Image Capture**: Take photos of medicine packaging
- **Medicine Database Integration**: AI-powered medicine information enrichment

#### Medicine Information
- Medicine name (brand and generic)
- Dosage strength and form (tablet, capsule, liquid, etc.)
- Manufacturer information
- Expiry date tracking with visual indicators
- Batch number and prescription details
- Dosage instructions
- Custom notes and translation
- Side effects information
- Drug interaction warnings

#### Medicine Operations
- View medicine list with search and filtering
- Edit medicine details
- Delete medicines (with confirmation)
- Expiry tracking with refill reminders
- Supply tracking and low stock alerts
- Medicine images and photo management

### 3. Reminder System

#### Reminder Types
- **Once Daily**: Single reminder per day
- **Twice Daily**: Morning and evening
- **Three Times Daily**: Morning, afternoon, evening
- **Four Times Daily**: Multiple times throughout the day
- **Every 8 Hours**: Interval-based reminders
- **Every 12 Hours**: Twice-daily interval reminders
- **Meal-Based**: Breakfast, lunch, dinner, bedtime reminders
- **Custom Schedule**: User-defined times and frequencies
- **Day-of-Week Selection**: Specific days for reminders

#### Reminder Features
- Multiple reminder times per medicine
- Flexible timing with offset windows
- Quiet hours configuration (default: 10 PM - 8 AM)
- Timezone-aware reminders
- Voice reminders using ElevenLabs
- Custom notification sounds
- Reminder enable/disable toggle
- Edit and delete reminders

#### Notification Types
- **Local Notifications**: Scheduled device notifications
- **Firebase Cloud Messaging**: Push notifications
- **Actionable Notifications**: Quick actions (Taken, Skipped, Snooze)
- **Urgent Reminders**: High-priority alerts for critical medicines

### 4. Medication Tracking

#### Logging Features
- **Taken**: Mark medicine as taken with timestamp
- **Skipped**: Record intentional skipping
- **Missed**: Track missed doses
- **Manual Time Entry**: Adjust timestamps if needed
- **Bulk Logging**: Log multiple medicines at once

#### Tracking Views
- **Calendar View**: Monthly calendar with medication logs
- **Daily View**: Detailed daily medication timeline
- **List View**: Chronological list of all logs
- **History View**: Filterable historical records

#### Analytics & Statistics
- Adherence rate calculation (percentage of doses taken)
- Daily/weekly/monthly statistics
- Visual charts and graphs (fl_chart)
- Trend analysis over time
- Export to PDF functionality

### 5. Side Effects Logging

#### Features
- Log side effects associated with medicines
- Severity rating (Mild, Moderate, Severe)
- Date and time tracking
- Notes and description
- Visual timeline of side effects
- Filter by medicine or severity
- Export functionality

### 6. AI-Powered "I Feel" Feature

#### Symptom Analysis
- **Text Chat**: Conversational AI for symptom checking
- **Voice Input**: Speak symptoms using speech-to-text
- **Voice Output**: AI responses via ElevenLabs TTS
- **Chat History**: Persistent conversation history
- **Context Awareness**: AI considers current medications

#### AI Capabilities
- Symptom analysis and possible causes
- Urgency level assessment (Low, Medium, High, Emergency)
- Recommendations and next steps
- Doctor visit suggestions
- Medication interaction warnings
- Multi-turn conversations with context

#### Voice Features
- Real-time speech recognition
- Voice message playback
- Custom voice selection (ElevenLabs)
- Multi-language voice support
- Emotional tone in voice responses

### 7. Caregiver Support System

#### Caregiver Features
- **Invitation System**: QR code or token-based invitations
- **Permission Levels**: View-only or full access
- **Patient Dashboard**: View patient's medications and adherence
- **Real-time Notifications**: Alerts for missed doses
- **Medication Overview**: Summary of patient's medication schedule
- **Voice Messages**: Send voice messages to patients

#### Caregiver Management
- Add/remove caregivers
- Manage caregiver permissions
- View caregiver list
- Revoke access
- Activity logs

### 8. Pharmacy Finder

#### Features
- **Location-Based Search**: Find nearby pharmacies using GPS
- **Map View**: Interactive map with pharmacy markers
- **List View**: Sortable list of pharmacies
- **Distance Calculation**: Show distance from current location
- **Opening Hours**: Display pharmacy hours (24/7 indicator)
- **Directions**: Open in Maps app for navigation
- **Offline Support**: Cached pharmacy data

#### Location Services
- Current location detection
- Permission handling
- Location-based reminders
- Travel mode support

### 9. Doctor Management

#### Features
- Add doctor information
- Store contact details
- Specialization tracking
- Search and filter doctors
- Quick call/email actions

### 10. Settings & Preferences

#### Notification Settings
- Enable/disable notifications
- Notification sound selection
- Quiet hours configuration
- Notification categories (reminders, adherence, side effects)
- Push notification preferences

#### Voice Settings
- Voice selection (ElevenLabs voices)
- Voice speed/pitch adjustment
- Voice personality settings
- Personal voice recording
- Test voice playback

#### Privacy Settings
- Data sharing preferences
- Biometric authentication toggle
- Location permission management
- Analytics opt-out
- Data export/delete options

#### App Settings
- Language selection (English/Arabic)
- Theme selection (Light/Dark/System)
- Timezone settings
- Default reminder preferences
- Export data (PDF, CSV)

### 11. Onboarding Flow

#### Steps
1. **Welcome Screen**: App introduction
2. **Health Profile**: Collect user health information
3. **Routine Setup**: Configure daily routine times
4. **Timezone Setup**: Set timezone preferences
5. **Permission Requests**: Camera, microphone, location, notifications

### 12. Gamification (Planned/Partial)

#### Features
- Health quests and challenges
- Adherence streaks
- Achievement badges
- Points and rewards system
- Personalized goals

---

## Services & Components

### Core Services

#### Authentication Services

**FirebaseAuthService**
- Email/password authentication
- Google Sign-In integration
- Apple Sign-In integration
- Password reset and email verification
- Session management

**BiometricAuthService**
- Fingerprint/Face ID authentication
- Secure credential storage
- Biometric availability detection
- Credential management

#### Data Services

**FirestoreService**
- CRUD operations for Firestore collections
- Real-time data streams
- Query building and filtering
- Batch operations
- Transaction support
- Offline persistence handling

**StorageService**
- Firebase Storage integration
- Image upload/download
- File management
- URL generation
- Progress tracking

**FirebaseUserService**
- User profile CRUD
- Health profile management
- Profile photo handling
- Data validation

#### Medicine Services

**MedicineService**
- Medicine CRUD operations
- Medicine search and filtering
- Expiry tracking
- Supply management
- Medicine enrichment (AI-powered)

**SideEffectService**
- Side effect logging
- Side effect retrieval
- Filtering and sorting
- Statistics calculation

**BarcodeService**
- Barcode scanning using ML Kit
- Barcode data parsing
- Medicine lookup integration

**MedicineCameraService**
- Camera integration for medicine photos
- Image capture and processing
- OCR text extraction

#### Reminder Services

**ReminderService**
- Reminder CRUD operations
- Reminder scheduling
- Notification management
- Timezone handling
- Frequency calculations

**NotificationService**
- Local notification scheduling
- Notification display
- Action button handling
- Sound and vibration configuration
- Quiet hours enforcement

**FirebaseMessagingService**
- FCM token management
- Push notification handling
- Background message processing
- Notification channel management

**VoiceReminderService**
- Voice reminder generation
- ElevenLabs integration
- Voice playback scheduling
- Voice confirmation flows

#### AI Services

**GeminiService**
- Symptom analysis API calls
- Medication information enrichment
- Health insights generation
- Rate limiting and error handling
- Conversation history management

**ElevenLabsService**
- Text-to-speech synthesis
- Voice selection and configuration
- Audio file generation and caching
- Streaming audio playback
- Voice settings management

**SpeechService**
- Speech-to-text conversion
- Voice command recognition
- Language detection
- Continuous listening

#### Tracking Services

**TrackingService**
- Medication log creation
- Log retrieval and filtering
- Adherence calculation
- Statistics generation
- Calendar data preparation

**PDFService**
- PDF generation for medication reports
- Export functionality
- Template-based PDFs

#### Caregiver Services

**CaregiverService**
- Caregiver invitation management
- Permission handling
- Patient access management
- Relationship tracking

**CaregiverNotificationService**
- Missed medication alerts
- Adherence summaries
- Urgent health concern notifications

**CaregiverSharingService**
- QR code generation for invitations
- Token-based invitations
- Sharing link generation

#### Location Services

**LocationService**
- Current location detection
- Permission handling
- Geocoding and reverse geocoding
- Distance calculations
- Location-based reminders

**PharmacyService**
- Pharmacy search (Google Places API or similar)
- Pharmacy data caching
- Opening hours parsing
- Distance calculations

#### Utility Services

**AudioService**
- Sound effect playback
- Audio session management
- Volume control
- Playback state management

**CacheService**
- Data caching strategies
- Cache invalidation
- Offline data management

**RemoteConfigService**
- Firebase Remote Config integration
- API key management
- Feature flag handling
- Configuration updates

**PermissionService**
- Runtime permission requests
- Permission status checking
- Permission dialog display
- Permission rationale handling

**TimezoneMonitorService**
- Timezone change detection
- Automatic reminder rescheduling
- Background monitoring (WorkManager)

**ApiRateLimiter**
- API call rate limiting
- Quota management
- Rate limit enforcement
- Per-user tracking

**ApiError**
- Standardized error handling
- Error type classification
- Localized error messages
- Error recovery strategies

**PerformanceMonitoringService**
- App performance tracking
- Firebase Performance integration
- Custom traces
- Network monitoring

**CrashRecoveryService**
- Crash detection and recovery
- Data restoration
- Pending operation recovery
- State restoration

**AppUpdateService**
- App version checking
- Update prompts
- In-app update handling

**DeepLinkService**
- Deep link handling
- URL routing
- App link support
- Universal links (iOS)

**WearableService**
- Wearable device integration
- Health data sync
- Step counting
- Heart rate monitoring (if available)

**AccessibilityService**
- Accessibility feature detection
- Screen reader support
- Large text support
- High contrast mode

**TranslationService**
- Text translation (Google ML Kit)
- Multi-language support
- Translation caching

**OCRService (MedicineOCRService)**
- Text recognition from images
- Medicine label parsing
- Structured data extraction

**AnalyticsService**
- Firebase Analytics integration
- Custom event tracking
- User behavior analytics

**ExportService**
- Data export functionality
- Multiple format support (PDF, CSV)
- Email integration

**GamificationService**
- Quest generation
- Achievement tracking
- Points calculation
- Reward management

**ProviderAnalyticsService**
- Caregiver analytics
- Patient adherence reports
- Statistics aggregation

---

## Data Models

### UserModel

```dart
{
  id: String,
  email: String,
  name: String,
  phoneNumber: String?,
  photoUrl: String?,
  createdAt: DateTime,
  updatedAt: DateTime,
  healthProfile: {
    age: int?,
    gender: String?,
    weight: double?,
    height: double?,
    medicalConditions: List<String>,
    allergies: List<String>,
    bloodType: String?,
  },
  preferences: {
    language: String,
    theme: String,
    timezone: String,
    quietHoursStart: String?,
    quietHoursEnd: String?,
  },
  routine: {
    wakeTime: String?,
    breakfastTime: String?,
    lunchTime: String?,
    dinnerTime: String?,
    sleepTime: String?,
  }
}
```

### MedicineModel

```dart
{
  id: String,
  userId: String,
  name: String,
  genericName: String?,
  strength: String?,
  form: String, // tablet, capsule, liquid, etc.
  manufacturer: String?,
  expiryDate: DateTime?,
  batchNumber: String?,
  prescriptionNumber: String?,
  imageUrl: String?,
  notes: String?,
  translation: String?,
  dosage: {
    amount: double,
    unit: String,
    instructions: String?,
  },
  supply: {
    totalQuantity: int,
    currentQuantity: int,
    refillReminderDays: int, // default 7
  },
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### ReminderModel

```dart
{
  id: String,
  userId: String,
  medicineId: String,
  frequency: String, // once_daily, twice_daily, etc.
  times: List<TimeOfDay>,
  daysOfWeek: List<int>?, // 0-6 (Sunday-Saturday)
  mealTime: String?, // breakfast, lunch, dinner, bedtime
  isEnabled: bool,
  voiceEnabled: bool,
  voiceId: String?,
  quietHoursEnabled: bool,
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### MedicineLogModel

```dart
{
  id: String,
  userId: String,
  medicineId: String,
  reminderId: String?,
  status: String, // taken, skipped, missed
  takenAt: DateTime,
  scheduledTime: DateTime?,
  notes: String?,
  createdAt: DateTime,
}
```

### SideEffectLogModel

```dart
{
  id: String,
  userId: String,
  medicineId: String,
  symptom: String,
  severity: String, // mild, moderate, severe
  occurredAt: DateTime,
  notes: String?,
  createdAt: DateTime,
}
```

### CaregiverModel

```dart
{
  id: String,
  userId: String, // Patient's user ID
  caregiverId: String, // Caregiver's user ID
  caregiverEmail: String,
  caregiverName: String,
  permissions: {
    viewMedications: bool,
    viewAdherence: bool,
    viewSideEffects: bool,
    receiveNotifications: bool,
  },
  invitationToken: String,
  status: String, // pending, accepted, revoked
  invitedAt: DateTime,
  acceptedAt: DateTime?,
  createdAt: DateTime,
}
```

### ConversationModel (I Feel)

```dart
{
  id: String,
  userId: String,
  messages: List<{
    id: String,
    text: String,
    sender: String, // user, ai
    timestamp: DateTime,
    medicinesAtTime: List<String>?,
    voiceId: String?,
  }>,
  lastMessageAt: DateTime,
  createdAt: DateTime,
}
```

### PharmacyModel

```dart
{
  id: String,
  name: String,
  address: String,
  phoneNumber: String?,
  latitude: double,
  longitude: double,
  distance: double?, // calculated distance
  openingHours: {
    isOpen24Hours: bool,
    hours: Map<String, String>?, // day -> hours
  },
  rating: double?,
  placeId: String?,
}
```

---

## State Management

### Riverpod Architecture

The app uses **Riverpod 3.0.3** as the primary state management solution.

#### Provider Types

1. **StateProvider**: Simple state management
   ```dart
   final selectedMedicineProvider = StateProvider<MedicineModel?>((ref) => null);
   ```

2. **StateNotifierProvider**: Complex state with business logic
   ```dart
   final medicinesProvider = StateNotifierProvider<MedicinesNotifier, AsyncValue<List<MedicineModel>>>((ref) {
     return MedicinesNotifier(ref.read(medicineServiceProvider));
   });
   ```

3. **StreamProvider**: Real-time data streams
   ```dart
   final medicinesStreamProvider = StreamProvider<List<MedicineModel>>((ref) {
     return ref.read(medicineServiceProvider).getMedicinesStream();
   });
   ```

4. **FutureProvider**: Async data loading
   ```dart
   final userProfileProvider = FutureProvider<UserModel?>((ref) async {
     return await ref.read(firebaseUserServiceProvider).getCurrentUserProfile();
   });
   ```

#### Provider Organization

- **Feature Providers**: Located in `lib/features/{feature}/providers/`
- **Global Providers**: Located in `lib/core/providers/`
- **Service Providers**: Services exposed as providers for dependency injection

#### State Management Best Practices

1. **Immutable State**: All state objects are immutable
2. **AsyncValue**: Use `AsyncValue` for async operations (loading, data, error)
3. **Provider Composition**: Build complex providers from simpler ones
4. **Dependency Injection**: Services injected via providers
5. **Watch vs Read**: Use `watch` for reactive updates, `read` for one-time access

---

## Firebase Integration

### Firebase Services Used

#### Authentication
- **Email/Password**: Traditional authentication
- **Google Sign-In**: OAuth integration
- **Apple Sign-In**: iOS native authentication
- **Custom Tokens**: (If needed for special cases)

#### Cloud Firestore

**Collections Structure:**
```
users/{userId}
  - User profile data
  - Health information
  - Preferences

medicines/{medicineId}
  - Medicine details
  - Linked to userId

reminders/{reminderId}
  - Reminder configuration
  - Linked to userId and medicineId

logs/{logId}
  - Medication logs
  - Linked to userId and medicineId

side_effects/{effectId}
  - Side effect records
  - Linked to userId and medicineId

caregivers/{caregiverId}
  - Caregiver relationships
  - Linked to userId

iFeelConversations/{conversationId}
  - AI chat conversations
  - Linked to userId

pharmacies/{pharmacyId}
  - Cached pharmacy data
  - Public data
```

**Firestore Indexes:**
- `logs`: `takenAt` (ASC) + `status` (ASC)
- `side_effects`: `medicineId` (ASC) + `occurredAt` (DESC)
- `iFeelConversations`: `userId` (ASC) + `lastMessageAt` (DESC)

#### Firebase Storage

**Storage Structure:**
```
users/{userId}/
  profile/photo.jpg
  medicines/{medicineId}/image.jpg
  voices/{voiceId}.mp3
  exports/{exportId}.pdf
```

**Rules:**
- User can only access their own files
- File size limits: 5MB images, 10MB audio
- Content type validation

#### Cloud Functions

**Functions:**
- Notification triggers on missed doses
- Data cleanup on account deletion
- Caregiver notification handlers
- Analytics aggregation

#### Remote Config

**Configuration Parameters:**
- `GEMINI_API_KEY`: Gemini AI API key
- `ELEVENLABS_API_KEY`: ElevenLabs API key
- Feature flags for A/B testing
- App configuration values

#### Cloud Messaging (FCM)

- Push notifications for reminders
- Caregiver alerts
- System notifications
- Background message handling

#### Security Rules

**Firestore Rules:**
- User data isolated by `userId`
- Read/write access restricted to authenticated users
- Caregiver access with permission checks
- Public read for pharmacies collection

**Storage Rules:**
- User-specific path access
- Authentication required
- File size and type validation

---

## AI & Voice Features

### Google Gemini AI Integration

#### Use Cases
1. **Symptom Analysis**: Analyze user-reported symptoms
2. **Medication Information**: Enrich medicine data with side effects, interactions
3. **Health Insights**: Generate personalized health recommendations
4. **Conversational AI**: Multi-turn conversations in "I Feel" chat

#### Implementation

**GeminiService**
- Models: `gemini-3-flash` (default) and `gemini-3-pro` (for complex medical reasoning)
- Features: Search grounding, safety settings, retry logic, response caching, enhanced output cleaning
- System prompts for medical context
- Conversation history management
- Rate limiting (ApiRateLimiter)
- Error handling (ApiError system)

**Features:**
- Context-aware responses (considers user's medications)
- Multi-language support
- Structured JSON responses for medication data
- Safety filters for medical advice

### ElevenLabs Voice Integration

#### Use Cases
1. **Voice Reminders**: Personalized voice notifications
2. **AI Responses**: Voice output for "I Feel" conversations
3. **Voice Confirmations**: Interactive voice confirmations
4. **Personal Voice**: User can record their own voice

#### Implementation

**ElevenLabsService**
- Text-to-speech synthesis
- Voice selection (multiple voices available)
- Audio caching for performance
- Streaming support
- Multi-language voices

**Voice Settings:**
- Stability: Voice consistency (0.0 - 1.0)
- Similarity Boost: Voice accuracy (0.0 - 1.0)
- Style Exaggeration: Emotional intensity (0.0 - 1.0)
- Speaker Boost: Enhanced presence (boolean)

**Models:**
- `Flash`: Fast, efficient (default)
- `Multilingual`: For Arabic and other languages
- `Turbo`: Ultra-fast for real-time

### Speech Recognition

**SpeechService**
- Real-time speech-to-text
- Continuous listening
- Language detection
- Error handling and timeouts

### ML Kit Integration

**Google ML Kit Features:**
- **Text Recognition**: OCR from medicine labels
- **Barcode Scanning**: Medicine barcode scanning
- **Translation**: Text translation (English ↔ Arabic)

---

## Localization & Internationalization

### Supported Languages

- **English (en)**: Primary language
- **Arabic (ar)**: Full RTL support

### Localization Files

- `lib/l10n/app_en.arb`: English strings
- `lib/l10n/app_ar.arb`: Arabic strings
- Generated files in `lib/l10n/generated/`

### Localization System

- **Flutter Intl**: Standard Flutter localization
- **ARB Format**: Application Resource Bundle files
- **Code Generation**: Automatic code generation from ARB files
- **RTL Support**: Full right-to-left layout support for Arabic

### Localized Content

- All UI strings
- Error messages
- Date/time formatting (locale-aware)
- Number formatting
- Validation messages

### Date/Time Localization

- Locale-aware date formatting
- 12/24-hour time format based on locale
- Day/month/year order based on locale
- Relative time strings ("Today", "Yesterday")

---

## Theming & UI

### Theme System

**AppTheme**
- Light theme (default)
- Dark theme
- System theme (follows device setting)

### Color System

**AppColors**
- Theme-aware colors
- Dynamic color switching
- Consistent color palette
- Dark mode optimized colors

**Color Palette:**
- Primary Green: Main brand color
- Primary Blue: Secondary actions
- Error Red: Error states
- Success Green: Success states
- Background colors (light/dark)
- Text colors (primary/secondary/tertiary)
- Card colors
- Shadow colors

### Typography

**AppTextStyles**
- Heading styles (H1, H2, H3)
- Body styles (large, medium, small)
- Caption styles
- Button styles
- Theme-aware font sizes and weights

### Components

**Reusable Widgets:**
- `StandardErrorWidget`: Consistent error display
- `PermissionDialog`: Permission request dialogs
- `GlassmorphicContainer`: Glass morphism effects
- `GradientText`: Text with gradients
- `AnimatedStatRing`: Animated statistics display
- `PulseGlow`: Pulsing glow effects

### UI Patterns

- Material Design 3 principles
- Responsive layouts
- Accessibility support
- Smooth animations
- Loading states (shimmer effects)
- Empty states
- Error states

---

## Security & Permissions

### Security Features

#### Authentication Security
- Secure credential storage (`flutter_secure_storage`)
- Biometric authentication
- Session management
- Token refresh
- Account lockout (Firebase handles)

#### Data Security
- Firestore security rules
- Storage security rules
- User data isolation
- Encrypted sensitive data
- Secure API key storage (Remote Config)

#### API Security
- API keys stored in Remote Config (not in code)
- Rate limiting per user
- Error message sanitization
- HTTPS-only API calls

### Permissions Required

#### Android Permissions
- `INTERNET`: Network access
- `CAMERA`: Medicine photo capture, OCR
- `RECORD_AUDIO`: Voice input, voice reminders
- `ACCESS_FINE_LOCATION`: Pharmacy finder
- `ACCESS_COARSE_LOCATION`: Approximate location
- `POST_NOTIFICATIONS`: Push notifications (Android 13+)
- `SCHEDULE_EXACT_ALARM`: Precise reminder scheduling (Android 12+)
- `VIBRATE`: Notification vibration
- `WAKE_LOCK`: Keep device awake for notifications

#### iOS Permissions
- `NSCameraUsageDescription`: Camera access
- `NSMicrophoneUsageDescription`: Microphone access
- `NSLocationWhenInUseUsageDescription`: Location access
- `NSUserNotificationsUsageDescription`: Notifications
- Face ID/Touch ID: Biometric authentication

#### Permission Handling
- Runtime permission requests
- Permission rationale dialogs
- Graceful degradation when permissions denied
- Permission status checking
- Re-request permissions from settings

---

## Setup & Installation

### Prerequisites

1. **Flutter SDK**: >=3.0.0 <4.0.0
2. **Dart SDK**: >=3.0.0
3. **Node.js**: 20+ (for Cloud Functions)
4. **Firebase Account**: Create project at [Firebase Console](https://console.firebase.google.com)
5. **Android Studio** / **Xcode**: For platform builds
6. **Git**: Version control

### Step-by-Step Setup

#### 1. Clone Repository

```bash
git clone <repository-url>
cd Tickdo
```

#### 2. Install Flutter Dependencies

```bash
flutter pub get
```

#### 3. Install Cloud Functions Dependencies

```bash
cd functions
npm install
cd ..
```

#### 4. Firebase Setup

**a. Create Firebase Project**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project: `tickdoseapp`
3. Enable Google Analytics (optional)

**b. Enable Firebase Services**
- Authentication (Email/Password, Google, Apple)
- Cloud Firestore
- Firebase Storage
- Cloud Functions
- Cloud Messaging
- Remote Config
- Crashlytics
- Analytics
- Performance Monitoring

**c. Configure Firebase CLI**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase (if not already done)
firebase init
```

**d. Download Configuration Files**
- Android: Download `google-services.json` → Place in `android/app/`
- iOS: Download `GoogleService-Info.plist` → Place in `ios/Runner/`

#### 5. Android Configuration

**a. Release Keystore**

```bash
# Generate keystore (if not exists)
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

**b. SHA-1 Fingerprints**

```bash
# Debug SHA-1
cd android && ./gradlew signingReport

# Release SHA-1
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

Add both SHA-1 fingerprints to Firebase Console → Project Settings → Your Android App

**c. Re-download google-services.json** after adding SHA-1

#### 6. iOS Configuration

**a. Apple Sign-In**
1. Enable "Sign in with Apple" in Firebase Console
2. In Xcode: Signing & Capabilities → Add "Sign in with Apple"

**b. Push Notifications**
1. Enable Push Notifications capability in Xcode
2. Upload APNs certificate to Firebase Console

**c. Deep Linking**
1. Configure Associated Domains in Xcode
2. Add domain: `applinks:tickdose.app`

#### 7. Environment Configuration

**Option 1: .env File (Development)**

```bash
# Create .env file in root
touch .env

# Add to .env
GEMINI_API_KEY=your_gemini_api_key
ELEVENLABS_API_KEY=your_elevenlabs_api_key
```

**Option 2: Firebase Remote Config (Recommended for Production)**

1. Go to Firebase Console → Remote Config
2. Add parameters:
   - `GEMINI_API_KEY`: Your Google Gemini API key
   - `ELEVENLABS_API_KEY`: Your ElevenLabs API key
3. Publish configuration

#### 8. Deploy Backend

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes

# Deploy Storage rules
firebase deploy --only storage

# Deploy Cloud Functions
cd functions
npm install
cd ..
firebase deploy --only functions
```

#### 9. Run the App

```bash
# Development
flutter run

# Specific device
flutter run -d <device-id>

# Release mode (for testing)
flutter run --release
```

---

## Configuration

### App Constants

Edit `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const int defaultRefillReminderDays = 7;
  static const String defaultQuietHoursStart = '22:00'; // 10 PM
  static const String defaultQuietHoursEnd = '08:00';   // 8 AM
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxAudioSize = 10 * 1024 * 1024; // 10MB
  // ... more constants
}
```

### API Configuration

#### Google Gemini API
1. Get API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Add to Firebase Remote Config as `GEMINI_API_KEY`
3. Or add to `.env` file for local development

#### ElevenLabs API
1. Get API key from [ElevenLabs](https://elevenlabs.io/)
2. Add to Firebase Remote Config as `ELEVENLABS_API_KEY`
3. Or add to `.env` file for local development

### Timezone Configuration

Default timezone handling:
- Automatically detects device timezone
- Fallback to UTC if detection fails
- User can override in settings
- Timezone-aware reminder scheduling

### Notification Configuration

Edit notification settings in code or via Firebase Remote Config:
- Default quiet hours
- Notification sounds
- Vibration patterns
- Action button configuration

---

## Build & Deployment

### Development Build

```bash
# Debug build
flutter run --debug

# Profile build (performance testing)
flutter run --profile

# Release build (testing)
flutter run --release
```

### Android Build

#### APK Build

```bash
flutter build apk --release

# Split APKs by ABI (smaller size)
flutter build apk --split-per-abi --release
```

#### App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### Signing Configuration

Ensure `android/key.properties` exists:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=upload-keystore.jks
```

### iOS Build

#### Build for Device

```bash
flutter build ios --release
```

#### Archive in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Product → Archive
3. Distribute to App Store or TestFlight

#### App Store Configuration

- Bundle Identifier: `com.tickdose.app`
- Version: 1.0.0
- Build Number: 1
- Signing: Automatic or manual

### Pre-Deployment Checklist

- [ ] All Firestore rules deployed
- [ ] All Firestore indexes deployed
- [ ] Storage rules deployed
- [ ] Cloud Functions deployed
- [ ] Release SHA-1 added to Firebase
- [ ] `google-services.json` updated
- [ ] Keystore password changed from default
- [ ] Keystore backed up securely
- [ ] API keys configured in Remote Config
- [ ] Version numbers updated
- [ ] Release notes prepared
- [ ] Testing completed
- [ ] Crashlytics monitoring enabled
- [ ] Analytics enabled

### Post-Deployment

- [ ] Monitor Firebase Console for errors
- [ ] Check Crashlytics for crashes
- [ ] Monitor API quota usage
- [ ] Review Analytics data
- [ ] Test push notifications
- [ ] Verify offline functionality
- [ ] Test on multiple devices
- [ ] Monitor user feedback

---

## Testing

### Unit Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/medicine_service_test.dart

# Run with coverage
flutter test --coverage
```

### Widget Tests

```bash
# Run widget tests
flutter test test/widget_test.dart
```

### Integration Tests

```bash
# Run integration tests
flutter test integration_test/
```

### Manual Testing Checklist

#### Authentication
- [ ] Email/password registration
- [ ] Email/password login
- [ ] Google Sign-In
- [ ] Apple Sign-In (iOS)
- [ ] Biometric authentication
- [ ] Password reset
- [ ] Email verification

#### Medicine Management
- [ ] Add medicine manually
- [ ] Add medicine via camera OCR
- [ ] Scan barcode
- [ ] Edit medicine
- [ ] Delete medicine
- [ ] Expiry tracking
- [ ] Low stock alerts

#### Reminders
- [ ] Create reminder
- [ ] Edit reminder
- [ ] Delete reminder
- [ ] Enable/disable reminder
- [ ] Notification received
- [ ] Voice reminder playback
- [ ] Quiet hours respect

#### Tracking
- [ ] Mark as taken
- [ ] Mark as skipped
- [ ] Mark as missed
- [ ] Calendar view
- [ ] Statistics calculation
- [ ] PDF export

#### AI Features
- [ ] "I Feel" text chat
- [ ] Voice input
- [ ] Voice output
- [ ] Chat history
- [ ] Symptom analysis

#### Caregiver
- [ ] Send invitation
- [ ] Accept invitation
- [ ] View patient data
- [ ] Receive notifications
- [ ] Revoke access

#### Settings
- [ ] Change language
- [ ] Toggle dark mode
- [ ] Notification settings
- [ ] Voice settings
- [ ] Privacy settings

---

## Troubleshooting

### Common Issues

#### 1. Google Sign-In fails in release build

**Solution:**
- Verify release SHA-1 is in Firebase Console
- Re-download `google-services.json`
- Clean and rebuild: `flutter clean && flutter build apk --release`

#### 2. Cloud Functions deployment fails

**Solution:**
- Ensure billing is enabled on Firebase project
- Check Node.js version (requires 20+)
- Verify Firebase CLI is up to date: `npm install -g firebase-tools`
- Check function logs: `firebase functions:log`

#### 3. Offline persistence not working

**Solution:**
- Check Firestore settings initialization in `main.dart`
- Verify cache size is not limited
- Test on physical device (emulators may have issues)
- Check Firestore rules allow read access

#### 4. Push notifications not received

**Solution:**
- Verify FCM token is stored in Firestore
- Check notification permissions
- Test on physical device (not emulator)
- Verify APNs certificate (iOS) or FCM server key (Android)
- Check notification channel configuration (Android)

#### 5. API rate limit errors

**Solution:**
- Check API quota in Google Cloud Console / ElevenLabs dashboard
- Verify rate limiting implementation
- Check `ApiRateLimiter` service
- Monitor API usage in Remote Config

#### 6. Localization not working

**Solution:**
- Run `flutter gen-l10n` to generate localization files
- Check `l10n.yaml` configuration
- Verify ARB files are in `lib/l10n/`
- Restart app after language change

#### 7. Build errors

**Solution:**
```bash
# Clean build
flutter clean
flutter pub get
flutter pub upgrade

# Rebuild
flutter build apk --release
```

#### 8. Permission denied errors

**Solution:**
- Check permission requests in code
- Verify permission declarations in `AndroidManifest.xml` / `Info.plist`
- Test permission flow manually
- Check `PermissionService` implementation

---

## API References

### Internal APIs

#### MedicineService

```dart
// Get all medicines
Future<List<MedicineModel>> getMedicines();

// Get medicine stream
Stream<List<MedicineModel>> getMedicinesStream();

// Add medicine
Future<String> addMedicine(MedicineModel medicine);

// Update medicine
Future<void> updateMedicine(String id, MedicineModel medicine);

// Delete medicine
Future<void> deleteMedicine(String id);

// Get medicine by ID
Future<MedicineModel?> getMedicineById(String id);
```

#### ReminderService

```dart
// Get all reminders
Future<List<ReminderModel>> getReminders();

// Add reminder
Future<String> addReminder(ReminderModel reminder);

// Update reminder
Future<void> updateReminder(String id, ReminderModel reminder);

// Delete reminder
Future<void> deleteReminder(String id);

// Enable/disable reminder
Future<void> toggleReminder(String id, bool enabled);
```

#### GeminiService

```dart
// Send chat message
Future<String> sendChatMessage(
  String message, {
  required String apiKey,
  List<Content>? history,
  UserModel? userProfile,
});

// Check symptom
Future<String> checkSymptom({
  required String symptom,
  required List<MedicineModel> userMedicines,
  required String apiKey,
});

// Get medicine details
Future<Map<String, dynamic>> getMedicineDetails(
  String medicineName, {
  required String apiKey,
  String language = 'en',
});
```

#### ElevenLabsService

```dart
// Text to speech
Future<String> textToSpeech({
  required String text,
  required String voiceId,
  ElevenLabsModel model = ElevenLabsModel.flash,
  double stability = 0.5,
  double similarityBoost = 0.75,
});

// Get available voices
Future<List<VoiceModel>> getAvailableVoices();

// Play audio
Future<void> playAudio({required String audioPath});

// Stop playback
Future<void> stopPlayback();
```

### External APIs

#### Google Gemini AI
- **Models**: 
  - `gemini-3-flash` (default) - Stable Gemini 3 Flash: Fast, cost-effective for most tasks
  - `gemini-3-pro` - Stable Gemini 3 Pro: Advanced reasoning for medical analysis tasks
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/{model-name}:generateContent`
- **Authentication**: API key in header
- **Rate Limits**: Per-user rate limiting implemented
- **Model Selection**: Pro model used for symptom analysis and drug interactions; Flash for chat, enrichment, OCR, and quests
- **Features**:
  - **Search Grounding**: Enabled for real-time medical data retrieval
  - **Safety Settings**: Configured for medical, dangerous, harassment, and hate speech content
  - **Structured Outputs**: JSON schema enforcement for reliable parsing
  - **Enhanced Prompts**: XML-style structured prompts following best practices
  - **Retry Logic**: Exponential backoff (max 3 retries) for transient failures
  - **Response Caching**: 24-hour cache for identical queries
  - **Output Cleaning**: Robust JSON parsing with validation and error recovery
- **Note**: Using stable Gemini 3 family models (verified stable as of 2025, no experimental/preview versions)
- **Documentation**: [Google AI Studio](https://makersuite.google.com/app/apikey)

#### ElevenLabs
- **Endpoint**: `https://api.elevenlabs.io/v1/text-to-speech/{voiceId}`
- **Authentication**: API key in header (`xi-api-key`)
- **Rate Limits**: Per-user rate limiting implemented
- **Documentation**: [ElevenLabs API Docs](https://elevenlabs.io/docs)

---

## Contributing

### Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Add tests if applicable
5. Ensure all tests pass: `flutter test`
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

### Code Style

- Follow Dart style guide: [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before committing
- Format code: `dart format .`
- Run linter: `flutter analyze`

### Commit Messages

Use clear, descriptive commit messages:
- `feat: Add new feature`
- `fix: Fix bug`
- `docs: Update documentation`
- `style: Code formatting`
- `refactor: Code refactoring`
- `test: Add tests`
- `chore: Maintenance tasks`

---

## License

[Add your license here]

---

## Support & Contact

### Issues

For bug reports and feature requests:
- Create an issue in the repository
- Include device information, OS version, app version
- Include steps to reproduce
- Include relevant logs

### Documentation

- Check existing documentation files
- Review Firebase Console logs
- Check Crashlytics for crash reports

### Acknowledgments

- **Firebase**: Backend infrastructure
- **Google Gemini**: AI capabilities
- **ElevenLabs**: Voice synthesis
- **Flutter Team**: Amazing framework
- **Open Source Community**: Various packages and libraries

---

## Version History

### Version 1.0.0+1 (Current)

**Initial Release**
- Complete medication management system
- AI-powered symptom checking
- Voice reminders
- Caregiver support
- Multi-language support (English, Arabic)
- Offline functionality
- Full Firebase integration
- Production-ready error handling
- Comprehensive localization
- Dark mode support

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Maintained by**: Tickdose Development Team

