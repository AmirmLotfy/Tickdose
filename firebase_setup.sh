#!/bin/bash

# TICKDOSE Firebase Setup & Deployment Script
# Project ID: tickdoseapp

echo "🚀 Starting TICKDOSE Firebase Setup..."
echo ""

# Step 1: Login to Firebase
echo "Step 1: Logging into Firebase..."
firebase login

# Step 2: List projects to verify
echo ""
echo "Step 2: Verifying project access..."
firebase projects:list

# Step 3: Set active project
echo ""
echo "Step 3: Setting active project to tickdoseapp..."
firebase use tickdoseapp

# Step 4: Create Android app
echo ""
echo "Step 4: Creating Android app..."
firebase apps:create android \
  --package-name=com.tickdose.app \
  --display-name="TICKDOSE Android"

# Step 5: Create iOS app
echo ""
echo "Step 5: Creating iOS app..."
firebase apps:create ios \
  --bundle-id=com.tickdose.app \
  --display-name="TICKDOSE iOS"

# Step 6: Create Web app
echo ""
echo "Step 6: Creating Web app..."
firebase apps:create web \
  --display-name="TICKDOSE Web"

# Step 7: Download all app configurations
echo ""
echo "Step 7: Configuring Flutter with FlutterFire..."
flutterfire configure \
  --project=tickdoseapp \
  --account=YOUR_EMAIL@gmail.com \
  --platforms=android,ios,web \
  --out=lib/firebase_options.dart \
  --yes

# Step 8: Deploy Firestore rules
echo ""
echo "Step 8: Deploying Firestore security rules..."
firebase deploy --only firestore:rules

# Step 9: Deploy Firestore indexes
echo ""
echo "Step 9: Deploying Firestore indexes..."
firebase deploy --only firestore:indexes

# Step 10: Deploy Storage rules
echo ""
echo "Step 10: Deploying Storage security rules..."
firebase deploy --only storage:rules

# Step 11: Verify deployment
echo ""
echo "Step 11: Verifying deployment..."
firebase deploy --only firestore:rules,storage:rules,firestore:indexes --dry-run

echo ""
echo "✅ Firebase setup complete!"
echo ""
echo "📱 Next steps:"
echo "1. Download google-services.json for Android from Firebase Console"
echo "2. Download GoogleService-Info.plist for iOS from Firebase Console"
echo "3. Enable Authentication providers (Email, Google, Apple)"
echo "4. Set up billing in Firebase Console"
echo ""
