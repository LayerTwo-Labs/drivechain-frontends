#!/bin/bash

set -e

# Check if required parameters are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <client> <dsa_key_file> [exe_file]"
    echo "Example: $0 bitwindow dsa_priv.pem [bitwindow.exe]"
    echo "If exe_file not provided, will auto-detect in client's release/ directory"
    echo "Version will be automatically extracted from pubspec.yaml"
    exit 1
fi

CLIENT=$1
DSA_KEY_FILE=$2
EXE_FILE=$3

# Set up directories
CLIENT_DIR="$CLIENT"
RELEASE_DIR="$CLIENT_DIR/release"

# Get version from pubspec.yaml
VERSION=$(./scripts/appcast/get-version.sh "$CLIENT")

if [ -z "$VERSION" ]; then
    echo "ERROR: Could not get version for $CLIENT"
    exit 1
fi

# Auto-detect exe file if not provided
if [ -z "$EXE_FILE" ]; then
    echo "Auto-detecting Windows exe file in $RELEASE_DIR"
    for file in "$RELEASE_DIR"/*.exe; do
        if [ -f "$file" ]; then
            EXE_FILE=$(basename "$file")
            echo "Found exe file: $EXE_FILE"
            break
        fi
    done
    
    if [ -z "$EXE_FILE" ]; then
        echo "ERROR: No exe files found in $RELEASE_DIR"
        exit 1
    fi
fi

# Generate current date in RFC 2822 format
PUB_DATE=$(date -R)

echo "Generating Windows appcast fragment for $CLIENT version $VERSION"
echo "Release directory: $RELEASE_DIR"
echo "Exe file: $EXE_FILE"
echo "DSA key: $DSA_KEY_FILE"

# Check if exe file exists
EXE_PATH="$RELEASE_DIR/$EXE_FILE"
if [ ! -f "$EXE_PATH" ]; then
    echo "ERROR: Exe file not found: $EXE_PATH"
    exit 1
fi

# Check if key file exists
if [ ! -f "$DSA_KEY_FILE" ]; then
    echo "ERROR: DSA key file not found: $DSA_KEY_FILE"
    exit 1
fi

echo "Signing Windows exe file with DSA key"
cd "$CLIENT_DIR"

echo "Running: dart run auto_updater:sign_update --ed-key-file ../$DSA_KEY_FILE release/$EXE_FILE"
signing_output=$(dart run auto_updater:sign_update --ed-key-file "../$DSA_KEY_FILE" "release/$EXE_FILE")
echo "$signing_output"

signature=$(echo "$signing_output" | grep -oE 'sparkle:dsaSignature="[^"]*"' | cut -d'"' -f2)

if [ -z "$signature" ]; then
    echo "ERROR: Could not generate DSA signature for $EXE_FILE using $DSA_KEY_FILE"
    exit 1
fi

echo "DSA signature: $signature"

# Get file size (we're now in CLIENT_DIR, so use relative path)
file_size=$(stat -c%s "release/$EXE_FILE" 2>/dev/null || stat -f%z "release/$EXE_FILE" 2>/dev/null || wc -c < "release/$EXE_FILE")

# Generate Windows appcast fragment (we're in CLIENT_DIR now)
FRAGMENT_FILE="release/$CLIENT-windows-fragment.xml"
echo "Generating fragment: $FRAGMENT_FILE"

cat > "$FRAGMENT_FILE" << EOF
    <!-- Windows Release -->
    <item>
      <title>Version $VERSION</title>
      <description>Latest version of $CLIENT for Windows</description>
      <pubDate>$PUB_DATE</pubDate>
      <enclosure 
        url="https://releases.drivechain.info/$EXE_FILE" 
        sparkle:version="$VERSION" 
        sparkle:shortVersionString="$VERSION" 
        sparkle:dsaSignature="$signature" 
        length="$file_size" 
        type="application/octet-stream" 
        sparkle:os="windows" />
    </item>
EOF

echo "Windows fragment generated successfully: $FRAGMENT_FILE"