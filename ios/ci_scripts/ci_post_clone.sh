#!/bin/bash

set -euo pipefail

echo "=== CI_POST_CLONE.SH STARTED ==="

# Define Flutter SDK directory
FLUTTER_DIR="$HOME/flutter"
export FLUTTER_ROOT="$FLUTTER_DIR"

# Add Flutter to PATH
export PATH="$FLUTTER_DIR/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

echo "PATH = $PATH"
echo "CI_PRIMARY_REPOSITORY_PATH = ${CI_PRIMARY_REPOSITORY_PATH:-Not set}"
echo "FLUTTER_ROOT = $FLUTTER_ROOT"

# Install Flutter SDK if not found
if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Flutter SDK not found, installing..."
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
else
  echo "Flutter SDK found at $FLUTTER_DIR"
fi

# Verify Flutter installation
flutter --version

# Get dependencies
flutter pub get

# Check CocoaPods
echo "Checking CocoaPods..."
pod --version

# Run pod install
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
echo "Running pod install..."
pod install --repo-update
cd ..

echo "=== CI_POST_CLONE.SH COMPLETED ==="
