#!/bin/bash

# Configuration
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
ROBO_SCRIPT="robo_script.json"
EMAILS="mobishopy@gmail.com"
PW="112233//Al.com"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed."
    echo "Please install it: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo "❌ Error: APK not found at $APK_PATH"
    echo "Please run: flutter build apk --debug"
    exit 1
fi

echo "🚀 Starting Firebase Robo Test..."
echo "📱 APK: $APK_PATH"
echo "📜 Script: $ROBO_SCRIPT"

# Run the test
# We use robo-directives to inject the text as well, as a fallback/reinforcement
gcloud firebase test android run \
  --app "$APK_PATH" \
  --robo-script "$ROBO_SCRIPT" \
  --client-details matrix-label="Manual-Robo-Run"

echo "✅ Test command submitted! Check the URL above for results."
