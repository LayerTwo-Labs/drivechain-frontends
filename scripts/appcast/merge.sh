#!/bin/bash

set -e

# Check if required parameters are provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <client> [macos_fragment] [windows_fragment]"
    echo "Example: $0 bitwindow bitwindow-macos-fragment.xml bitwindow-windows-fragment.xml"
    echo "Fragments should be in the client's release/ directory"
    echo "This script will merge fragments with existing appcast, preserving old entries"
    exit 1
fi

CLIENT=$1
MACOS_FRAGMENT=$2
WINDOWS_FRAGMENT=$3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CLIENT_DIR="$PROJECT_ROOT/$CLIENT"
RELEASE_DIR="$CLIENT_DIR/release"

echo "Merging appcast for $CLIENT"
echo "Release directory: $RELEASE_DIR"
echo "macOS fragment: $MACOS_FRAGMENT"
echo "Windows fragment: $WINDOWS_FRAGMENT"

# Generate appcast.xml with client name prefix
APPCAST_FILE="$RELEASE_DIR/$CLIENT-appcast.xml"
TEMP_APPCAST_FILE="$RELEASE_DIR/$CLIENT-appcast-temp.xml"

# Check if existing appcast exists
if [ -f "$APPCAST_FILE" ]; then
    echo "Found existing appcast: $APPCAST_FILE"
    echo "Will merge new fragments with existing entries"
else
    echo "No existing appcast found, creating new one: $APPCAST_FILE"
fi

# Start building the new appcast
cat > "$TEMP_APPCAST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>$CLIENT</title>
    <link>https://releases.drivechain.info/</link>
    <description>$CLIENT - Drivechain Application</description>
    <language>en</language>
EOF

# Track what we're adding
NEW_WINDOWS_ADDED=false
NEW_MACOS_ADDED=false

# Add Windows fragment if provided
if [ -n "$WINDOWS_FRAGMENT" ] && [ -f "$RELEASE_DIR/$WINDOWS_FRAGMENT" ]; then
    echo "Adding Windows fragment: $WINDOWS_FRAGMENT"
    cat "$RELEASE_DIR/$WINDOWS_FRAGMENT" >> "$TEMP_APPCAST_FILE"
    NEW_WINDOWS_ADDED=true
fi

# Add macOS fragment if provided
if [ -n "$MACOS_FRAGMENT" ] && [ -f "$RELEASE_DIR/$MACOS_FRAGMENT" ]; then
    echo "Adding macOS fragment: $MACOS_FRAGMENT"
    cat "$RELEASE_DIR/$MACOS_FRAGMENT" >> "$TEMP_APPCAST_FILE"
    NEW_MACOS_ADDED=true
fi

# If existing appcast exists, preserve entries for platforms we didn't update
if [ -f "$APPCAST_FILE" ]; then
    # Preserve existing Windows entry if we didn't add a new one
    if [ "$NEW_WINDOWS_ADDED" = false ]; then
        echo "Preserving existing Windows entry from old appcast"
        # Extract Windows item from existing appcast and append to temp file
        sed -n '/<!-- Windows Release -->/,/<\/item>/p' "$APPCAST_FILE" >> "$TEMP_APPCAST_FILE" || true
    fi
    
    # Preserve existing macOS entry if we didn't add a new one  
    if [ "$NEW_MACOS_ADDED" = false ]; then
        echo "Preserving existing macOS entry from old appcast"
        # Extract macOS item from existing appcast and append to temp file
        sed -n '/<!-- macOS Release -->/,/<\/item>/p' "$APPCAST_FILE" >> "$TEMP_APPCAST_FILE" || true
    fi
fi

# Close the XML
cat >> "$TEMP_APPCAST_FILE" << EOF
    
  </channel>
</rss>
EOF

# Replace the old appcast with the new one
mv "$TEMP_APPCAST_FILE" "$APPCAST_FILE"

echo "Appcast merged successfully: $APPCAST_FILE"

# Clean up fragment files
if [ -n "$WINDOWS_FRAGMENT" ] && [ -f "$RELEASE_DIR/$WINDOWS_FRAGMENT" ]; then
    rm "$RELEASE_DIR/$WINDOWS_FRAGMENT"
    echo "Cleaned up Windows fragment"
fi

if [ -n "$MACOS_FRAGMENT" ] && [ -f "$RELEASE_DIR/$MACOS_FRAGMENT" ]; then
    rm "$RELEASE_DIR/$MACOS_FRAGMENT" 
    echo "Cleaned up macOS fragment"
fi