#!/usr/bin/env bash

# This script orchestrates the build process for clients in the sub-folder of this directory.
# for different platforms (Linux, macOS, Windows).
# All sub-folders that want to use this script need these scripts
# to be present:
# 1. set-app-name.sh
# 2. download-binaries.sh
# 3. flavorize-<linux/macos/windows>.sh

set -e

platform=$(echo "$1" | tr '[:upper:]' '[:lower:]')
client="$2"
chain=$(echo "$3" | tr '[:upper:]' '[:lower:]')
identity="$4"
notarization_key_path="$5"
notarization_key_id="$6"
notarization_issuer_id="$7"

if test -z "$platform" -o -z "$client"; then
    echo "Usage: $0 <linux/macos/windows> <sidesail/launcher/bitwindow> [chain] [code_sign_identity] [notarization_key_path] [notarization_key_id] [notarization_issuer_id]"
    exit 1
fi

client_dir="$client"

if [ ! -d "$client_dir" ]; then
    echo "Error: Client directory $client_dir does not exist."
    exit 1
fi

# Enter the directory of the client we're building for
cd "$client_dir"

cleanup() {
    rm -f "$client_dir/build-vars.env"
    echo "Cleaned up successfully"
    cd ../
}
# run cleanup on exit
trap cleanup EXIT

# set-app-name.sh is required in the client directory. 
if [ ! -f "./scripts/set-app-name.sh" ]; then
    echo "set-app-name.sh is required, does not exist in ./$client_dir/scripts/"
    exit 1
fi

# Run set-app-name.sh to set $app_name and create build-vars.env
source ./scripts/set-app-name.sh "$chain"

# Check that set-app-name.sh did its job
if [ -z "$app_name" ]; then
    echo "Error: set-app-name.sh did not set a valid app name"
    exit 1
fi

# Print the app_name for debugging
echo "App name set to: $app_name"

# download-binaries.sh is required in the client directory. 
if [ ! -f "./scripts/download-binaries.sh" ]; then
    echo "download-binaries.sh is required, does not exist in ./$client_dir/scripts/"
    exit 1
fi

echo "Downloading $client_dir binaries for $platform"
bash ./scripts/download-binaries.sh "$platform" "$chain"

# flavorize-<platform>.sh is required in the client directory. 
if [ ! -f "./scripts/flavorize-$platform.sh" ]; then
    echo "Error: flavorize-$platform.sh does not exist in ./$client_dir/scripts/"
    exit 1
fi

echo "Flavorizing $client_dir for $platform"
bash ./scripts/flavorize-"$platform".sh "$app_name"

# Return to the parent directory to run the platform-specific build script
cd ../

echo "Building $client_dir $app_name release"
bash ./scripts/build-"$platform".sh "$app_name" "$client_dir" \
    "$identity" "$notarization_key_path" \
    "$notarization_key_id" "$notarization_issuer_id"
