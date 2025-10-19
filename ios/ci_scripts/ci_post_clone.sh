#!/bin/bash

set -euo pipefail

echo "=== CI_POST_CLONE.SH STARTED ==="
echo "Current working directory: $(pwd)"
echo "Listing contents:"
echo "PATH = $PATH"
echo "CI_PRIMARY_REPOSITORY_PATH = ${CI_PRIMARY_REPOSITORY_PATH:-Not set}"

# CocoaPods check
echo "Checking CocoaPods..."
if ! command -v pod &> /dev/null; then
    echo "ERROR: CocoaPods (pod) command not found!"
    exit 1
else
    echo "CocoaPods version: $(pod --version)"
fi

# Flutter binary full path
FLUTTER_BIN="/Users/eoip/development/flutter/bin/flutter"

echo "Checking Flutter at $FLUTTER_BIN..."
if [ ! -x "$FLUTTER_BIN" ]; then
    echo "ERROR: Flutter binary not found or not executable at $FLUTTER_BIN"
    exit 1
else
    echo "Flutter found at $FLUTTER_BIN"
fi

echo "Flutter version:"
$FLUTTER_BIN --version

echo "Running flutter pub get..."
$FLUTTER_BIN pub get

echo "Running pod install..."
cd ios || { echo "ERROR: Failed to enter ios directory"; exit 1; }
pod install --repo-update
cd ..

echo "=== CI_POST_CLONE.SH COMPLETED ==="
