#!/bin/bash

set -e

# Check if required parameters are provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <client>"
    echo "Example: $0 bitwindow"
    echo "This script extracts the version from the client's pubspec.yaml"
    exit 1
fi

CLIENT=$1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CLIENT_DIR="$PROJECT_ROOT/$CLIENT"
PUBSPEC_FILE="$CLIENT_DIR/pubspec.yaml"

# Check if pubspec.yaml exists
if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "ERROR: pubspec.yaml not found: $PUBSPEC_FILE" >&2
    exit 1
fi

# Extract version from pubspec.yaml
VERSION=$(grep '^version: ' "$PUBSPEC_FILE" | sed 's/version: //' | tr -d ' ')

if [ -z "$VERSION" ]; then
    echo "ERROR: Could not extract version from $PUBSPEC_FILE" >&2
    exit 1
fi

echo "$VERSION"