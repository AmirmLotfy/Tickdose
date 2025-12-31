# Rebuild Instructions After google-services.json Update

## ✅ Do You Need to Rebuild?

**YES** - You should rebuild after updating `google-services.json` because:

1. **Google Services Plugin** processes `google-services.json` at build time
2. **OAuth Client IDs** are embedded in the app during compilation
3. **Runtime Configuration** - The app needs the updated client IDs for Google Sign-In to work

## 🔄 Rebuild Options

### Option 1: Clean Build (Recommended)
This ensures all cached files are cleared and the new configuration is fully applied:

```bash
# Clean previous builds
flutter clean

# Rebuild release APK
flutter build apk --release

# OR rebuild release App Bundle
flutter build appbundle --release
```

### Option 2: Standard Rebuild (Faster)
If you just want to rebuild without cleaning:

```bash
# Rebuild release APK
flutter build apk --release

# OR rebuild release App Bundle
flutter build appbundle --release
```

### Option 3: Debug Build (For Testing)
To test the changes in debug mode:

```bash
flutter run --release
```

## 📋 Current Configuration Status

✅ **Both SHA-1 fingerprints are configured:**
- Debug SHA-1: `5d07e80397602d316d88f5fea803820ca772aaa4`
- Release SHA-1: `dcd383b3ae47cb88052d44b6521191379acbea28`

✅ **OAuth Client IDs:**
- Debug: `664338606340-c79u992uf6fi4ee9b7ps7vlm31kes6h8`
- Release: `664338606340-chib84b2kldc6u967o43n37is8a2ueu7`

## ⚠️ Important Notes

1. **Clean Build Recommended**: Since you changed the OAuth client configuration, a clean build ensures everything is properly updated
2. **Test Google Sign-In**: After rebuilding, test Google Sign-In to ensure it works with the new configuration
3. **Release vs Debug**: Make sure to test both debug and release builds if you're using both

## 🧪 Verification

After rebuilding, verify the configuration:

```bash
# Check that the build completed successfully
# Then test Google Sign-In in the app
```

## 🚀 Quick Rebuild Command

```bash
flutter clean && flutter build apk --release
```

This will:
1. Clean all previous build artifacts
2. Rebuild with the updated google-services.json
3. Create a new release APK with the correct OAuth client IDs
