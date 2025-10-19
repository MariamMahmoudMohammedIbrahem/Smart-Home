#!/bin/bash

set -euo pipefail

echo "=== CI_POST_CLONE.SH STARTED ==="

# Debug: Show current directory and files
echo "Current directory: $(pwd)"
echo "Contents:"
ls -la

# Check for CocoaPods
echo "Checking CocoaPods..."
if ! command -v pod &> /dev/null; then
    echo "CocoaPods not found!"
    # Optional fallback (not usually needed in Xcode Cloud)
    # echo "Installing CocoaPods..."
    # gem install --user-install cocoapods
else
    echo "CocoaPods version: $(pod --version)"
fi

# Find Flutter - if not on PATH, try to locate
echo "Checking for Flutter..."
if ! command -v flutter &> /dev/null; then
    FLUTTER_PATH=$(find / -name "flutter" -type f -executable 2>/dev/null | head -1)
    if [ -n "$FLUTTER_PATH" ]; then
        export PATH="$(dirname "$FLUTTER_PATH"):$PATH"
        echo "Flutter found at: $FLUTTER_PATH"
    else
        echo "ERROR: Flutter not found!"
        exit 1
    fi
fi

# Verify Flutter
echo "Flutter version:"
flutter --version

# Install dependencies
echo "Running flutter pub get..."
flutter pub get

# iOS dependencies
echo "Running pod install..."
cd ios || {
    echo "ERROR: Failed to enter ios directory"
    exit 1
}
pod install --repo-update
cd ..

echo "=== CI_POST_CLONE.SH COMPLETED ==="
