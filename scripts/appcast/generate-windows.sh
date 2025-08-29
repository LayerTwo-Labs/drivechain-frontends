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
EXE_PATH=$3

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
if [ -z "$EXE_PATH" ]; then
    for file in "$RELEASE_DIR"/*"$CLIENT"*.exe; do
        if [ -f "$file" ]; then
            EXE_PATH=$file
            break
        fi
    done
    
    if [ -z "$EXE_PATH" ]; then
        echo "ERROR: No exe files found in $RELEASE_DIR"
        exit 1
    fi
fi

# Generate current date in RFC 2822 format
PUB_DATE=$(date -R)

# Check if exe file exists
if [ ! -f "$EXE_PATH" ]; then
    echo "ERROR: Exe file not found: $EXE_PATH"
    exit 1
fi

# Check if key file exists
if [ ! -f "$DSA_KEY_FILE" ]; then
    echo "ERROR: DSA key file not found: $DSA_KEY_FILE"
    exit 1
fi

cd "$CLIENT_DIR"

echo "Signing Windows exe file with DSA key"
echo "Running: dart run auto_updater:sign_update ../$EXE_PATH ../$DSA_KEY_FILE"
signing_output=$(dart run auto_updater:sign_update "../$EXE_PATH" "../$DSA_KEY_FILE")
echo "$signing_output"

signature=$(echo "$signing_output" | grep -oE 'sparkle:dsaSignature="[^"]*"' | cut -d'"' -f2)

if [ -z "$signature" ]; then
    echo "ERROR: Could not generate DSA signature for $EXE_PATH using $DSA_KEY_FILE"
    exit 1
fi

echo "DSA signature: $signature"

# Get file size using full path
file_size=$(stat -c%s "../$EXE_PATH" 2>/dev/null || stat -f%z "../$EXE_PATH" 2>/dev/null || wc -c < "../$EXE_PATH")

# Generate Windows appcast fragment (we're in CLIENT_DIR now)
FRAGMENT_FILE="release/$CLIENT-windows-fragment.xml"
mkdir -p release

# convert client to releases-name
if [ "$CLIENT" == "bitwindow" ]; then
    RELEASES_NAME="BitWindow"
    RELEASES_FILENAME="BitWindow-latest-win32-x64.exe"
elif [ "$CLIENT" == "bitassets" ]; then
    RELEASES_NAME="BitAssets"
    RELEASES_FILENAME="test-bitassets-win32-x64.exe"
elif [ "$CLIENT" == "bitnames" ]; then
    RELEASES_NAME="BitNames"
    RELEASES_FILENAME="test-bitnames-win32-x64.exe"
elif [ "$CLIENT" == "thunder" ]; then
    RELEASES_NAME="Thunder"
    RELEASES_FILENAME="test-thunder-win32-x64.exe"
fi

cat > "$FRAGMENT_FILE" << EOF
    <!-- Windows Release -->
    <item>
      <title>Version $VERSION</title>
      <description>Latest version of $CLIENT for Windows</description>
      <pubDate>$PUB_DATE</pubDate>
      <enclosure 
        url="https://releases.drivechain.info/$RELEASES_FILENAME" 
        sparkle:version="$VERSION" 
        sparkle:shortVersionString="$VERSION" 
        sparkle:dsaSignature="$signature" 
        length="$file_size" 
        type="application/octet-stream" 
        sparkle:os="windows" />
    </item>
EOF