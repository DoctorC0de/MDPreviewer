#!/bin/bash
set -e

APP_NAME="MDPreviewer"
EXTENSION_NAME="MDPreviewerQL"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
# Modern structure: Contents/PlugIns/*.appex
EXTENSION_BUNDLE="${APP_BUNDLE}/Contents/PlugIns/${EXTENSION_NAME}.appex"

echo "Creating modern app extension structure..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
mkdir -p "${EXTENSION_BUNDLE}/Contents/MacOS"
mkdir -p "${EXTENSION_BUNDLE}/Contents/Resources"

echo "Copying binaries..."
# Rust host app
cp target/release/mdpreviewer-host "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# App Extension binary
cp "${BUILD_DIR}/${EXTENSION_NAME}" "${EXTENSION_BUNDLE}/Contents/MacOS/${EXTENSION_NAME}"
chmod +x "${EXTENSION_BUNDLE}/Contents/MacOS/${EXTENSION_NAME}"

echo "Copying Plists..."
cp resources/App-Info.plist "${APP_BUNDLE}/Contents/Info.plist"
cp resources/Extension-Info.plist "${EXTENSION_BUNDLE}/Contents/Info.plist"

# Manually replace $(EXECUTABLE_NAME) and $(PRODUCT_BUNDLE_IDENTIFIER) in the plists
sed -i '' "s/\$(EXECUTABLE_NAME)/${APP_NAME}/g" "${APP_BUNDLE}/Contents/Info.plist"
sed -i '' "s/\$(PRODUCT_BUNDLE_IDENTIFIER)/com.doctorcode.mdpreviewer/g" "${APP_BUNDLE}/Contents/Info.plist"
sed -i '' "s/\$(PRODUCT_NAME)/${APP_NAME}/g" "${APP_BUNDLE}/Contents/Info.plist"

sed -i '' "s/\$(EXECUTABLE_NAME)/${EXTENSION_NAME}/g" "${EXTENSION_BUNDLE}/Contents/Info.plist"
sed -i '' "s/\$(PRODUCT_BUNDLE_IDENTIFIER)/com.doctorcode.mdpreviewer.ql/g" "${EXTENSION_BUNDLE}/Contents/Info.plist"
sed -i '' "s/\$(PRODUCT_NAME)/${EXTENSION_NAME}/g" "${EXTENSION_BUNDLE}/Contents/Info.plist"

# Add PkgInfo
echo "APPL????" > "${APP_BUNDLE}/Contents/PkgInfo"

echo "Signing bundle for local trust..."
# Signing with entitlements is critical for app extensions on macOS 14+
codesign -s - --force --entitlements resources/Entitlements.plist --timestamp=none "${EXTENSION_BUNDLE}"
codesign -s - --force --deep --entitlements resources/MDPreviewer.entitlements --timestamp=none "${APP_BUNDLE}"

echo "Bundling complete: ${APP_BUNDLE}"
