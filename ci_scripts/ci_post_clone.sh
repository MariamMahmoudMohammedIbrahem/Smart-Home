#!/bin/sh
# ci_post_clone.sh

set -e
echo "Cleaning and reinstalling CocoaPods..."
cd ios
rm -rf Pods
pod repo update
pod install
echo "Pods installed"
