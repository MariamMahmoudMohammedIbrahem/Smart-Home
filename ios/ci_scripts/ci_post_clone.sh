#!/bin/sh
set -e

echo "Running post-clone script..."

# Navigate to ios directory
cd ios || { echo "Failed to cd into ios"; exit 1; }

# Ensure CocoaPods is available
if ! command -v pod &> /dev/null
then
  echo "CocoaPods not found. Installing..."
  sudo gem install cocoapods
fi

# Install pods
pod install --repo-update || { echo "Pod install failed"; exit 1; }
