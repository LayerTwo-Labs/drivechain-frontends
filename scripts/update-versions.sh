#!/bin/bash

# Update versions.json with build information for a specific client and platform
# This script downloads the existing versions.json, updates the specific entry, and outputs the updated JSON

set -e

# Check arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <client> <platform> <file_path>"
    echo ""
    echo "Arguments:"
    echo "  client:       thunder, bitnames, bitassets, zside, bitwindow"
    echo "  platform:     macos, linux, windows"
    echo "  file_path:    path to the built file"
    echo ""
    echo "Examples:"
    echo "  $0 bitwindow macos BitWindow-latest-x86_64-apple-darwin.zip"
    echo "  $0 thunder linux test-thunder-x86_64-unknown-linux-gnu.zip"
    exit 1
fi

CLIENT=$1
PLATFORM=$2
FILE_PATH=$3

# Get file size and download URL from the file
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' does not exist"
    exit 1
fi

FILE_SIZE=$(stat -c%s "$FILE_PATH" 2>/dev/null || stat -f%z "$FILE_PATH" 2>/dev/null || wc -c < "$FILE_PATH")
DOWNLOAD_URL=$(basename "$FILE_PATH")

# Validate client
case $CLIENT in
    thunder|bitnames|bitassets|zside|bitwindow)
        ;;
    *)
        echo "Error: Invalid client '$CLIENT'"
        exit 1
        ;;
esac

# Validate platform
case $PLATFORM in
    macos|linux|windows)
        ;;
    *)
        echo "Error: Invalid platform '$PLATFORM'"
        exit 1
        ;;
esac

# Get git information (assuming we're in the repo root)
COMMIT_HASH=$(git rev-parse --short HEAD)
COMMIT_FULL=$(git rev-parse HEAD)
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Try to get version from the app's pubspec.yaml if it exists
VERSION="unknown"
if [ -f "$CLIENT/pubspec.yaml" ]; then
    VERSION=$(grep '^version: ' "$CLIENT/pubspec.yaml" | sed 's/version: //' || echo "unknown")
fi

echo "Updating versions.json for $CLIENT/$PLATFORM"
echo "  File: $DOWNLOAD_URL"
echo "  Size: $FILE_SIZE bytes"
echo "  Version: $VERSION"
echo "  Commit: $COMMIT_HASH"
echo "  Build Date: $BUILD_DATE"

# Download existing versions.json (if it exists)
VERSIONS_URL="https://releases.drivechain.info/versions.json"
TEMP_VERSIONS=$(mktemp)

if curl -s -f "$VERSIONS_URL" -o "$TEMP_VERSIONS" 2>/dev/null; then
    echo "Downloaded existing versions.json"
else
    echo "No existing versions.json found, creating new one"
    echo '{}' > "$TEMP_VERSIONS"
fi

# Create the updated versions.json using jq
jq --arg client "$CLIENT" \
   --arg platform "$PLATFORM" \
   --arg version "$VERSION" \
   --arg commit "$COMMIT_HASH" \
   --arg commitFull "$COMMIT_FULL" \
   --arg buildDate "$BUILD_DATE" \
   --arg downloadUrl "$DOWNLOAD_URL" \
   --argjson size "$FILE_SIZE" \
   '
   .[$client] //= {} |
   .[$client][$platform] = {
     "version": $version,
     "commit": $commit,
     "commitFull": $commitFull,
     "buildDate": $buildDate,
     "downloadUrl": $downloadUrl,
     "size": $size
   }
   ' "$TEMP_VERSIONS" > versions.json

echo "Updated versions.json created successfully"
echo "Contents:"
cat versions.json | jq .

# Clean up
rm -f "$TEMP_VERSIONS"