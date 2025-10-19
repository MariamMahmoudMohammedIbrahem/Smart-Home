#!/bin/bash

set -euo pipefail

echo "=== CI_POST_CLONE.SH STARTED ==="
echo "Current working directory: $(pwd)"
echo "Listing contents:"
echo "PATH = $PATH"
echo "CI_PRIMARY_REPOSITORY_PATH = ${CI_PRIMARY_REPOSITORY_PATH:-Not set}"

# Install Flutter if not installed
if ! command -v flutter &> /dev/null; then
  echo "Flutter not found, installing Flutter SDK..."

  # Flutter version to install
  FLUTTER_VERSION="stable"

  # Directory where Flutter will be installed
  FLUTTER_DIR="$HOME/flutter"

  # Download Flutter SDK zip for macOS
  echo "Downloading Flutter SDK..."
  curl -L "https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_VERSION}/macos/flutter_macos_${FLUTTER_VERSION}.zip" -o flutter_sdk.zip

  echo "Extracting Flutter SDK..."
  unzip -q flutter_sdk.zip -d "$HOME"

  rm flutter_sdk.zip

  # Add flutter to PATH for this session
  export PATH="$FLUTTER_DIR/bin:$PATH"
else
  echo "Flutter found: $(command -v flutter)"
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
cd ios || { echo "ERROR: Failed to enter ios directory"; exit 1; }
pod install --repo-update
cd ..

echo "=== CI_POST_CLONE.SH COMPLETED ==="
