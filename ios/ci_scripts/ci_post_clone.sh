#!/bin/sh

# Ensure CocoaPods is available
if ! command -v pod >/dev/null; then
  echo "CocoaPods not found. Installing..."
  brew install cocoapods
fi

# Navigate to the iOS directory
cd ios || exit 1

# Install pods
pod install
