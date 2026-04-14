#!/bin/bash
set -e

APP_NAME="VibeWatch"
APP_BUNDLE="build/$APP_NAME.app"

mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
cp Info.plist "$APP_BUNDLE/Contents/"

swift build -c release
cp "$(swift build -c release --show-bin-path)/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"

echo ""
echo "✓ Built: $APP_BUNDLE"
echo "  Run:   open $APP_BUNDLE"
