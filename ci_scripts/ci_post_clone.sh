#!/bin/sh
set -e

echo "=== Running ci_post_clone.sh ==="

# Install Flutter dependencies
echo "Current directory: $(pwd)"
echo "Listing files:"
ls -la

echo "Running flutter pub get..."
flutter pub get

# Install iOS pods
echo "Running pod install..."
cd ios
pod install --repo-update
cd ..

echo "=== CI setup completed successfully ==="