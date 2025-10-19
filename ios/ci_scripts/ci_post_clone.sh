#!/bin/bash

set -euo pipefail

echo "=== CI_POST_CLONE.SH STARTED ==="

# Debug
echo "Current working directory: $(pwd)"
echo "Listing contents:"
ls -la
echo "PATH = $PATH"
echo "CI_PRIMARY_REPOSITORY_PATH = ${CI_PRIMARY_REPOSITORY_PATH:-Not set}"

# CocoaPods
echo "Checking CocoaPods..."
if ! command -v pod &> /dev/null; then
    echo "ERROR: CocoaPods (pod) command not found!"
    exit 1
else
    echo "CocoaPods version: $(pod --version)"
fi

# Find Flutter
echo "Checking for Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found in PATH!"
    exit 1
else
    echo "Flutter found at: $(which flutter)"
fi

echo "Flutter version:"
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
