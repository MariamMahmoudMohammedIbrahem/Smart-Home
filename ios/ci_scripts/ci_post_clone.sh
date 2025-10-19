#!/bin/bash

set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/Users/eoip/flutter/bin:$PATH"
echo "=== CI_POST_CLONE.SH STARTED ==="
echo "Current working directory: $(pwd)"
echo "PATH = $PATH"
echo "CI_PRIMARY_REPOSITORY_PATH = ${CI_PRIMARY_REPOSITORY_PATH:-Not set}"

# Flutter SDK directory
FLUTTER_DIR="$HOME/flutter"

# Check if Flutter SDK is installed
if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Flutter SDK not found, installing..."
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
else
  echo "Flutter SDK found at $FLUTTER_DIR"
fi

# Add Flutter to PATH
export PATH="$FLUTTER_DIR/bin:$PATH"

# Verify Flutter installation
if ! command -v flutter &> /dev/null; then
  echo "ERROR: Flutter command not found even after installation."
  exit 1
fi

echo "Flutter version:"
flutter --version

# Check CocoaPods
echo "Checking CocoaPods..."
if ! command -v pod &> /dev/null; then
  echo "ERROR: CocoaPods (pod) command not found!"
  exit 1
else
  echo "CocoaPods version: $(pod --version)"
fi

echo "Running flutter pub get..."
flutter pub get

echo "Running pod install..."
cd "$CI_PRIMARY_REPOSITORY_PATH/ios" || { echo "ERROR: Failed to enter ios directory"; exit 1; }
pod install --repo-update
cd ..

echo "=== CI_POST_CLONE.SH COMPLETED ==="
