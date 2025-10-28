#!/bin/bash
set -euo pipefail

echo "=== CI_POST_CLONE.SH STARTED ==="

# Setup Flutter environment
FLUTTER_DIR="$HOME/flutter"
export FLUTTER_ROOT="$FLUTTER_DIR"
export PATH="$FLUTTER_DIR/bin:$PATH"

echo "PATH = $PATH"
echo "FLUTTER_ROOT = $FLUTTER_ROOT"
echo "CI_PRIMARY_REPOSITORY_PATH = ${CI_PRIMARY_REPOSITORY_PATH:-Not set}"

# Install Flutter SDK if missing
if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Flutter SDK not found, cloning stable branch..."
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
else
  echo "Flutter SDK already present at $FLUTTER_DIR"
fi

# Verify Flutter installation
flutter --version

# Precache Flutter iOS artifacts
echo "Running flutter precache for iOS..."
flutter precache --ios

# Get dependencies
cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

# Check CocoaPods
cd ios
pod repo update
pod install
cd ..

echo "=== CI_POST_CLONE.SH COMPLETED ==="
