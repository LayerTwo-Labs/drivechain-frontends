#!/bin/bash

# Generate version information for any Flutter app in the monorepo
# This script creates lib/gen/version.dart with build-time information

set -e

# Validate app name and show usage if invalid
APP_NAME=$1

# Check if app name is provided, valid, directory exists, and is a Flutter app
if [ $# -eq 0 ] || ! [[ "$APP_NAME" =~ ^(thunder|bitnames|bitassets|bitwindow|zside)$ ]] || [ ! -d "$APP_NAME" ] || [ ! -f "$APP_NAME/pubspec.yaml" ]; then
    echo "Error: Invalid app name '$APP_NAME'"
    echo "Usage: $0 <thunder/bitnames/bitassets/bitwindow/zside>"
    echo ""
    echo "Examples:"
    echo "  $0 bitwindow"
    echo "  $0 thunder"
    exit 1
fi

echo "Generating version info for $APP_NAME..."

# Get git information
COMMIT_HASH=$(git rev-parse --short HEAD)
COMMIT_FULL=$(git rev-parse HEAD)
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Get version from pubspec.yaml
VERSION=$(grep '^version: ' "$APP_NAME/pubspec.yaml" | sed 's/version: //')

# Create gen directory if it doesn't exist
mkdir -p "$APP_NAME/lib/gen"

# Generate the Dart version file
cat > "$APP_NAME/lib/gen/version.dart" << EOF
// Generated file - do not edit manually
// Generated on: $BUILD_DATE

class AppVersion {
  /// Short commit hash (7 characters)
  static const String commit = '$COMMIT_HASH';
  
  /// Full commit hash
  static const String commitFull = '$COMMIT_FULL';
  
  /// Build date in ISO 8601 format (UTC)
  static const String buildDate = '$BUILD_DATE';
  
  /// Version from pubspec.yaml
  static const String version = '$VERSION';
  
  /// App name
  static const String appName = '$APP_NAME';
  
  /// Combined version string for display
  static const String versionString = 'v$VERSION ($COMMIT_HASH)';
  
  /// Build timestamp as Unix epoch
  static const String buildTimestamp = '$(date -u +%s)';
}
EOF

echo "Generated version info for $APP_NAME:"
echo "  Version: $VERSION"
echo "  Commit: $COMMIT_HASH"
echo "  Build Date: $BUILD_DATE"
echo "  File: $APP_NAME/lib/gen/version.dart"