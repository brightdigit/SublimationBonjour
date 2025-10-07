#!/bin/bash
set -e  # Exit on any error

# Parse arguments
SWIFT_FLAG="${1:-CLIENT_ONLY}"

# More portable way to get script directory
if [ -z "$SRCROOT" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PACKAGE_DIR="${SCRIPT_DIR}/.."
else
    PACKAGE_DIR="${SRCROOT}"
fi

# Configuration
SCHEME_NAME="SublimationBonjour"
FRAMEWORK_NAME="SublimationBonjour"
OUTPUT_DIR="${PACKAGE_DIR}/build/xcframework"
ARCHIVES_DIR="${PACKAGE_DIR}/build/archives"

# Cleanup previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$OUTPUT_DIR"
rm -rf "$ARCHIVES_DIR"
mkdir -p "$ARCHIVES_DIR"

# Define platforms as array of "name:sdk:destination" pairs
PLATFORMS=(
    "iOS:iphoneos:generic/platform=iOS"
    "iOS-Simulator:iphonesimulator:generic/platform=iOS Simulator"
    "macOS:macosx:generic/platform=macOS"
    "tvOS:appletvos:generic/platform=tvOS"
    "tvOS-Simulator:appletvsimulator:generic/platform=tvOS Simulator"
    "watchOS:watchos:generic/platform=watchOS"
    "watchOS-Simulator:watchsimulator:generic/platform=watchOS Simulator"
    "visionOS:xros:generic/platform=visionOS"
    "visionOS-Simulator:xrsimulator:generic/platform=visionOS Simulator"
)

# Build archives for each platform
echo "🔨 Building frameworks for all platforms..."
XCFRAMEWORK_ARGS=()

for PLATFORM_CONFIG in "${PLATFORMS[@]}"; do
    IFS=':' read -r PLATFORM SDK DESTINATION <<< "$PLATFORM_CONFIG"

    ARCHIVE_PATH="${ARCHIVES_DIR}/${PLATFORM}.xcarchive"

    echo "📦 Building $PLATFORM (SDK: $SDK)..."

    # Set Swift preprocessor flag to conditionally compile code
    # This avoids Swift compiler bug with module/type name conflicts in library evolution
    xcodebuild archive \
        -scheme "$SCHEME_NAME" \
        -sdk "$SDK" \
        -destination "$DESTINATION" \
        -archivePath "$ARCHIVE_PATH" \
        -derivedDataPath "${PACKAGE_DIR}/build/DerivedData" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        ONLY_ACTIVE_ARCH=NO \
        OTHER_SWIFT_FLAGS='$(inherited) -D '"${SWIFT_FLAG}"

    XCFRAMEWORK_ARGS+=(-framework "${ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework")
done

# Create XCFramework
echo "🎁 Creating XCFramework..."
xcodebuild -create-xcframework \
    "${XCFRAMEWORK_ARGS[@]}" \
    -output "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"

echo "✅ XCFramework created successfully at:"
echo "   ${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"

# Print size information
echo ""
echo "📊 Framework size:"
du -sh "${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework"
