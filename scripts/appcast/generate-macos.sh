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
ZIP_FILE=$3

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
if [ -z "$ZIP_FILE" ]; then
    echo "Auto-detecting macOS zip file in $RELEASE_DIR"
    for file in "$RELEASE_DIR"/*.zip; do
        if [ -f "$file" ]; then
            ZIP_FILE=$(basename "$file")
            echo "Found zip file: $ZIP_FILE"
            break
        fi
    done
    
    if [ -z "$ZIP_FILE" ]; then
        echo "ERROR: No zip files found in $RELEASE_DIR"
        exit 1
    fi
fi

# Generate current date in RFC 2822 format
PUB_DATE=$(date -R)

echo "Generating macOS appcast fragment for $CLIENT version $VERSION"
echo "Release directory: $RELEASE_DIR"
echo "Zip file: $ZIP_FILE"
echo "Ed25519 key: $ED25519_KEY_FILE"

# Check if zip file exists
ZIP_PATH="$RELEASE_DIR/$ZIP_FILE"
if [ ! -f "$ZIP_PATH" ]; then
    echo "ERROR: Zip file not found: $ZIP_PATH"
    exit 1
fi

# Check if key file exists
if [ ! -f "$ED25519_KEY_FILE" ]; then
    echo "ERROR: Ed25519 key file not found: $ED25519_KEY_FILE"
    exit 1
fi

echo "Signing macOS zip file with Ed25519 key"
cd "$CLIENT_DIR"

echo "Running: dart run auto_updater:sign_update --ed-key-file ../$ED25519_KEY_FILE release/$ZIP_FILE"
signing_output=$(dart run auto_updater:sign_update --ed-key-file "../$ED25519_KEY_FILE" "release/$ZIP_FILE")
echo "$signing_output"

signature=$(echo "$signing_output" | grep -oE 'sparkle:edSignature="[^"]*"' | cut -d'"' -f2)

if [ -z "$signature" ]; then
    echo "ERROR: Could not generate EdDSA signature for $ZIP_FILE using $ED25519_KEY_FILE"
    exit 1
fi

echo "EdDSA signature: $signature"

# Get file size (we're now in CLIENT_DIR, so use relative path)
file_size=$(stat -c%s "release/$ZIP_FILE" 2>/dev/null || stat -f%z "release/$ZIP_FILE" 2>/dev/null || wc -c < "release/$ZIP_FILE")

# Generate macOS appcast fragment (we're in CLIENT_DIR now)
FRAGMENT_FILE="release/$CLIENT-macos-fragment.xml"
echo "Generating fragment: $FRAGMENT_FILE"

cat > "$FRAGMENT_FILE" << EOF
    <!-- macOS Release -->
    <item>
      <title>Version $VERSION</title>
      <description>Latest version of $CLIENT for macOS</description>
      <pubDate>$PUB_DATE</pubDate>
      <enclosure 
        url="https://releases.drivechain.info/$ZIP_FILE" 
        sparkle:version="$VERSION" 
        sparkle:shortVersionString="$VERSION" 
        sparkle:edSignature="$signature" 
        length="$file_size" 
        type="application/zip" 
        sparkle:os="macos" />
    </item>
EOF

echo "macOS fragment generated successfully: $FRAGMENT_FILE"