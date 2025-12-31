# TICKDOSE - Complete Application Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Technology Stack](#technology-stack)
5. [Project Structure](#project-structure)
6. [Setup & Installation](#setup--installation)
7. [Configuration](#configuration)
8. [Core Services](#core-services)
9. [Data Models](#data-models)
10. [Authentication & Security](#authentication--security)
11. [Firebase Integration](#firebase-integration)
12. [AI Features](#ai-features)
13. [State Management](#state-management)
14. [Navigation](#navigation)
15. [Build & Deployment](#build--deployment)
16. [Testing](#testing)
17. [Known Issues & Solutions](#known-issues--solutions)
18. [API References](#api-references)

---

## Overview

**TICKDOSE** is a comprehensive medication reminder and health tracking application built with Flutter. The app helps users manage their medications, track adherence, receive intelligent reminders, and interact with AI-powered health assistance.

### Key Statistics
- **App Name**: TICKDOSE
- **Version**: 1.0.0+1
- **Platform**: Android, iOS, Web
- **Firebase Project**: `tickdoseapp`
- **Package Name**: `com.tickdose.app`
- **Default Timezone**: Africa/Cairo (UTC+2)

### Core Purpose
- Medication management and tracking
- Intelligent reminder system
- Adherence analytics and insights
- AI-powered symptom checking
- Pharmacy finder with location services
- Voice-based interactions
- Health data tracking

---

## Architecture

### Architecture Pattern
- **State Management**: Riverpod (primary), Provider (legacy support)
- **Architecture Style**: Feature-based modular architecture
- **Design Pattern**: Provider pattern with services layer

### Key Components
1. **Features Layer** (`lib/features/`) - Feature-specific UI and business logic
2. **Core Layer** (`lib/core/`) - Shared services, models, utilities, and themes
3. **Services Layer** (`lib/core/services/`) - Business logic and external integrations
4. **Providers Layer** (`lib/*/providers/`) - State management

### Data Flow
```
UI Layer (Screens/Widgets)
    ↓
Providers (State Management)
    ↓
Services (Business Logic)
    ↓
Firebase/Local Storage
```

---

## Features

### 1. Authentication & User Management
- **Email/Password Authentication**
- **Google Sign-In**
- **Apple Sign-In** (iOS)
- **Biometric Authentication** (Fingerprint/Face ID)
- **Password Reset**
- **Email Verification**
- **Profile Management**
  - Edit profile information
  - Health information tracking
  - Change password
  - Account deletion

### 2. Medicine Management
- **Add Medicines**
  - Manual entry
  - Camera-based OCR (text recognition)
  - Medicine image capture
- **Medicine Details**
  - Name, generic name, strength, form
  - Dosage instructions
  - Manufacturer, batch number
  - Expiry date tracking
  - Prescription information
  - Side effects and interactions
  - Custom notes
- **Medicine List & Search**
- **Edit & Delete Medicines**
- **Expiry Tracking**
  - Visual indicators for expiring/expired medicines
  - Refill reminders (default 7 days)

### 3. Reminder System
- **Multiple Reminder Types**
  - Once daily
  - Twice daily
  - Three times daily
  - Four times daily
  - Every 8 hours
  - Every 12 hours
  - Meal-based reminders (breakfast, lunch, dinner, bedtime)
  - Custom schedules
- **Flexible Timing**
  - Multiple times per day
  - Meal timing (before/with/after meals)
  - Interval-based reminders
  - Day-of-week selection
- **Reminder Management**
  - Enable/disable reminders
  - Edit reminders
  - Delete reminders
- **Notification Features**
  - Local notifications
  - Firebase Cloud Messaging (FCM)
  - Quiet hours support
  - Sound effects
  - Urgent reminder alerts

### 4. Medication Tracking
- **Daily Tracking**
  - Mark as taken
  - Mark as skipped
  - Mark as missed
- **Calendar View**
  - Monthly calendar
  - Daily medication logs
- **Adherence Statistics**
  - Overall adherence rate
  - Streak tracking
  - Monthly/weekly statistics
  - Pie charts and line graphs
- **History Logs**
  - Complete medication history
  - Filter by status (taken/skipped/missed)
  - Search functionality
- **PDF Export**
  - Generate medication reports
  - Share with healthcare providers

### 5. Side Effects Tracking
- **Log Side Effects**
  - Per medication
  - Date and time tracking
  - Severity levels
  - Notes
- **Side Effects List**
  - View all logged side effects
  - Filter by medicine
  - Trend analysis

### 6. AI-Powered Features ("I Feel")

#### Symptom Checking
- **Text Chat Interface**
  - AI-powered symptom analysis using Google Gemini
  - Context-aware responses (considers user's current medications)
  - Structured symptom analysis
  - Urgency assessment
  - Recommendations
- **Voice Chat Interface**
  - Speech-to-text input
  - Text-to-speech responses
  - ElevenLabs voice synthesis (optional)
  - Voice settings customization
- **Chat History**
  - Save conversations
  - Review past interactions
  - Context continuity

#### AI Capabilities
- Symptom analysis with context
- Drug interaction checking
- Adherence coaching and insights
- Personalized health tips

### 7. Pharmacy Finder
- **Location-Based Search**
  - Find nearby pharmacies
  - Map view with markers
  - List view with details
- **Pharmacy Information**
  - Name, address, phone
  - Distance calculation
  - Operating hours
- **Integration**
  - Google Maps integration
  - Location services

### 8. Settings & Preferences
- **Notification Settings**
  - Enable/disable notifications
  - Quiet hours configuration
  - Sound preferences
  - Reminder sounds
- **Privacy Settings**
  - Biometric login toggle
  - Health data sharing
  - Location services
  - Data deletion
- **Voice Settings**
  - Voice selection (ElevenLabs)
  - Voice speed
  - Voice volume
- **App Settings**
  - Dark mode toggle
  - Language preferences
  - About information
  - Help & support
  - Terms of service
  - Privacy policy

### 9. Onboarding
- **First-time User Experience**
  - Welcome screens
  - Feature highlights
  - Guided setup

### 10. Sound Effects System
- **12 Different Sound Effects**
  - User actions: medication taken, skipped, missed, success, error, tap
  - Notifications: reminder alert, urgent reminder
  - Achievements: streak milestone, perfect week
  - UI sounds: swipe, toggle
- **Audio Controls**
  - Enable/disable sounds
  - Volume control
  - Per-action sound selection

---

## Technology Stack

### Frontend
- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **UI Framework**: Material Design
- **State Management**: 
  - Riverpod 2.4.2 (primary)
  - Provider 6.1.1 (legacy)

### Backend & Cloud Services
- **Firebase Core**: 2.24.0
- **Authentication**: Firebase Auth 4.16.0
- **Database**: Cloud Firestore 4.14.0
- **Storage**: Firebase Storage 11.6.0
- **Messaging**: Firebase Cloud Messaging 14.7.0
- **Crashlytics**: Firebase Crashlytics 3.4.12
- **Remote Config**: Firebase Remote Config 4.4.7

### AI & ML
- **Gemini AI**: google_generative_ai 0.4.0
- **Speech Recognition**: speech_to_text 7.3.0
- **Text-to-Speech**: flutter_tts 3.8.5
- **Text Recognition**: google_mlkit_text_recognition 0.15.0
- **Voice Synthesis**: ElevenLabs (via custom service)

### Local Storage
- **Shared Preferences**: shared_preferences 2.5.3
- **Secure Storage**: flutter_secure_storage 9.0.0
- **Hive**: hive 2.2.3, hive_flutter 1.1.0
- **SQLite**: sqflite 2.3.3

### Notifications
- **Local Notifications**: flutter_local_notifications 17.0.0
- **Timezone**: timezone 0.9.3

### Location & Maps
- **Location Services**: location 6.0.0, geolocator 10.1.0
- **Maps**: flutter_map 6.1.0, latlong2 0.9.0

### Utilities
- **HTTP Client**: dio 5.4.0, http 1.6.0
- **Permissions**: permission_handler 11.3.0
- **Device Info**: device_info_plus 10.0.0
- **Image Picker**: image_picker 1.0.7
- **Cached Images**: cached_network_image 3.4.0
- **PDF Generation**: pdf 3.11.1, printing 5.13.3
- **Charts**: fl_chart 0.66.0
- **Calendar**: table_calendar 3.1.0
- **Audio**: audioplayers 6.1.0, just_audio 0.10.5, record 6.1.2
- **Internationalization**: intl 0.19.0
- **URL Launcher**: url_launcher 6.2.0
- **Biometrics**: local_auth 2.1.8

---

## Project Structure

```
lib/
├── core/                           # Core functionality
│   ├── constants/                  # App constants
│   │   ├── app_constants.dart     # App-wide constants
│   │   ├── api_constants.dart     # API endpoints
│   │   ├── dimens.dart            # Spacing/dimension constants
│   │   └── strings.dart           # String constants
│   ├── icons/                      # App icons
│   │   └── app_icons.dart
│   ├── models/                     # Data models
│   │   ├── medicine_model.dart
│   │   ├── reminder_model.dart
│   │   ├── medicine_log_model.dart
│   │   ├── side_effect_log_model.dart
│   │   ├── user_model.dart
│   │   ├── pharmacy_model.dart
│   │   ├── i_feel_models.dart
│   │   └── voice_model.dart
│   ├── providers/                  # Shared providers
│   │   └── voice_settings_provider.dart
│   ├── services/                   # Business logic services
│   │   ├── firebase_auth_service.dart
│   │   ├── firebase_user_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   ├── notification_service.dart
│   │   ├── audio_service.dart
│   │   ├── firebase_messaging_service.dart
│   │   ├── gemini_service.dart
│   │   ├── speech_service.dart
│   │   ├── voice_service.dart
│   │   ├── voice_reminder_service.dart
│   │   ├── elevenlabs_service.dart
│   │   ├── elevenlabs_streaming_service.dart
│   │   ├── medicine_ocr_service.dart
│   │   ├── location_service.dart
│   │   ├── pharmacy_service.dart
│   │   ├── biometric_auth_service.dart
│   │   ├── permission_service.dart
│   │   ├── remote_config_service.dart
│   │   ├── cache_service.dart
│   │   └── image_upload_service.dart
│   ├── theme/                      # App theming
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/                      # Utility functions
│   │   ├── date_time_utils.dart
│   │   ├── validators.dart
│   │   ├── password_validator.dart
│   │   ├── reminder_helpers.dart
│   │   ├── adherence_calculator.dart
│   │   ├── logger.dart
│   │   ├── extensions.dart
│   │   ├── multilingual_support.dart
│   │   └── auth_error_messages.dart
│   └── widgets/                    # Shared widgets
│       └── permission_dialog.dart
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── home/                       # Home screen
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── medicines/                  # Medicine management
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── reminders/                  # Reminder system
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── tracking/                   # Medication tracking
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── pharmacy/                   # Pharmacy finder
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   ├── profile/                    # User profile
│   │   ├── providers/
│   │   └── screens/
│   ├── settings/                   # App settings
│   │   ├── screens/
│   │   └── widgets/
│   ├── i_feel/                     # AI chat feature
│   │   └── screens/
│   ├── onboarding/                 # Onboarding flow
│   │   ├── screens/
│   │   └── widgets/
│   ├── splash/                     # Splash screen
│   │   └── screens/
│   └── navigation/                 # Navigation & routing
│       ├── routes/
│       └── widgets/
│
├── l10n/                           # Localization
│   ├── app_en.arb                  # English strings
│   └── app_ar.arb                  # Arabic strings
│
├── firebase_options.dart           # Firebase configuration
└── main.dart                       # App entry point
```

---

## Setup & Installation

### Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   ```bash
   flutter --version
   ```

2. **Dart SDK** (3.0.0 or higher)

3. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

4. **FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

5. **Platform-specific setup**:
   - **Android**: Android Studio, Android SDK
   - **iOS**: Xcode (macOS only)
   - **Web**: Chrome browser

### Installation Steps

1. **Clone the repository** (if applicable)

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Follow the detailed guide in `FIREBASE_SETUP.md`
   - Or run the automated script:
     ```bash
     ./firebase_setup.sh
     ```

4. **Configure environment variables**
   - Copy `.env.example` to `.env`
   - Add required API keys (see Configuration section)

5. **Run the app**
   ```bash
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d chrome
   ```

---

## Configuration

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# Gemini AI API Key (for symptom checking)
GEMINI_API_KEY=your_gemini_api_key_here

# ElevenLabs API Key (for voice synthesis - optional)
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here

# Other API keys as needed
```

### Firebase Remote Config

The app uses Firebase Remote Config to manage API keys securely. Configure in Firebase Console:

1. Go to Firebase Console → Remote Config
2. Add parameters:
   - `GEMINI_API_KEY`: Your Google Gemini API key
   - `ELEVENLABS_API_KEY`: Your ElevenLabs API key (optional)

### App Constants

Edit `lib/core/constants/app_constants.dart` to customize:
- Default refill reminder days (default: 7)
- Quiet hours (default: 10 PM - 8 AM)
- Pagination limits
- Validation rules

### Timezone Configuration

Default timezone is set in `lib/main.dart`:
```dart
tz.setLocalLocation(tz.getLocation('Africa/Cairo')); // UTC+2
```

Modify as needed for your target region.

---

## Core Services

### Authentication Services

#### FirebaseAuthService
- Email/password authentication
- Google Sign-In
- Apple Sign-In
- Password reset
- Email verification

#### BiometricAuthService
- Fingerprint/Face ID authentication
- Secure credential storage
- Credential management

### Data Services

#### FirestoreService
- CRUD operations for Firestore
- Real-time data streams
- Query building
- Data validation

#### StorageService
- Firebase Storage integration
- Image upload/download
- File management

#### FirebaseUserService
- User profile management
- User data CRUD operations

### Notification Services

#### NotificationService
- Local notification scheduling
- Timezone-aware notifications
- Notification cancellation
- Notification channels

#### FirebaseMessagingService
- FCM push notifications
- Notification handling
- Token management

### AI Services

#### GeminiService
- Symptom analysis
- Drug interaction checking
- Adherence insights generation
- Structured AI responses

#### SpeechService
- Speech-to-text conversion
- Text-to-speech synthesis
- Language detection

#### VoiceService
- Voice reminder generation
- Voice synthesis (ElevenLabs)
- Voice streaming

### Utility Services

#### AudioService
- Sound effect playback
- Volume control
- Sound enable/disable toggle
- 12 predefined sound effects

#### LocationService
- Current location retrieval
- Location permissions
- Distance calculations

#### MedicineOCRService
- Camera-based text recognition
- Medicine label extraction
- Image processing

#### PharmacyService
- Nearby pharmacy search
- Pharmacy data retrieval
- Distance calculations

#### RemoteConfigService
- Remote configuration management
- API key retrieval
- Feature flags

#### CacheService
- Local data caching
- Cache management

---

## Data Models

### MedicineModel
```dart
- id: String
- userId: String
- name: String
- genericName: String
- strength: String (e.g., "500mg")
- form: String (tablet, capsule, liquid, injection)
- dosage: String
- frequency: String
- manufacturer: String
- batchNumber: String
- expiryDate: DateTime?
- prescribedBy: String
- prescriptionDate: DateTime?
- refillReminderDays: int
- sideEffects: List<String>
- interactions: List<String>
- notes: String
- imageUrl: String?
- imageCapturedAt: DateTime?
- createdAt: DateTime
- updatedAt: DateTime
```

### ReminderModel
```dart
- id: String
- medicineId: String
- medicineName: String
- frequency: ReminderFrequency (enum)
- times: List<String> (HH:mm format)
- mealTimes: Map<String, String>? (for meal-based reminders)
- mealTiming: MealTiming? (before/with/after meals)
- startTime: String? (HH:mm format)
- intervalHours: int?
- includeOvernight: bool
- enabled: bool
- time: String (primary time)
- dosage: String
- frequency_legacy: String
- daysOfWeek: List<int>
- notificationId: int
```

### MedicineLogModel
```dart
- id: String
- userId: String
- medicineId: String
- medicineName: String
- status: String (taken, skipped, missed)
- timestamp: DateTime
- notes: String?
- dosage: String
```

### SideEffectLogModel
```dart
- id: String
- userId: String
- medicineId: String
- medicineName: String
- symptom: String
- severity: String (mild, moderate, severe)
- timestamp: DateTime
- notes: String?
```

### UserModel
```dart
- id: String
- email: String
- displayName: String
- photoUrl: String?
- phoneNumber: String?
- dateOfBirth: DateTime?
- gender: String?
- healthConditions: List<String>
- allergies: List<String>
- createdAt: DateTime
- updatedAt: DateTime
```

### PharmacyModel
```dart
- id: String
- name: String
- address: String
- phoneNumber: String?
- latitude: double
- longitude: double
- openingHours: Map<String, String>?
- distance: double? (calculated)
```

---

## Authentication & Security

### Authentication Methods

1. **Email/Password**
   - Standard Firebase Auth
   - Email verification required
   - Password reset via email

2. **Google Sign-In**
   - OAuth 2.0 flow
   - Requires SHA-1 fingerprints in Firebase Console

3. **Apple Sign-In** (iOS only)
   - Native iOS integration
   - Privacy-focused

4. **Biometric Authentication**
   - Fingerprint (Android)
   - Face ID / Touch ID (iOS)
   - Optional login method
   - Secure credential storage

### Security Features

1. **Firestore Security Rules**
   - User-based access control
   - Data ownership validation
   - Field validation
   - See `firestore.rules` for details

2. **Firebase Storage Rules**
   - User-specific file access
   - File type validation
   - Size limits

3. **Secure Storage**
   - Sensitive data stored in `flutter_secure_storage`
   - Biometric credentials encrypted
   - API keys via Remote Config

4. **Password Requirements**
   - Minimum 6 characters
   - Maximum 128 characters
   - Validation on registration

---

## Firebase Integration

### Firebase Project
- **Project ID**: `tickdoseapp`
- **Services Used**:
  - Authentication
  - Firestore Database
  - Cloud Storage
  - Cloud Messaging
  - Remote Config
  - Crashlytics

### Firestore Collections

#### users/{userId}
- User profile data
- Subcollections:
  - `medicines/{medicineId}`
  - `reminders/{reminderId}`
  - `medicineLogs/{logId}`

#### iFeelConversations/{conversationId}
- AI chat conversations
- Subcollections:
  - `messages/{messageId}`

#### pharmacies/{pharmacyId}
- Public pharmacy data (read-only for users)

#### systemConfig/{configId}
- System configuration (admin only)

### Security Rules

Firestore security rules ensure:
- Users can only access their own data
- Data validation on create/update
- Public read access for pharmacies only
- Admin-only access for system config

See `firestore.rules` for complete rules.

### Storage Structure

```
users/{userId}/
  ├── medicines/{medicineId}/images/
  └── profile/
      └── avatar.jpg
```

---

## AI Features

### Google Gemini Integration

#### Symptom Checking
- **Input**: User symptom description + current medications
- **Output**: Structured analysis with:
  - Summary
  - Possible causes
  - Recommendations
  - Urgency level (LOW/MEDIUM/HIGH/EMERGENCY)
  - Doctor visit recommendation

#### Drug Interaction Checking
- Analyzes multiple medications
- Identifies interactions
- Provides severity assessment
- Gives recommendations

#### Adherence Insights
- Personalized coaching based on adherence data
- Actionable tips
- Progress insights

### Voice Features

#### ElevenLabs Integration
- High-quality voice synthesis
- Multiple voice options
- Streaming voice responses
- Customizable voice settings

#### Speech Recognition
- Real-time speech-to-text
- Multi-language support
- Continuous listening mode

---

## State Management

### Riverpod Providers

#### Feature Providers
- `authProvider` - Authentication state
- `medicineProvider` - Medicine list and operations
- `reminderProvider` - Reminder management
- `trackingProvider` - Medication tracking
- `homeProvider` - Home screen data
- `profileProvider` - User profile
- `settingsProvider` - App settings
- `biometricEnabledProvider` - Biometric settings
- `healthDataSharingProvider` - Privacy settings

#### Stream Providers
- Real-time Firestore streams
- Auto-updating UI on data changes

### Provider Pattern
```dart
// Example usage
final medicinesAsync = ref.watch(medicinesStreamProvider);
final authState = ref.watch(authStateProvider);
```

---

## Navigation

### Route Structure

All routes are defined in `lib/features/navigation/routes/route_names.dart`:

**Auth Routes:**
- `/` - Splash screen
- `/onboarding` - Onboarding
- `/login` - Login
- `/register` - Register
- `/forgot-password` - Password reset
- `/email-verification` - Email verification

**Main App Routes:**
- `/home` - Home screen
- `/today` - Today's medications

**Medicine Routes:**
- `/medicines` - Medicine list
- `/medicines/add` - Add medicine
- `/medicines/edit` - Edit medicine
- `/medicines/detail` - Medicine details

**Reminder Routes:**
- `/reminders` - Reminder list
- `/reminders/add` - Add reminder
- `/reminders/edit` - Edit reminder

**Tracking Routes:**
- `/tracking` - Tracking screen

**Pharmacy Routes:**
- `/pharmacy` - Pharmacy finder

**Profile Routes:**
- `/profile` - Profile screen
- `/profile/edit` - Edit profile
- `/profile/health` - Health info

**Settings Routes:**
- `/settings` - Settings screen
- `/settings/notifications` - Notification settings
- `/settings/privacy` - Privacy settings
- `/settings/voice` - Voice settings
- `/settings/about` - About
- `/settings/help` - Help
- `/settings/privacy-policy` - Privacy policy
- `/settings/terms-of-service` - Terms of service

**AI Chat Routes:**
- `/i-feel` - Chat screen
- `/i-feel/history` - Chat history
- `/i-feel/voice` - Voice chat

### Navigation Implementation
- Uses `MaterialPageRoute`
- Named routes via `AppRouter.generateRoute`
- Argument passing support
- Deep linking ready

---

## Build & Deployment

### Development Build

```bash
# Debug build
flutter run

# Debug build with specific device
flutter run -d <device-id>

# Check devices
flutter devices
```

### Release Build

#### Android

1. **Create release keystore** (if not exists)
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure keystore** in `android/keystore.properties`

3. **Build APK**
   ```bash
   flutter build apk --release
   ```

4. **Build App Bundle** (for Play Store)
   ```bash
   flutter build appbundle --release
   ```

5. **Verify signing**
   ```bash
   cd android
   ./gradlew signingReport
   ```

#### iOS

1. **Configure signing** in Xcode
   - Open `ios/Runner.xcworkspace`
   - Set signing team and bundle identifier

2. **Build for release**
   ```bash
   flutter build ios --release
   ```

3. **Archive in Xcode**
   - Product → Archive
   - Upload to App Store Connect

### Release Checklist

See `RELEASE_CHECKLIST.md` for detailed checklist:

- [x] Release keystore created
- [x] Keystore properties configured
- [x] Build.gradle.kts updated
- [ ] Release SHA-1 added to Firebase Console
- [ ] google-services.json re-downloaded
- [ ] Keystore password changed
- [ ] Keystore backed up securely
- [ ] Release build tested
- [ ] Google Sign-In tested
- [ ] All features tested

### SHA-1 Fingerprints

**Debug SHA-1:**
```
5d07e80397602d316d88f5fea803820ca772aaa4
```

**Release SHA-1:**
```
dcd383b3ae47cb88052d44b6521191379acbea28
```

⚠️ **Important**: Add release SHA-1 to Firebase Console for Google Sign-In to work in production.

---

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter test integration_test/
```

### Test Script
Use the provided test script:
```bash
./run_test.sh
```

---

## Known Issues & Solutions

### Current Issues

1. **google_mlkit_commons Dependency Issue**
   - **Error**: `resource android:attr/lStar not found`
   - **Cause**: Compatibility issue with Android build tools
   - **Solution**: Update `google_mlkit_text_recognition` to ^0.15.0 (already done)
   - **Status**: May need Android build tools update

### Build Issues

#### Issue: "Permission denied" in Firebase CLI
**Solution:**
```bash
firebase logout
firebase login --reauth
```

#### Issue: "Project not found"
**Solution:**
```bash
firebase projects:list
firebase use tickdoseapp
```

#### Issue: "FlutterFire not found"
**Solution:**
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

#### Issue: Google Sign-In fails in release build
**Solution:**
1. Verify release SHA-1 in Firebase Console
2. Re-download `google-services.json`
3. Clean and rebuild:
   ```bash
   flutter clean && flutter build apk --release
   ```

### Runtime Issues

#### Issue: Remote Config initialization fails
**Impact**: AI features may not work
**Solution**: Ensure API keys are set in Firebase Remote Config

#### Issue: Notifications not working
**Solution**:
1. Check notification permissions
2. Verify notification channel setup
3. Check device notification settings

---

## API References

### Firebase APIs

#### Authentication
- `FirebaseAuth.instance.currentUser`
- `FirebaseAuth.instance.signInWithEmailAndPassword()`
- `FirebaseAuth.instance.createUserWithEmailAndPassword()`
- `FirebaseAuth.instance.signInWithCredential()`

#### Firestore
- `FirebaseFirestore.instance.collection()`
- `FirebaseFirestore.instance.doc()`
- `collection().add()`, `.get()`, `.update()`, `.delete()`
- `collection().snapshots()` (real-time streams)

#### Storage
- `FirebaseStorage.instance.ref()`
- `ref().putFile()`, `.getDownloadURL()`, `.delete()`

#### Remote Config
- `FirebaseRemoteConfig.instance.getString()`
- `FirebaseRemoteConfig.instance.fetchAndActivate()`

### Gemini AI API

#### Models Used
- `gemini-3-flash` - Stable Gemini 3 Flash: Default model for chat, medicine enrichment, OCR, and quest generation (fast, cost-effective)
- `gemini-3-pro` - Stable Gemini 3 Pro: Advanced model for symptom analysis and drug interaction checking (complex reasoning tasks)
- **Model Selection Strategy**: 
  - Flash (default): Chat conversations, medicine details, image extraction, quest generation
  - Pro: Symptom analysis, drug interactions (safety-critical medical reasoning)
- **Note**: Using stable Gemini 3 family models (verified stable as of 2025)

#### Features & Best Practices
- **Search Grounding**: Enabled for real-time medical data via `Tool.googleSearchRetrieval()`
  - Used for: Medicine details, symptom analysis, drug interactions
  - Provides up-to-date medical information from Google Search
- **Safety Settings**: Configured for medical content, dangerous content, harassment, and hate speech
  - All safety thresholds set to `medium` for medical applications
- **Structured Outputs**: JSON schema enforcement with `responseMimeType: 'application/json'`
  - Schema validation for all response types
  - Default values for missing optional fields
  - Type coercion and validation
- **Enhanced Prompts**: XML-style structured prompts for better model understanding
  - `<role>`, `<task>`, `<context>`, `<output_format>`, `<instructions>` tags
  - Consistent response formatting
- **Retry Logic**: Exponential backoff for transient failures (max 3 retries)
  - Retries on: Network errors, timeouts, 500/502/503 errors
  - Delays: 1s, 2s, 4s
- **Response Caching**: 24-hour cache for identical queries to reduce API calls
  - Automatic cache cleanup every 6 hours
  - LRU eviction when cache is full (max 100 entries)
- **Output Cleaning**: Comprehensive text sanitization
  - HTML/script tag removal (XSS prevention)
  - Markdown artifact cleanup
  - Whitespace normalization
  - Medical disclaimer enforcement
  - Maximum length enforcement (10,000 chars)
- **JSON Parsing**: Enhanced parsing with:
  - Nested markdown code block handling
  - Multiple JSON object extraction
  - Malformed JSON recovery
  - Trailing comma fixes
  - Comment removal
- **Timeouts**: Per-operation timeouts
  - Chat: 30 seconds
  - Symptom analysis: 60 seconds
  - OCR: 45 seconds
  - Quest generation: 30 seconds
  - Medicine details: 30 seconds
- **Temperature**: 1.0 (optimal for Gemini 3 models per best practices)
  - 0.2 for OCR tasks (accuracy over creativity)

#### Methods
- `GenerativeModel.generateContent()` - With safety settings and grounding
- `Chat.sendMessage()` - Multi-turn conversations with context
- Structured prompts with XML-style tags for consistent responses
- Automatic retry with exponential backoff for reliability
- Schema validation for all structured responses
- Text sanitization for all user-facing outputs

#### API Analytics
- Success/failure rate tracking
- Response time monitoring
- Model usage statistics (Flash vs Pro)
- Error pattern analysis
- Stored in Firestore for monitoring and optimization

### ElevenLabs API

#### Models Used (December 2025)
- `eleven_flash_v2_5` - Flash v2.5: Ultra-low latency ~75ms, best for real-time streaming
- `eleven_multilingual_v3` - Multilingual v3: High fidelity, 70+ languages, emotional tags
- `eleven_turbo_v2_5` - Turbo v2.5: Balanced speed and quality

**Model Selection**:
- Flash (default): Real-time streaming, voice reminders, quick responses
- Multilingual: Automatically used for Arabic text, supports 70+ languages
- Turbo: Balanced option for general use

#### Features & Best Practices
- **Audio Validation**: All generated audio files are validated for:
  - File size > 0
  - Valid MP3 header (ID3v2 or frame sync)
  - Minimum duration checks
  - Playability verification
- **Retry Logic**: Exponential backoff (1s, 2s, 4s) for:
  - Rate limit errors (429)
  - Server errors (500, 502, 503)
  - Network/timeout errors
- **Streaming**: Real-time streaming with:
  - Chunk validation
  - Timeout handling (30 seconds)
  - Retry logic for failed streams
  - Optimized latency (level 4)
- **Caching**: LRU cache for audio files (max 100 entries)
- **Connection Pooling**: Persistent HTTP client for efficient connection reuse
- **Batch Processing**: Optimized parallel batch generation with controlled concurrency (max 3 concurrent)

#### Voice Settings
- **stability** (0.0-1.0): Voice consistency (default: 0.5)
- **similarity_boost** (0.0-1.0): Closeness to original voice (default: 0.75)
- **style** (0.0-1.0): Emotional intensity (default: 0.0)
- **use_speaker_boost** (bool): Enhanced voice presence (default: true)

**Note**: The `clarity` parameter has been removed as ElevenLabs API doesn't support it directly. Voice clarity is achieved through `stability` and `similarity_boost` parameters.

#### Error Handling
- Specific error types: `audioGenerationFailed`, `invalidResponseFormat`, `modelUnavailable`
- Comprehensive error messages with actionable guidance
- Automatic retry for transient failures
- Graceful degradation on errors

---

## Additional Resources

### Documentation Files
- `FIREBASE_SETUP.md` - Complete Firebase setup guide
- `BUILD_STATUS.md` - Current build status and issues
- `RELEASE_CHECKLIST.md` - Release deployment checklist
- `RELEASE_SETUP.md` - Release build setup instructions
- `assets/sounds/README.md` - Sound effects documentation

### External Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Google Gemini API](https://ai.google.dev/docs)
  - [Gemini 3 Models](https://ai.google.dev/models/gemini)
  - [Grounding with Google Search](https://ai.google.dev/gemini-api/docs/grounding)
  - [Best Practices](https://ai.google.dev/gemini-api/docs/best-practices)
- [ElevenLabs API](https://elevenlabs.io/docs)
  - [Text-to-Speech API](https://elevenlabs.io/docs/api-reference/text-to-speech)
  - [Streaming API](https://elevenlabs.io/docs/api-reference/text-to-speech-streaming)
  - [Voice Settings](https://elevenlabs.io/docs/api-reference/voice-settings)

---

## Support & Maintenance

### Version Information
- **App Version**: 1.0.0+1
- **Flutter SDK**: >=3.0.0 <4.0.0
- **Dart SDK**: >=3.0.0 <4.0.0

### Contact & Issues
For issues or questions, refer to:
- Firebase Console logs
- Crashlytics reports
- Local error logs (via Logger utility)

### Future Enhancements
- Enhanced OCR accuracy
- More AI features
- Additional voice options
- Expanded pharmacy database
- Multi-language support expansion
- Wearable device integration

---

## License

This project is proprietary. All rights reserved.

---

**Last Updated**: 2024
**Documentation Version**: 1.0.0
