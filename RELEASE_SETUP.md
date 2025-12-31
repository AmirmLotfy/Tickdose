# Release Build Setup - TICKDOSE

## ✅ Completed Setup

All release build configuration has been completed:

1. ✅ **Release Keystore Created**: `android/app/upload-keystore.jks`
2. ✅ **Keystore Properties**: `android/keystore.properties`
3. ✅ **Build Configuration**: Updated `android/app/build.gradle.kts` for release signing
4. ✅ **Release SHA-1**: `dcd383b3ae47cb88052d44b6521191379acbea28`

## 🔐 Keystore Information

**Location**: `android/app/upload-keystore.jks`
**Alias**: `upload`
**Validity**: 10,000 days (~27 years)

**⚠️ IMPORTANT SECURITY NOTES:**
- The keystore password is currently: `tickdose_release_2024`
- **CHANGE THIS PASSWORD** before production deployment!
- Keep the keystore file secure and backed up
- Never commit the keystore file to version control (already in .gitignore)

## 📱 Firebase Console Setup

### Add Release SHA-1 to Firebase Console

1. Go to Firebase Console:
   https://console.firebase.google.com/project/tickdoseapp/settings/general

2. Scroll down to "Your apps" section

3. Click on your Android app (package: `com.tickdose.tickdose`)

4. Click "Add fingerprint" button

5. Add the release SHA-1:
   ```
   dcd383b3ae47cb88052d44b6521191379acbea28
   ```

6. Click "Save"

7. **Re-download google-services.json**:
   - Click "Download google-services.json"
   - Replace the file at `android/app/google-services.json`

### Alternative: Using Firebase CLI

After adding SHA-1 in Console, re-download the config:
```bash
cd /Users/frameless/Desktop/Tickdo
firebase apps:sdkconfig android \
  --package-name=com.tickdose.tickdose \
  --out=android/app/google-services.json
```

## 🏗️ Building Release APK/AAB

### Build Release APK:
```bash
flutter build apk --release
```

### Build Release App Bundle (for Play Store):
```bash
flutter build appbundle --release
```

### Verify Signing:
```bash
cd android
./gradlew signingReport
```

You should see both debug and release SHA-1 fingerprints.

## 🔄 Current Configuration

### Debug SHA-1 (for development):
- `5d07e80397602d316d88f5fea803820ca772aaa4`
- Already configured in Firebase

### Release SHA-1 (for production):
- `dcd383b3ae47cb88052d44b6521191379acbea28`
- ✅ Added to google-services.json (temporary)
- ⚠️ **MUST be added to Firebase Console** (see above)

## 📝 Next Steps

1. **Add Release SHA-1 to Firebase Console** (see instructions above)
2. **Re-download google-services.json** after adding SHA-1
3. **Change keystore password** for security:
   ```bash
   keytool -storepasswd -keystore android/app/upload-keystore.jks
   ```
4. **Backup the keystore** to a secure location
5. **Test release build** before deploying to Play Store

## 🚨 Security Checklist

- [ ] Keystore password changed from default
- [ ] Keystore backed up securely
- [ ] Release SHA-1 added to Firebase Console
- [ ] google-services.json re-downloaded after Firebase update
- [ ] Release build tested successfully
- [ ] Keystore file is NOT in version control (check .gitignore)

## 📞 Support

If you encounter issues:
1. Verify keystore.properties file exists and has correct paths
2. Check that keystore file is in `android/app/upload-keystore.jks`
3. Ensure Firebase Console has both SHA-1 fingerprints
4. Re-download google-services.json after Firebase updates
