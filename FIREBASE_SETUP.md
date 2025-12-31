# Firebase Setup Guide - TICKDOSE App
**Project ID:** `tickdoseapp`

---

## 📋 Prerequisites

1. **Install Firebase CLI:**
```bash
npm install -g firebase-tools
```

2. **Install FlutterFire CLI:**
```bash
dart pub global activate flutterfire_cli
```

3. **Verify installations:**
```bash
firebase --version
flutterfire --version
```

---

## 🚀 Complete Setup Commands

### Option 1: Automated Script (Recommended)

```bash
cd /Users/frameless/Desktop/Tickdo
./firebase_setup.sh
```

⚠️ **Note:** Edit the script and replace `YOUR_EMAIL@gmail.com` with your actual Google account email.

---

### Option 2: Manual Step-by-Step

#### Step 1: Login to Firebase
```bash
firebase login
```
This will open your browser to authenticate.

#### Step 2: Verify Project Access
```bash
firebase projects:list
```
Ensure you see `tickdoseapp` in the list.

#### Step 3: Set Active Project
```bash
cd /Users/frameless/Desktop/Tickdo
firebase use tickdoseapp
```

#### Step 4: Create Android App
```bash
firebase apps:create android \
  --package-name=com.tickdose.app \
  --display-name="TICKDOSE Android"
```

**Download config after creation:**
```bash
firebase apps:sdkconfig android \
  --package-name=com.tickdose.app \
  --out=android/app/google-services.json
```

#### Step 5: Create iOS App
```bash
firebase apps:create ios \
  --bundle-id=com.tickdose.app \
  --display-name="TICKDOSE iOS"
```

**Download config after creation:**
```bash
firebase apps:sdkconfig ios \
  --bundle-id=com.tickdose.app \
  --out=ios/Runner/GoogleService-Info.plist
```

#### Step 6: Create Web App
```bash
firebase apps:create web \
  --display-name="TICKDOSE Web"
```

#### Step 7: Configure Flutter Apps with FlutterFire
```bash
flutterfire configure \
  --project=tickdoseapp \
  --platforms=android,ios,web \
  --out=lib/firebase_options.dart \
  --yes
```

This will:
- ✅ Auto-detect your Flutter app
- ✅ Generate `firebase_options.dart`
- ✅ Update Android/iOS configurations

#### Step 8: Deploy Security Rules
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes

# Deploy Storage rules
firebase deploy --only storage:rules
```

**Or deploy all at once:**
```bash
firebase deploy --only firestore:rules,firestore:indexes,storage:rules
```

---

## 🔧 Post-Setup Configuration

### Enable Authentication Providers

1. **Go to Firebase Console:**
   https://console.firebase.google.com/project/tickdoseapp/authentication/providers

2. **Enable Email/Password:**
   - Click "Email/Password"
   - Toggle "Enable"
   - Save

3. **Enable Google Sign-In:**
   - Click "Google"
   - Toggle "Enable"
   - Add support email
   - Save

4. **Enable Apple Sign-In (iOS only):**
   - Click "Apple"
   - Toggle "Enable"
   - Follow Apple setup instructions
   - Save

---

## 📥 Download Configuration Files

### Android (`google-services.json`)
```bash
firebase apps:sdkconfig android \
  --package-name=com.tickdose.app \
  --out=android/app/google-services.json
```

**Or download from Console:**
1. Go to Project Settings → Your apps → Android app
2. Click "Download google-services.json"
3. Place in `android/app/`

### iOS (`GoogleService-Info.plist`)
```bash
firebase apps:sdkconfig ios \
  --bundle-id=com.tickdose.app \
  --out=ios/Runner/GoogleService-Info.plist
```

**Or download from Console:**
1. Go to Project Settings → Your apps → iOS app
2. Click "Download GoogleService-Info.plist"
3. Place in `ios/Runner/`

### Web Configuration
Web config is automatically included in `firebase_options.dart` when you run `flutterfire configure`.

---

## ✅ Verify Setup

### Check Firebase Connection:
```bash
firebase projects:list
firebase use
```

### Verify Rules Deployment:
```bash
firebase deploy --only firestore:rules --dry-run
```

### Test in Emulator:
```bash
firebase emulators:start
```

---

## 🔐 Security Checklist

After deployment, verify in Firebase Console:

1. **Firestore Rules:**
   - Go to Firestore → Rules
   - Check "Last deployed" timestamp
   - Verify rules are active

2. **Storage Rules:**
   - Go to Storage → Rules
   - Check "Last deployed" timestamp
   - Verify rules are active

3. **Indexes:**
   - Go to Firestore → Indexes
   - Wait for all indexes to build (can take a few minutes)

---

## 💰 Enable Billing (Required for Production)

1. Go to: https://console.firebase.google.com/project/tickdoseapp/usage
2. Click "Modify plan"
3. Select "Blaze (Pay as you go)"
4. Add payment method
5. Set budget alerts

**Free tier limits:**
- Firestore: 50K reads/day, 20K writes/day
- Storage: 5GB storage, 1GB/day download
- Authentication: Unlimited

---

## 🚨 Common Issues & Solutions

### Issue: "Permission denied"
**Solution:** Make sure you're logged into the correct Google account:
```bash
firebase logout
firebase login --reauth
```

### Issue: "Project not found"
**Solution:** Verify project ID:
```bash
firebase projects:list
firebase use tickdoseapp
```

### Issue: "FlutterFire not found"
**Solution:** Add to PATH:
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### Issue: "Rules deployment failed"
**Solution:** Validate rules syntax:
```bash
firebase deploy --only firestore:rules --dry-run
```

---

## 📱 Platform-Specific Setup

### Android Additional Setup:
1. Update `android/app/build.gradle`:
   - Verify `applicationId "com.tickdose.app"`
   - Ensure google-services plugin is applied

2. Add SHA-1 fingerprint for Google Sign-In:
```bash
cd android
./gradlew signingReport
```
Copy SHA-1 and add in Firebase Console → Project Settings → Your apps → Android

### iOS Additional Setup:
1. Open Xcode workspace: `open ios/Runner.xcworkspace`
2. Verify Bundle Identifier: `com.tickdose.app`
3. Add GoogleService-Info.plist to Xcode project (drag & drop)

---

## 🎯 Final Verification

Run these commands to ensure everything is set up:

```bash
# 1. Check Flutter Firebase integration
flutter pub get

# 2. Run on Android
flutter run -d android

# 3. Run on iOS
flutter run -d ios

# 4. Check for Firebase errors in logs
flutter logs
```

---

## 📚 Useful Commands Reference

```bash
# List all Firebase projects
firebase projects:list

# List apps in current project
firebase apps:list

# Check current project
firebase use

# Switch project
firebase use tickdoseapp

# Deploy specific service
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
firebase deploy --only firestore:indexes

# Deploy all
firebase deploy

# Start emulators for local testing
firebase emulators:start

# View Firebase logs
firebase functions:log
```

---

**🎉 Setup Complete!**

Your TICKDOSE app is now connected to Firebase project `tickdoseapp` with:
- ✅ Android app configured
- ✅ iOS app configured
- ✅ Web app configured
- ✅ Security rules deployed
- ✅ Indexes deployed
- ✅ Ready for production!
