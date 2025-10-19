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

# Try known paths where Flutter may exist on Xcode Cloud
FLUTTER_PATHS=(
  "/opt/homebrew/bin/flutter"
  "/usr/local/bin/flutter"
  "$HOME/flutter/bin/flutter"
)

for path in "${FLUTTER_PATHS[@]}"; do
  if [ -x "$path" ]; then
    echo "Found Flutter at $path"
    export PATH="$(dirname "$path"):$PATH"
    break
  fi
done

# Confirm flutter is now available
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found in any known location!"
    exit 1
fi

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
