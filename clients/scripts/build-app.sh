#!/usr/bin/env bash

# This script orchestrates the build process for all clients in this directory, for various
# OSes (Linux, macOS, Windows).
# All clients that want to use this script need these scripts:
# 1. set-app-name.sh - must set the app name and create build-vars.env (if any)
# 2. download-binaries.sh - responsible for populating the assets/bin directory.
# 3. flavorize-<linux/macos/windows>.sh - responsible for setting name, icon etc. for the os.

set -e

os=$(echo "$1" | tr '[:upper:]' '[:lower:]')
client="$2"
chain=$(echo "$3" | tr '[:upper:]' '[:lower:]')
identity="$4"
notarization_key_path="$5"
notarization_key_id="$6"
notarization_issuer_id="$7"

# Convert github actions os names names to a format we expect
case "$os" in
    windows-latest) os="windows" ;;
    linux-latest)   os="linux" ;;
    macos-latest)   os="macos" ;;
esac

if test -z "$os" -o -z "$client"; then
    echo "Usage: $0 <linux/macos/windows> <sidesail/launcher/bitwindow> [chain] [code_sign_identity] [notarization_key_path] [notarization_key_id] [notarization_issuer_id]"
    exit 1
fi

old_cwd=$(pwd)
cleanup() {
    rm -f "$client_dir/build-vars.env"
    git checkout -f "$client_dir/macos"
    git checkout -f "$client_dir/linux"
    git checkout -f "$client_dir/windows"
    echo "Cleaned up all files"
    cd $old_cwd
    echo "Back to $old_cwd"
}
trap cleanup EXIT

client_dir="$client"
if [ ! -d "$client_dir" ]; then
    echo "Error: Client directory $client_dir does not exist."
    exit 1
fi
cd "$client_dir"

source ./scripts/set-app-name.sh "$chain"
if [ -z "$app_name" ]; then
    echo "Error: set-app-name.sh did not set a valid app name"
    exit 1
fi
echo "App name set to: $app_name"

echo "Downloading $client_dir binaries for $os"
bash ./scripts/download-binaries.sh "$os" "$chain"

echo "Flavorizing $client_dir for $os"
bash ./scripts/flavorize-"$os".sh "$app_name"

# Return to the parent directory to run the os-specific build script
cd ../
echo "Building $client_dir $app_name release"
bash ./scripts/build-"$os".sh "$app_name" "$client_dir" \
    "$identity" "$notarization_key_path" \
    "$notarization_key_id" "$notarization_issuer_id"
