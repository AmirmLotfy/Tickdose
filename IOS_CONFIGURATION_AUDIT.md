# iOS Configuration Audit and Setup Guide

## Current Status

### ✅ Already Configured

1. **Deep Linking**
   - Custom URL scheme: `tickdose://` configured in Info.plist
   - Associated Domains: `applinks:tickdose.app` configured
   - Location: `ios/Runner/Info.plist` lines 60-76

2. **Push Notifications**
   - Background modes: `audio` and `processing` enabled
   - Location: `ios/Runner/Info.plist` lines 77-81
   - Firebase Messaging configured via `GoogleService-Info.plist`

3. **Permissions**
   - Location: `NSLocationWhenInUseUsageDescription`
   - Camera: `NSCameraUsageDescription`
   - Photo Library: `NSPhotoLibraryUsageDescription`
   - Speech Recognition: `NSSpeechRecognitionUsageDescription`
   - Microphone: `NSMicrophoneUsageDescription`
   - All configured in `ios/Runner/Info.plist`

4. **Firebase Integration**
   - `GoogleService-Info.plist` present
   - Firebase SDK integrated

## ⚠️ Required Manual Configuration

### 1. Apple Sign-In Capability

**Status**: Not configured in Xcode project

**Steps to Configure**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the `Runner` target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "Sign in with Apple"
6. Ensure your Apple Developer account has Sign in with Apple enabled

**Verification**:
- Check that `Runner.entitlements` file exists with:
  ```xml
  <key>com.apple.developer.applesignin</key>
  <array>
    <string>Default</string>
  </array>
  ```

### 2. Push Notifications Capability

**Status**: Partially configured (Info.plist has background modes, but capability may not be added)

**Steps to Configure**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the `Runner` target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "Push Notifications"
6. Upload APNs certificate to Firebase Console:
   - Go to Firebase Console → Project Settings → Cloud Messaging
   - Upload APNs Authentication Key or Certificate

**APNs Certificate Setup**:
- Option 1 (Recommended): APNs Authentication Key
  - Create in Apple Developer Portal → Keys
  - Download `.p8` file
  - Upload to Firebase Console
- Option 2: APNs Certificate
  - Create in Apple Developer Portal → Certificates
  - Download certificate
  - Upload to Firebase Console

### 3. Background Modes Verification

**Status**: Configured in Info.plist

**Verify in Xcode**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the `Runner` target
3. Go to "Signing & Capabilities" tab
4. Ensure "Background Modes" capability is added
5. Verify these modes are checked:
   - ✅ Audio, AirPlay, and Picture in Picture
   - ✅ Background processing

### 4. Associated Domains Configuration

**Status**: Configured in Info.plist

**Verify in Xcode**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the `Runner` target
3. Go to "Signing & Capabilities" tab
4. Ensure "Associated Domains" capability is added
5. Verify domain: `applinks:tickdose.app`

**Apple App Site Association File**:
- Must be hosted at: `https://tickdose.app/.well-known/apple-app-site-association`
- Content-Type: `application/json`
- Example content:
  ```json
  {
    "applinks": {
      "apps": [],
      "details": [
        {
          "appID": "TEAM_ID.com.tickdose.tickdose",
          "paths": ["/invite*"]
        }
      ]
    }
  }
  ```

### 5. App Transport Security

**Status**: Should be configured for API calls

**Check Info.plist**:
- Ensure no ATS exceptions needed (all APIs should use HTTPS)
- If needed, add exceptions in `ios/Runner/Info.plist`:
  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
  </dict>
  ```

### 6. Info.plist Verification Checklist

- [x] Bundle Identifier matches Firebase configuration
- [x] Display Name: "Tickdose"
- [x] URL Schemes: `tickdose://`
- [x] Associated Domains: `applinks:tickdose.app`
- [x] Background Modes: `audio`, `processing`
- [x] All permission descriptions present
- [ ] Launch Screen configured
- [ ] App Icons configured

### 7. Xcode Project Settings

**Required Settings**:
- Deployment Target: iOS 13.0+ (for Apple Sign-In)
- Swift Version: 5.0+
- Build Configuration: Debug and Release

**Verify**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select `Runner` project → `Runner` target
3. Check "General" tab:
   - Minimum Deployments: iOS 13.0
   - Swift Language Version: Swift 5

### 8. Firebase iOS Configuration

**Required**:
- [x] `GoogleService-Info.plist` present
- [ ] APNs certificate/key uploaded to Firebase Console
- [ ] Bundle ID matches Firebase project
- [ ] App registered in Firebase Console

**Verify**:
1. Go to Firebase Console → Project Settings
2. Check iOS app configuration
3. Verify Bundle ID: `com.tickdose.tickdose` (or your bundle ID)
4. Upload APNs certificate if not done

### 9. Code Signing

**Required**:
- Development team selected in Xcode
- Provisioning profile configured
- Signing certificate valid

**Verify**:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select `Runner` target → "Signing & Capabilities"
3. Ensure "Automatically manage signing" is checked OR
4. Manual signing with valid provisioning profile

### 10. App Store Connect Configuration

**For App Store Submission**:
- [ ] App created in App Store Connect
- [ ] Bundle ID registered
- [ ] App Store metadata prepared
- [ ] Privacy policy URL configured
- [ ] App Store screenshots prepared

## Testing Checklist

### Apple Sign-In
- [ ] Test Sign in with Apple on physical iOS device (iOS 13+)
- [ ] Verify user profile creation after Apple Sign-In
- [ ] Test sign-out functionality

### Push Notifications
- [ ] Test FCM token registration
- [ ] Test foreground notifications
- [ ] Test background notifications
- [ ] Test notification tap handling
- [ ] Test on physical device (simulator has limitations)

### Deep Linking
- [ ] Test custom URL scheme: `tickdose://invite?token=...`
- [ ] Test universal links: `https://tickdose.app/invite?token=...`
- [ ] Verify navigation to invitation screen
- [ ] Test when app is closed, in background, and foreground

### Background Audio
- [ ] Test voice reminders in background
- [ ] Verify audio continues when app is backgrounded
- [ ] Test with device locked

### Permissions
- [ ] Test location permission request
- [ ] Test camera permission request
- [ ] Test photo library permission request
- [ ] Test microphone permission request
- [ ] Test speech recognition permission request

## Common Issues and Solutions

### Issue: Apple Sign-In not working
**Solution**:
- Verify capability is added in Xcode
- Check Bundle ID matches Firebase configuration
- Ensure iOS 13+ deployment target
- Test on physical device (simulator may have issues)

### Issue: Push notifications not received
**Solution**:
- Verify APNs certificate uploaded to Firebase
- Check Push Notifications capability added
- Verify FCM token is stored in Firestore
- Test on physical device
- Check notification permissions granted

### Issue: Deep links not working
**Solution**:
- Verify Associated Domains capability added
- Check `apple-app-site-association` file is accessible
- Verify URL scheme in Info.plist
- Test on physical device (simulator has limitations)

### Issue: Background audio stops
**Solution**:
- Verify Background Modes capability with Audio enabled
- Check `UIBackgroundModes` in Info.plist
- Ensure audio session configured properly
- Test on physical device

## Next Steps

1. **Open Xcode and verify all capabilities**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Add missing capabilities** (Sign in with Apple, Push Notifications)

3. **Upload APNs certificate to Firebase Console**

4. **Test on physical iOS device** (simulator has limitations)

5. **Configure App Store Connect** (if submitting to App Store)

## Notes

- Most iOS-specific configurations must be done in Xcode
- Some features (like Apple Sign-In) require physical device testing
- APNs certificate must be uploaded to Firebase for push notifications
- Universal links require hosting `apple-app-site-association` file on your domain
