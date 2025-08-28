#!/bin/bash

set -e

# Check if required parameters are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <client> <ed25519_key_file> [zip_file]"
    echo "Example: $0 bitwindow id_ed25519 [bitwindow-osx64.zip]"
    echo "If zip_file not provided, will auto-detect in client's release/ directory"
    echo "Version will be automatically extracted from pubspec.yaml"
    exit 1
fi

CLIENT=$1
ED25519_KEY_FILE=$2
ZIP_PATH=$3

# Set up directories
CLIENT_DIR="$CLIENT"
RELEASE_DIR="$CLIENT_DIR/release"

# Get version from pubspec.yaml
VERSION=$(./scripts/appcast/get-version.sh "$CLIENT")

if [ -z "$VERSION" ]; then
    echo "ERROR: Could not get version for $CLIENT"
    exit 1
fi

# Auto-detect zip file if not provided
if [ -z "$ZIP_PATH" ]; then
    for file in "$RELEASE_DIR"/*"$CLIENT"*.zip; do
        if [ -f "$file" ]; then
            ZIP_PATH=$file
            break
        fi
    done
    
    if [ -z "$ZIP_PATH" ]; then
        echo "ERROR: No zip files found in $RELEASE_DIR"
        exit 1
    fi
fi

# Generate current date in RFC 2822 format
PUB_DATE=$(date -R)

# Check if zip file exists
if [ ! -f "$ZIP_PATH" ]; then
    echo "ERROR: Zip file not found: $ZIP_PATH"
    exit 1
fi

# Check if key file exists
if [ ! -f "$ED25519_KEY_FILE" ]; then
    echo "ERROR: Ed25519 key file not found: $ED25519_KEY_FILE"
    exit 1
fi

cd "$CLIENT_DIR"

echo "Signing macOS zip file with Ed25519 key"
echo "Running: dart run auto_updater:sign_update --ed-key-file ../$ED25519_KEY_FILE ../$ZIP_PATH"
signing_output=$(dart run auto_updater:sign_update --ed-key-file "../$ED25519_KEY_FILE" "../$ZIP_PATH")
echo "$signing_output"

signature=$(echo "$signing_output" | grep -oE 'sparkle:edSignature="[^"]*"' | cut -d'"' -f2)

if [ -z "$signature" ]; then
    echo "ERROR: Could not generate EdDSA signature for $ZIP_PATH using $ED25519_KEY_FILE"
    exit 1
fi

echo "EdDSA signature: $signature"

# Get file size using full path
file_size=$(stat -c%s "../$ZIP_PATH" 2>/dev/null || stat -f%z "../$ZIP_PATH" 2>/dev/null || wc -c < "../$ZIP_PATH")

# Generate macOS appcast fragment (we're in CLIENT_DIR now)
FRAGMENT_FILE="release/$CLIENT-macos-fragment.xml"
mkdir -p release

# convert client to releases-name
if [ "$CLIENT" == "bitwindow" ]; then
    RELEASES_NAME="BitWindow"
    RELEASES_FILENAME="BitWindow-latest-x86_64-apple-darwin.zip"
elif [ "$CLIENT" == "bitassets" ]; then
    RELEASES_NAME="BitAssets"
    RELEASES_FILENAME="test-bitassets-x86_64-apple-darwin.zip"
elif [ "$CLIENT" == "bitnames" ]; then
    RELEASES_NAME="BitNames"
    RELEASES_FILENAME="test-bitnames-x86_64-apple-darwin.zip"
elif [ "$CLIENT" == "thunder" ]; then
    RELEASES_NAME="Thunder"
    RELEASES_FILENAME="test-thunder-x86_64-apple-darwin.zip"
fi

cat > "$FRAGMENT_FILE" << EOF
    <!-- macOS Release -->
    <item>
      <title>Version $VERSION</title>
      <description>Latest version of $CLIENT for macOS</description>
      <pubDate>$PUB_DATE</pubDate>
      <enclosure 
        url="https://releases.drivechain.info/$RELEASES_FILENAME" 
        sparkle:version="$VERSION" 
        sparkle:shortVersionString="$VERSION" 
        sparkle:edSignature="$signature" 
        length="$file_size" 
        type="application/zip" 
        sparkle:os="macos" />
    </item>
EOF
