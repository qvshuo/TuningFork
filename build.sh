#!/bin/bash
set -euo pipefail

APP_NAME="TuningFork"
APP_BUNDLE_ID="art.anjing.TuningFork"
APP_VERSION="1.0"
APP_BUILD="1"
MIN_MACOS_VERSION="26.0"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
MACOS_DIR="$APP_BUNDLE/Contents/MacOS"
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"
EXECUTABLE="$MACOS_DIR/$APP_NAME"
SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
MODULE_CACHE_DIR="$BUILD_DIR/ModuleCache"

rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"
mkdir -p "$MODULE_CACHE_DIR"

if [[ ! -x naive ]]; then
    echo "Missing executable ./naive" >&2
    exit 1
fi

xcrun swiftc \
    -emit-executable \
    -o "$EXECUTABLE" \
    -sdk "$SDK_PATH" \
    -module-cache-path "$MODULE_CACHE_DIR" \
    -target "arm64-apple-macosx$MIN_MACOS_VERSION" \
    -framework AppKit \
    -framework SwiftUI \
    -framework UserNotifications \
    TuningForkApp.swift \
    RoundedCornersService.swift \
    SafariDarkModeRefreshService.swift \
    NaiveProxyService.swift

install -m 755 naive "$MACOS_DIR/naive"

cat > "$APP_BUNDLE/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$APP_BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$APP_VERSION</string>
    <key>CFBundleVersion</key>
    <string>$APP_BUILD</string>
    <key>LSMinimumSystemVersion</key>
    <string>$MIN_MACOS_VERSION</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>TuningFork needs automation permission to refresh Safari tabs after macOS switches to Dark Mode.</string>
</dict>
</plist>
EOF

if command -v codesign >/dev/null 2>&1; then
    codesign --force --deep --sign - "$APP_BUNDLE"
fi

echo "Built: $APP_BUNDLE"
echo "Run with: open $APP_BUNDLE"
