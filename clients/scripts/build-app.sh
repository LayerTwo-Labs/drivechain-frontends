#!/usr/bin/env bash

# All sub-folders that wants to build needs these scripts
# to be present. 
# 1. set-app-name.sh
# 2. download-binaries.sh
# 3. flavorize-<platform>.sh

set -e

platform=$(echo "$1" | tr '[:upper:]' '[:lower:]')
client="$2"
chain=$(echo "$3" | tr '[:upper:]' '[:lower:]')
identity="$4"
notarization_key_path="$5"
notarization_key_id="$6"
notarization_issuer_id="$7"

if test -z "$platform" -o -z "$client"; then
    echo "Usage: $0 <linux/macos/windows> [code_sign_identity] [notarization_key_path] [notarization_key_id] [notarization_issuer_id] <sidesail/launcher/bitwindow> [chain]"
    exit 1
fi

client_dir="$client"

if [ ! -d "$client_dir" ]; then
    echo "Error: Client directory $client_dir does not exist."
    exit 1
fi

# Store the current directory before changing
cd "$client_dir"

cleanup() {
    echo "Cleaning up..."
    git checkout -- $client_dir/windows $client_dir/macos $client_dir/linux $client_dir/pubspec.yaml
    rm "$client_dir/build-vars.env"
    cd ../
}
# Set up trap to call cleanup function on script exit
trap cleanup EXIT

# Run set-app-name.sh to set $app_name and create build-vars.env
source ./scripts/set-app-name.sh "$chain"

# Check if app_name is set after sourcing set-app-name.sh
if [ -z "$app_name" ]; then
    echo "Error: set-app-name.sh did not set a valid app name"
    exit 1
fi

# Print the app_name for debugging
echo "App name set to: $app_name"

if [ -z "$app_name" ]; then
    echo "Error: set-app-name.sh did not export a valid app name."
    exit 1
fi

echo "Building for platform: $platform, client: $client, app: $app_name"

echo "Downloading binaries for $platform"
bash ./scripts/download-binaries.sh "$platform" "$chain"

echo "Flavorizing for $platform"
bash ./scripts/flavorize-"$platform".sh "$app_name"

cd ../

echo "Building $app_name release"
bash ./scripts/build-"$platform".sh "$app_name" "$client_dir" \
    "$identity" "$notarization_key_path" \
    "$notarization_key_id" "$notarization_issuer_id"
