#!/bin/bash

# Bump version for any Flutter app in the monorepo
# This script increments the version in pubspec.yaml and optionally updates snapcraft.yaml

set -e

# Validate app name and show usage if invalid
APP_NAME=$1
BUMP_TYPE=${2:-patch}  # Default to patch bump

# Check if app name is provided, valid, directory exists, and is a Flutter app
if [ $# -eq 0 ] || ! [[ "$APP_NAME" =~ ^(thunder|bitnames|bitassets|bitwindow|zside)$ ]] || [ ! -d "$APP_NAME" ] || [ ! -f "$APP_NAME/pubspec.yaml" ]; then
    echo "Error: Invalid app name '$APP_NAME'"
    echo "Usage: $0 <thunder/bitnames/bitassets/bitwindow/zside> [major|minor|patch]"
    echo ""
    echo "Examples:"
    echo "  $0 bitwindow patch    # Bump patch version (default)"
    echo "  $0 bitwindow minor    # Bump minor version"
    echo "  $0 bitwindow major    # Bump major version"
    echo "  $0 bitwindow          # Same as patch"
    exit 1
fi

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo "Error: Invalid bump type '$BUMP_TYPE'"
    echo "Valid bump types: major, minor, patch"
    exit 1
fi

echo "Bumping $BUMP_TYPE version for $APP_NAME..."

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version: ' "$APP_NAME/pubspec.yaml" | sed 's/version: //')
echo "Current version: $CURRENT_VERSION"

# Parse version components (handle both x.y.z and x.y.z+build formats)
if [[ "$CURRENT_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(\+[0-9]+)?$ ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    PATCH="${BASH_REMATCH[3]}"
    
    # Increment based on bump type
    case "$BUMP_TYPE" in
        major)
            NEW_MAJOR=$((MAJOR + 1))
            NEW_MINOR=0
            NEW_PATCH=0
            ;;
        minor)
            NEW_MAJOR=$MAJOR
            NEW_MINOR=$((MINOR + 1))
            NEW_PATCH=0
            ;;
        patch)
            NEW_MAJOR=$MAJOR
            NEW_MINOR=$MINOR
            NEW_PATCH=$((PATCH + 1))
            ;;
    esac
    
    NEW_VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
else
    echo "Error: Could not parse version format '$CURRENT_VERSION'"
    echo "Expected format: x.y.z or x.y.z+build"
    exit 1
fi

echo "New version: $NEW_VERSION"

# Update pubspec.yaml - use a more robust sed command
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS uses BSD sed
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$APP_NAME/pubspec.yaml"
else
    # Linux uses GNU sed
    sed -i "s/^version: .*/version: $NEW_VERSION/" "$APP_NAME/pubspec.yaml"
fi
echo "Updated $APP_NAME/pubspec.yaml"

# Update snapcraft.yaml if it exists and contains "latest" version
if [ -f "$APP_NAME/snapcraft.yaml" ]; then
    if grep -q '^version: "latest"' "$APP_NAME/snapcraft.yaml"; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^version: \"latest\"/version: \"$NEW_VERSION\"/" "$APP_NAME/snapcraft.yaml"
        else
            sed -i "s/^version: \"latest\"/version: \"$NEW_VERSION\"/" "$APP_NAME/snapcraft.yaml"
        fi
        echo "Updated $APP_NAME/snapcraft.yaml (removed 'latest', set to $NEW_VERSION)"
    else
        # Update existing version in snapcraft.yaml
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^version: .*/version: \"$NEW_VERSION\"/" "$APP_NAME/snapcraft.yaml"
        else
            sed -i "s/^version: .*/version: \"$NEW_VERSION\"/" "$APP_NAME/snapcraft.yaml"
        fi
        echo "Updated $APP_NAME/snapcraft.yaml to $NEW_VERSION"
    fi
fi

# Generate new version.dart file
./scripts/generate-version.sh "$APP_NAME"

echo ""
echo "✅ Successfully bumped $APP_NAME from $CURRENT_VERSION to $NEW_VERSION"
echo ""