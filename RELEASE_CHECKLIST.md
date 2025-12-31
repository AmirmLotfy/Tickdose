# ✅ Release Build Setup - COMPLETE

## 🎉 All Release Configuration Completed!

### Files Created/Modified:

1. ✅ **Release Keystore**: `android/app/upload-keystore.jks`
   - Alias: `upload`
   - Validity: 10,000 days
   - Password: `tickdose_release_2024` (⚠️ CHANGE THIS!)

2. ✅ **Keystore Properties**: `android/keystore.properties`
   - Contains keystore configuration
   - ⚠️ Already in .gitignore (won't be committed)

3. ✅ **Build Configuration**: `android/app/build.gradle.kts`
   - Release signing configured
   - Automatically uses release keystore when available

4. ✅ **Google Services**: `android/app/google-services.json`
   - Release SHA-1 added (temporary)
   - Contains both debug and release SHA-1

5. ✅ **Git Ignore**: Updated `.gitignore`
   - Keystore files excluded from version control

## 📋 SHA-1 Fingerprints

### Debug SHA-1 (Development):
```
5d07e80397602d316d88f5fea803820ca772aaa4
```
✅ Already in Firebase Console

### Release SHA-1 (Production):
```
dcd383b3ae47cb88052d44b6521191379acbea28
```
✅ Added to google-services.json
⚠️ **MUST be added to Firebase Console** (see below)

## 🔥 Firebase Console - REQUIRED ACTION

**You MUST add the release SHA-1 to Firebase Console:**

1. Visit: https://console.firebase.google.com/project/tickdoseapp/settings/general
2. Find your Android app (`com.tickdose.tickdose`)
3. Click "Add fingerprint"
4. Paste: `dcd383b3ae47cb88052d44b6521191379acbea28`
5. Click "Save"
6. **Re-download** `google-services.json` and replace the file

**Or use Firebase CLI:**
```bash
firebase apps:sdkconfig android \
  --package-name=com.tickdose.tickdose \
  --out=android/app/google-services.json
```

## 🏗️ Build Commands

### Build Release APK:
```bash
flutter build apk --release
```

### Build Release App Bundle (Play Store):
```bash
flutter build appbundle --release
```

### Verify Signing:
```bash
cd android
./gradlew signingReport
```

## 🔐 Security Actions Required

1. **Change Keystore Password:**
   ```bash
   keytool -storepasswd -keystore android/app/upload-keystore.jks
   ```
   Then update `android/keystore.properties`

2. **Backup Keystore:**
   - Copy `android/app/upload-keystore.jks` to secure location
   - Store password securely (password manager)
   - **Losing this keystore = cannot update app on Play Store!**

3. **Update keystore.properties** after password change:
   ```properties
   storePassword=YOUR_NEW_PASSWORD
   keyPassword=YOUR_NEW_PASSWORD
   keyAlias=upload
   storeFile=app/upload-keystore.jks
   ```

## ✅ Verification Checklist

- [x] Release keystore created
- [x] Keystore properties configured
- [x] Build.gradle.kts updated
- [x] Release SHA-1 added to google-services.json
- [x] .gitignore updated
- [ ] **Release SHA-1 added to Firebase Console** ⚠️
- [ ] **google-services.json re-downloaded from Firebase** ⚠️
- [ ] Keystore password changed
- [ ] Keystore backed up securely
- [ ] Release build tested

## 📝 Next Steps

1. **Add release SHA-1 to Firebase Console** (critical!)
2. **Re-download google-services.json**
3. **Change keystore password**
4. **Backup keystore securely**
5. **Test release build**: `flutter build apk --release`
6. **Verify Google Sign-In works** with release build

## 🚨 Important Notes

- The keystore file is **NEVER** committed to git (in .gitignore)
- The keystore.properties file is **NEVER** committed (in .gitignore)
- **Keep the keystore safe** - you'll need it for all future app updates
- The current password is temporary - **change it before production!**

## 📞 Troubleshooting

If Google Sign-In fails in release build:
1. Verify release SHA-1 is in Firebase Console
2. Re-download google-services.json
3. Clean and rebuild: `flutter clean && flutter build apk --release`
4. Check signing: `cd android && ./gradlew signingReport`

---

**Setup completed on**: $(date)
**Release SHA-1**: `dcd383b3ae47cb88052d44b6521191379acbea28`
