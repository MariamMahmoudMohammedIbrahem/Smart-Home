#!/bin/sh
set -e
echo "ci_post_clone.sh: pwd=$(pwd)"
ls -la
echo "listing repo root:"
ls -la ..
echo "CocoaPods setup…"
cd ../ios
echo "now in: $(pwd)"
pod install --repo-update
echo "Pods installed"
