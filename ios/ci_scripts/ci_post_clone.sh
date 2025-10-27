#!/bin/bash
set -euo pipefail

echo "=== CI_POST_CLONE.SH STARTED ==="

# Define Flutter SDK directory
FLUTTER_DIR="$HOME/flutter"
export FLUTTER_ROOT="$FLUTTER_DIR"
# Define default system PATH for safety
DEFAULT_PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Add Flutter to PATH but keep existing paths
export PATH="$FLUTTER_DIR/bin:${PATH:-$DEFAULT_PATH}"

echo "PATH = $PATH"
echo "CI_PRIMARY_REPOSITORY_PATH = ${CI_PRIMARY_REPOSITORY_PATH:-Not set}"
echo "FLUTTER_ROOT = $FLUTTER_ROOT"

# Persist PATH so later Xcode Cloud stages (like xcodebuild) can find tools
# Xcode Cloud may start a new shell for later commands, losing this PATH.
# Appending to ~/.zshrc ensures the same PATH is available later.
if [ -n "${SHELL:-}" ]; then
  case "$SHELL" in
    */zsh)
      echo "export PATH=\"$PATH\"" >> ~/.zshrc
      ;;
    */bash)
      echo "export PATH=\"$PATH\"" >> ~/.bashrc
      ;;
    *)
      echo "export PATH=\"$PATH\"" >> ~/.profile
      ;;
  esac
fi

# Install Flutter SDK if not found
if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Flutter SDK not found, installing..."
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
else
  echo "Flutter SDK found at $FLUTTER_DIR"
fi

# Verify Flutter installation
flutter --version

# Precache Flutter iOS artifacts
echo "Running flutter precache for iOS..."
flutter precache --ios

# Get dependencies
echo "Running flutter pub get..."
flutter pub get

# Check CocoaPods
echo "Checking CocoaPods..."
pod --version

# Run pod install
echo "Running pod install..."
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install --repo-update
cd "$CI_PRIMARY_REPOSITORY_PATH"
cd ..

echo "=== CI_POST_CLONE.SH COMPLETED ==="
