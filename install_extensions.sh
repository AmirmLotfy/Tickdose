#!/bin/bash
# Automated Firebase Extensions Installer for Tickdo

echo "🔥 Installing Firebase Extensions for Tickdo..."
echo ""

echo "📦 Step 1: Install Delete User Data Extension"
echo "   This removes all user data when they delete their account."
echo ""
firebase ext:install firebase/delete-user-data

echo ""
echo "📦 Step 2: Install Resize Images Extension"
echo "   This creates 200x200 thumbnails for medicine photos."
echo ""
firebase ext:install firebase/storage-resize-images

echo ""
echo "✅ Installation complete!"
echo "   Extensions are now active in your Firebase project."
