#!/bin/bash

# Build script for Blinks macOS app
# This script will open the project in Xcode

echo "🚀 Opening Blinks project in Xcode..."
echo ""
echo "📋 Build Instructions:"
echo "1. Xcode will open the project"
echo "2. Select 'Blinks' scheme at the top"
echo "3. Press Cmd+R to build and run"
echo "4. The app will appear in your menu bar (look for the eye icon 👁️)"
echo ""
echo "⚙️  To create a distributable app:"
echo "1. In Xcode, select Product > Archive"
echo "2. Click 'Distribute App'"
echo "3. Choose 'Copy App' to save the .app bundle"
echo ""

# Open the project in Xcode
open Blinks.xcodeproj

echo "✅ Project opened in Xcode!"
