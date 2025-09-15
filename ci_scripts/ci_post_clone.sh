#!/bin/bash

set -euo pipefail

echo "=== CI_POST_CLONE.SH STARTED ==="

# Debug: Show current directory and files
echo "Current directory: $(pwd)"
echo "Contents:"
ls -la

# Install CocoaPods
echo "Installing CocoaPods..."
sudo gem install cocoapods

# Find Flutter - Xcode Cloud should have it pre-installed
echo "Finding Flutter..."
FLUTTER_PATH=$(find / -name "flutter" -type f -executable 2>/dev/null | head -1)
if [ -n "$FLUTTER_PATH" ]; then
    export PATH="$(dirname "$FLUTTER_PATH"):$PATH"
    echo "Flutter found at: $FLUTTER_PATH"
else
    echo "ERROR: Flutter not found!"
    exit 1
fi

# Verify Flutter works
echo "Flutter version:"
flutter --version

# Install dependencies
echo "Installing Flutter dependencies..."
flutter pub get

echo "Installing iOS dependencies..."
cd ios
pod install --repo-update
cd ..

echo "=== CI_POST_CLONE.SH COMPLETED ==="