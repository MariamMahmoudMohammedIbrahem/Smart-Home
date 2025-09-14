#!/bin/bash
set -e

echo "=== Running ci_post_clone.sh ==="
echo "Script path: $(pwd)/$0"

# Install Flutter dependencies
echo "Running flutter pub get..."
flutter pub get

# Install iOS pods
echo "Running pod install..."
cd ios
pod install --repo-update
cd ..

echo "=== CI setup completed successfully ==="
