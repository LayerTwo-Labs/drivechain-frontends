#!/bin/bash

# A platform with no new fragment keeps its live item. With no Windows item,
# WinSparkle offers the unsigned macOS zip.

set -euo pipefail

if [ $# -ne 4 ]; then
    echo "Usage: $0 <client> <live_appcast> <windows_fragment> <macos_fragment>" >&2
    echo "Give an empty string for a missing file." >&2
    exit 1
fi

CLIENT=$1
LIVE_APPCAST=$2
WINDOWS_FRAGMENT=$3
MACOS_FRAGMENT=$4

live_item() {
    local os=$1
    if [ -z "$LIVE_APPCAST" ] || [ ! -f "$LIVE_APPCAST" ]; then
        return 0
    fi
    awk -v os="sparkle:os=\"$os\"" '
        /<item>/ { block = ""; inside = 1 }
        inside { block = block $0 "\n" }
        /<\/item>/ && inside {
            inside = 0
            if (index(block, os) > 0) { printf "%s", block; exit }
        }
    ' "$LIVE_APPCAST"
}

platform_item() {
    local os=$1 fragment=$2
    if [ -n "$fragment" ]; then
        cat "$fragment"
        return 0
    fi
    live_item "$os"
}

windows_item=$(platform_item windows "$WINDOWS_FRAGMENT")
macos_item=$(platform_item macos "$MACOS_FRAGMENT")

if [ -z "$windows_item" ] && [ -z "$macos_item" ]; then
    echo "ERROR: no appcast item for $CLIENT" >&2
    exit 1
fi

cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>$CLIENT</title>
    <link>https://releases.drivechain.info/</link>
    <description>$CLIENT - Drivechain Application</description>
    <language>en</language>
EOF
if [ -n "$windows_item" ]; then
    echo "$windows_item"
fi
if [ -n "$macos_item" ]; then
    echo "$macos_item"
fi
cat <<EOF
  </channel>
</rss>
EOF
