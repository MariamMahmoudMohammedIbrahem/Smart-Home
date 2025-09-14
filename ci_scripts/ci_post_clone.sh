#!/bin/sh
set -e

echo "=== Running ci_post_clone.sh ==="

# Install Flutter dependencies
flutter pub get

# Install iOS pods
cd ios
pod install --repo-update
cd ..

echo "=== CI setup completed successfully ==="