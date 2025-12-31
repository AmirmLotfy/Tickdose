# Manual Setup Guide - Step by Step

This guide covers all manual steps required to complete the production setup.

---

## Step 1: Add Release SHA-1 to Firebase Console

### Why?
Firebase requires your app's SHA-1 fingerprint for Google Sign-In and other services to work in release builds.

### Steps:

#### 1.1 Generate Release Keystore (if you don't have one)

```bash
cd /Users/frameless/Desktop/Tickdo/android/app
keytool -genkey -v -keystore release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
```

**When prompted:**
- **Password**: Choose a strong password (save it securely!)
- **Name**: Your name or company name
- **Organizational Unit**: Your department (optional)
- **Organization**: Your company name
- **City**: Your city
- **State**: Your state/province
- **Country**: Two-letter country code (e.g., US, GB, EG)

#### 1.2 Get SHA-1 Fingerprint

**For Release Keystore:**
```bash
keytool -list -v -keystore android/app/release.keystore -alias release
```

**For Debug Keystore (if needed):**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**You'll see output like:**
```
Certificate fingerprints:
     SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
     SHA256: ...
```

**Copy the SHA-1 value** (the long string after "SHA1:")

#### 1.3 Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **tickdoseapp**
3. Click the **⚙️ Settings** icon (gear) next to "Project Overview"
4. Select **Project settings**
5. Scroll down to **Your apps** section
6. Find your **Android app** (package name: `com.tickdose.app` or similar)
7. Click **Add fingerprint** button
8. Paste your **SHA-1** fingerprint
9. Click **Save**

**Repeat for both debug and release SHA-1 fingerprints if you want to test both builds.**

---

## Step 2: Re-download google-services.json

### Why?
The `google-services.json` file needs to be updated after adding SHA-1 fingerprints.

### Steps:

1. In Firebase Console, go to **Project settings** (same as Step 1.3)
2. Scroll to **Your apps** section
3. Find your **Android app**
4. Click **Download google-services.json**
5. **Replace** the existing file:
   ```bash
   # Backup old file (optional)
   cp android/app/google-services.json android/app/google-services.json.backup
   
   # Replace with new file
   # (Copy the downloaded file to android/app/google-services.json)
   ```

**Verify the file location:**
- ✅ `android/app/google-services.json` (correct)
- ❌ `android/google-services.json` (wrong location)

---

## Step 3: Change Keystore Password

### Why?
Security best practice - never use default passwords in production.

### Steps:

#### 3.1 Change Keystore Password

```bash
cd /Users/frameless/Desktop/Tickdo/android/app
keytool -storepasswd -keystore release.keystore
```

**When prompted:**
- **Current password**: Enter your current keystore password
- **New password**: Enter a strong new password
- **Re-enter new password**: Confirm the new password

#### 3.2 Update key.properties File

Create or update `android/key.properties`:

```properties
storePassword=YOUR_NEW_KEYSTORE_PASSWORD
keyPassword=YOUR_NEW_KEY_PASSWORD
keyAlias=release
storeFile=app/release.keystore
```

**⚠️ IMPORTANT:** 
- **Never commit this file to Git!**
- Add `android/key.properties` to `.gitignore`
- Store the password securely (password manager, secure notes, etc.)

#### 3.3 Verify .gitignore

Check that `android/key.properties` is in `.gitignore`:

```bash
cat .gitignore | grep key.properties
```

If not found, add it:
```bash
echo "android/key.properties" >> .gitignore
```

#### 3.4 Backup Keystore Securely

**⚠️ CRITICAL:** If you lose your keystore, you **cannot** update your app on Google Play Store!

```bash
# Create a secure backup location (outside the project)
mkdir -p ~/secure-backups/tickdose
cp android/app/release.keystore ~/secure-backups/tickdose/release.keystore

# Also backup key.properties (encrypted if possible)
cp android/key.properties ~/secure-backups/tickdose/key.properties
```

**Store backups in:**
- Encrypted cloud storage (Google Drive, Dropbox with encryption)
- Password manager (1Password, LastPass secure notes)
- Physical secure storage (encrypted USB drive)

---

## Step 4: Configure Firebase Remote Config

### Why?
The app needs API keys for Gemini AI and ElevenLabs services, stored securely in Remote Config.

### Steps:

#### 4.1 Get API Keys

**Gemini API Key:**
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click **Create API Key**
4. Select your project or create a new one
5. **Copy the API key** (starts with `AIza...`)

**ElevenLabs API Key (Optional - for voice features):**
1. Go to [ElevenLabs](https://elevenlabs.io/)
2. Sign up or log in
3. Go to **Profile** → **API Keys**
4. Click **Create API Key**
5. **Copy the API key**

#### 4.2 Add to Firebase Remote Config

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **tickdoseapp**
3. In the left sidebar, click **Remote Config** (under **Engage**)
4. If you see "Get started", click it
5. Click **Add parameter** button

**Add GEMINI_API_KEY:**
- **Parameter key**: `GEMINI_API_KEY`
- **Default value**: Paste your Gemini API key
- Click **Save**

**Add ELEVENLABS_API_KEY (Optional):**
- **Parameter key**: `ELEVENLABS_API_KEY`
- **Default value**: Paste your ElevenLabs API key (or leave empty if not using)
- Click **Save**

6. Click **Publish changes** button at the top

**Verify:**
- Both parameters should appear in the list
- Status should show "Published"

---

## Step 5: Test Release Build

### Why?
Ensure the app works correctly in release mode before publishing.

### Steps:

#### 5.1 Build Release APK

```bash
cd /Users/frameless/Desktop/Tickdo

# Clean build
flutter clean
flutter pub get

# Build release APK
flutter build apk --release
```

**Output location:** `build/app/outputs/flutter-apk/app-release.apk`

#### 5.2 Build Release App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

**Output location:** `build/app/outputs/bundle/release/app-release.aab`

#### 5.3 Install and Test

**Option A: Install on Connected Device**
```bash
# Connect Android device via USB
# Enable USB debugging on device
flutter install --release
```

**Option B: Install APK Manually**
1. Transfer `app-release.apk` to your Android device
2. On device: Settings → Security → Enable "Install from unknown sources"
3. Open the APK file and install

#### 5.4 Test Checklist

**Authentication:**
- [ ] Email/Password sign up works
- [ ] Email/Password login works
- [ ] Google Sign-In works
- [ ] Apple Sign-In works (iOS only)
- [ ] Logout works

**Core Features:**
- [ ] Add medicine works
- [ ] Edit medicine works
- [ ] Delete medicine works
- [ ] Add reminder works
- [ ] Reminder notifications appear
- [ ] Mark medicine as taken works
- [ ] Mark medicine as skipped works
- [ ] Tracking screen shows data
- [ ] Adherence calculation works

**Advanced Features:**
- [ ] "I Feel" symptom checker works (Gemini API)
- [ ] Voice recording works (if using ElevenLabs)
- [ ] Caregiver invitation works
- [ ] Caregiver notifications work
- [ ] Account deletion works

**Performance:**
- [ ] App starts quickly
- [ ] No crashes
- [ ] Smooth scrolling
- [ ] Images load correctly
- [ ] Offline mode works (after initial load)

**Security:**
- [ ] No API keys visible in APK (check with `strings app-release.apk | grep -i "api\|key"`)
- [ ] ProGuard obfuscation working (check APK size is reasonable)

---

## Step 6: iOS Capabilities Configuration

### Why?
iOS requires specific capabilities to be enabled in Xcode for features like push notifications, Sign in with Apple, etc.

### Steps:

#### 6.1 Open Project in Xcode

```bash
cd /Users/frameless/Desktop/Tickdo
open ios/Runner.xcworkspace
```

**⚠️ Important:** Open `.xcworkspace`, NOT `.xcodeproj`!

#### 6.2 Select Runner Target

1. In Xcode, click **Runner** in the left sidebar (under "TARGETS")
2. Click **Signing & Capabilities** tab

#### 6.3 Configure Signing

1. **Team**: Select your Apple Developer team
2. **Bundle Identifier**: Should be `com.tickdose.app` (or your custom bundle ID)
3. **Automatically manage signing**: ✅ Check this box

#### 6.4 Add Capabilities

Click **+ Capability** button and add:

**1. Push Notifications**
- Click **+ Capability** → Search "Push Notifications" → Add
- ✅ Should show "Push Notifications" enabled

**2. Sign in with Apple**
- Click **+ Capability** → Search "Sign in with Apple" → Add
- ✅ Should show "Sign in with Apple" enabled

**3. Background Modes**
- Click **+ Capability** → Search "Background Modes" → Add
- ✅ Check "Remote notifications"
- ✅ Check "Background fetch" (optional)

**4. Associated Domains** (for deep linking)
- Click **+ Capability** → Search "Associated Domains" → Add
- Click **+** to add domain
- Enter: `applinks:yourdomain.com` (replace with your actual domain)
- Or use Firebase App Links: `applinks:YOUR_PROJECT_ID.page.link`

#### 6.5 Configure Info.plist

1. In Xcode, open `ios/Runner/Info.plist`
2. Verify these entries exist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.tickdose.app</string>
        </array>
    </dict>
</array>
```

#### 6.6 Download GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **tickdoseapp**
3. Go to **Project settings**
4. Find your **iOS app**
5. Click **Download GoogleService-Info.plist**
6. **Replace** the file at: `ios/Runner/GoogleService-Info.plist`

#### 6.7 Configure App Transport Security (if needed)

If you're using custom domains, add to `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>yourdomain.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
        </dict>
    </dict>
</dict>
```

#### 6.8 Build and Test iOS

```bash
# Build iOS release
flutter build ios --release

# Or run on simulator
flutter run --release
```

**Test Checklist (iOS):**
- [ ] App builds without errors
- [ ] Push notifications work
- [ ] Sign in with Apple works
- [ ] Deep linking works
- [ ] All features work as on Android

---

## Step 7: Final Verification

### Checklist Before Publishing

**Android:**
- [ ] Release APK builds successfully
- [ ] Release App Bundle builds successfully
- [ ] All features tested in release mode
- [ ] SHA-1 added to Firebase
- [ ] `google-services.json` updated
- [ ] Keystore password changed
- [ ] Keystore backed up securely
- [ ] Remote Config configured with API keys

**iOS:**
- [ ] App builds in Xcode
- [ ] All capabilities configured
- [ ] `GoogleService-Info.plist` updated
- [ ] Sign in with Apple works
- [ ] Push notifications work
- [ ] App Store Connect configured (if publishing)

**General:**
- [ ] All Cloud Functions deployed
- [ ] Firestore rules deployed
- [ ] Storage rules deployed
- [ ] No API keys in code (all in Remote Config)
- [ ] Error tracking working (Crashlytics)
- [ ] Analytics enabled
- [ ] Performance monitoring enabled

---

## Troubleshooting

### Issue: "SHA-1 not found" error
**Solution:** Make sure you added the SHA-1 to Firebase Console and re-downloaded `google-services.json`

### Issue: "Keystore password incorrect"
**Solution:** Check `android/key.properties` has the correct password

### Issue: "Remote Config not working"
**Solution:** 
1. Verify parameters are published in Firebase Console
2. Check parameter keys match exactly: `GEMINI_API_KEY` (case-sensitive)
3. Ensure app has internet connection

### Issue: "iOS build fails"
**Solution:**
1. Run `pod install` in `ios/` directory
2. Clean build: `flutter clean && flutter pub get`
3. Open `.xcworkspace` not `.xcodeproj`

### Issue: "Push notifications not working"
**Solution:**
1. Verify APNs certificate uploaded to Firebase Console
2. Check capabilities enabled in Xcode
3. Test on real device (not simulator)

---

## Support

If you encounter issues:
1. Check Firebase Console logs
2. Check Crashlytics for errors
3. Review `README.md` for setup details
4. Review `IOS_CONFIGURATION_AUDIT.md` for iOS-specific issues

---

**Last Updated:** $(date)
**Project:** Tickdo
**Status:** Production Ready ✅
