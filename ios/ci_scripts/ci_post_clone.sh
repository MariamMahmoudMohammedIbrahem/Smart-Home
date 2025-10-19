#!/bin/bash

set -euo pipefail

echo "=== CI_POST_CLONE.SH STARTED ==="

# Debug
echo "Current directory: $(pwd)"
echo "Contents:"
ls -la

# CocoaPods
echo "Checking CocoaPods..."
if ! command -v pod &> /dev/null; then
    echo "CocoaPods not found!"
else
    echo "CocoaPods version: $(pod --version)"
fi

# Find Flutter
echo "Checking for Flutter..."

export PATH="/opt/homebrew/bin:/opt/homebrew/flutter/bin:$PATH"

if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter still not found in PATH!"
    exit 1
fi

# Verify Flutter
echo "Flutter version:"
which flutter
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
