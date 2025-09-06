#!/bin/sh
# ci_post_clone.sh

set -e

echo "Running Flutter & CocoaPods setup in Xcode Cloud..."

# Go to Flutter iOS directory
cd ios

# Ensure Flutter dependencies are installed first
flutter pub get

# Install CocoaPods
pod install --repo-update

echo "Setup complete!"
