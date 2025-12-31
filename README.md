# TICKDOSE - Medication Reminder App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter-based medication reminder application with AI-powered features, caregiver support, and voice reminders.

## Features

- **Medicine Management**: Add, edit, and track medications with images
- **Smart Reminders**: Timezone-aware notifications with voice reminders
- **Adherence Tracking**: Monitor medication intake with detailed logs and statistics
- **Side Effects Logging**: Track and monitor medication side effects
- **AI Symptom Analysis**: "I Feel" feature powered by Google Gemini AI
- **Caregiver Support**: Share access with family members or caregivers
- **Voice Reminders**: Personalized voice reminders using ElevenLabs
- **Offline Support**: Works offline with Firestore persistence
- **Multi-language**: English and Arabic support
- **Dark Mode**: Full dark mode support

## Tech Stack

- **Framework**: Flutter 3.0+
- **Backend**: Firebase (Firestore, Auth, Storage, Functions, Messaging)
- **State Management**: Riverpod
- **Local Storage**: Hive, SharedPreferences, SQLite
- **AI Services**: Google Gemini AI, ElevenLabs TTS
- **Notifications**: Firebase Cloud Messaging, Local Notifications

## Prerequisites

- Flutter SDK >=3.0.0 <4.0.0
- Dart SDK >=3.0.0
- Node.js 20+ (for Cloud Functions)
- Firebase account and project
- Android Studio / Xcode (for platform-specific builds)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Tickdo
```

### 2. Install Dependencies

```bash
# Flutter dependencies
flutter pub get

# Cloud Functions dependencies
cd functions
npm install
cd ..
```

### 3. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable the following services:
   - Authentication (Email/Password, Google, Apple)
   - Firestore Database
   - Firebase Storage
   - Cloud Functions
   - Cloud Messaging
   - Remote Config
   - Crashlytics
   - Analytics

3. Configure Firebase for your platforms:
   ```bash
   # Install Firebase CLI if not already installed
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase (if not already done)
   firebase init
   ```

4. Download configuration files:
   - Android: `google-services.json` → `android/app/google-services.json`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`

### 4. Environment Configuration

1. Create a `.env` file in the root directory:
   ```bash
   cp .env.example .env
   ```

2. Add your API keys (optional for local development):
   ```
   GEMINI_API_KEY=your_gemini_api_key
   ELEVENLABS_API_KEY=your_elevenlabs_api_key
   ```

3. **Recommended**: Configure API keys in Firebase Remote Config instead:
   - Go to Firebase Console → Remote Config
   - Add parameters: `GEMINI_API_KEY` and `ELEVENLABS_API_KEY`
   - Publish configuration

### 5. Android Setup

1. **Release Keystore** (for production builds):
   ```bash
   # Generate keystore (if not exists)
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

2. **Add SHA-1 Fingerprints to Firebase**:
   - Get debug SHA-1: `cd android && ./gradlew signingReport`
   - Get release SHA-1: `keytool -list -v -keystore android/app/upload-keystore.jks -alias upload`
   - Add both to Firebase Console → Project Settings → Your Android App

3. **Re-download google-services.json** after adding SHA-1

### 6. iOS Setup

1. **Apple Sign-In Configuration**:
   - Enable Sign in with Apple in Firebase Console
   - Configure in Xcode: Signing & Capabilities → Add "Sign in with Apple"

2. **Push Notifications**:
   - Enable Push Notifications capability in Xcode
   - Upload APNs certificate to Firebase Console

3. **Deep Linking**:
   - Configure Associated Domains in Xcode
   - Add domain: `applinks:tickdose.app`

### 7. Deploy Backend

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

## Running the App

### Development

```bash
# Run on connected device/emulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode (for testing)
flutter run --release
```

### Building for Production

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build for iOS
flutter build ios --release

# Archive in Xcode for App Store submission
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants
│   ├── icons/          # Custom icons
│   ├── models/         # Data models
│   ├── providers/      # Global providers
│   ├── services/       # Core services (Firebase, AI, etc.)
│   ├── theme/          # App theming
│   └── utils/          # Utility functions
├── features/           # Feature modules
│   ├── auth/          # Authentication
│   ├── home/          # Home screen
│   ├── medicines/     # Medicine management
│   ├── reminders/     # Reminder management
│   ├── tracking/      # Medication tracking
│   ├── profile/       # User profile
│   └── ...
└── main.dart          # App entry point

functions/             # Cloud Functions
├── index.js          # Function definitions
└── package.json      # Node.js dependencies
```

## Architecture

### State Management
- **Riverpod**: Primary state management solution
- **Provider**: Used for dependency injection

### Data Flow
1. **UI Layer**: Flutter widgets and screens
2. **State Layer**: Riverpod providers and notifiers
3. **Service Layer**: Business logic and API calls
4. **Data Layer**: Firestore, Storage, Local databases

### Key Services
- `FirebaseAuthService`: Authentication
- `FirestoreService`: Database operations
- `NotificationService`: Local notifications
- `FirebaseMessagingService`: Push notifications
- `GeminiService`: AI symptom analysis
- `ElevenLabsService`: Voice generation
- `MedicineService`: Medicine CRUD operations
- `ReminderService`: Reminder management
- `TrackingService`: Medication logging

## Security

### Firestore Rules
- User data is isolated by `userId`
- Read/write access restricted to authenticated users
- Caregiver relationships properly secured

### Storage Rules
- User files protected by authentication
- File size limits enforced (5MB images, 10MB audio)
- Path-based access control

### API Keys
- Stored in Firebase Remote Config (recommended)
- Never committed to version control
- `.env` file in `.gitignore`

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/medicine_service_test.dart

# Run with coverage
flutter test --coverage
```

## Deployment Checklist

### Pre-Deployment
- [ ] All Firestore rules deployed
- [ ] All Firestore indexes deployed
- [ ] Storage rules deployed
- [ ] Cloud Functions deployed
- [ ] Release SHA-1 added to Firebase Console
- [ ] `google-services.json` updated with release SHA-1
- [ ] Keystore password changed from default
- [ ] Keystore backed up securely
- [ ] API keys configured in Remote Config
- [ ] Release build tested thoroughly

### Post-Deployment
- [ ] Monitor Firebase Console for errors
- [ ] Check Crashlytics for crashes
- [ ] Monitor API quota usage
- [ ] Review Analytics data
- [ ] Test push notifications
- [ ] Verify offline functionality

## Troubleshooting

### Common Issues

1. **Google Sign-In fails in release build**
   - Verify release SHA-1 is in Firebase Console
   - Re-download `google-services.json`
   - Clean and rebuild: `flutter clean && flutter build apk --release`

2. **Cloud Functions deployment fails**
   - Ensure billing is enabled on Firebase project
   - Check Node.js version (requires 20+)
   - Verify Firebase CLI is up to date

3. **Offline persistence not working**
   - Check Firestore settings initialization
   - Verify cache size is not limited
   - Test on physical device (emulators may have issues)

4. **Push notifications not received**
   - Verify FCM token is stored in Firestore
   - Check notification permissions
   - Test on physical device

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- Create an issue in the repository
- Check existing documentation
- Review Firebase Console logs

## Acknowledgments

- Firebase for backend infrastructure
- Google Gemini for AI capabilities
- ElevenLabs for voice synthesis
- Flutter team for the amazing framework
