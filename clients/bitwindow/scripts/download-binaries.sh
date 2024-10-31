#!/usr/bin/env bash

set -e

# Check if less than 1 argument is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <linux/macos/windows>"
    exit 1
fi

# normalize to lower case!
platform=$(echo "$1" | tr '[:upper:]' '[:lower:]')

case "$platform" in 
    "windows")
    version_postfix=w64-mingw32
    enforcer_version_postfix=pc-windows-gnu
    bin_name_postfix=.exe
    unpack_cmd="unzip"
    ;;

    "linux")
    version_postfix=unknown-linux-gnu
    enforcer_version_postfix=unknown-linux-gnu
    unpack_cmd="unzip"
    ;;

    "macos")
    version_postfix=apple-darwin
    enforcer_version_postfix=apple-darwin
    unpack_cmd="tar -xf"
    ;;

    *)
    echo unsupported platform: $platform
    exit 1
esac


# Ensure the binary folder is in place. 
mkdir -p assets/bin

dl_dir=$(mktemp -d)

old_cwd=$(pwd)
assets_dir=$old_cwd/assets/bin

echo Changing into temporary download dir $dl_dir
cd $dl_dir

# Fetch the binaries we're going to bundle alongside the UI. Currently 
# re-using binaries from the Drivechain Launcher. 
# 
RELEASES="https://releases.drivechain.info"

drivechain=bitcoind$bin_name_postfix
drivechain_cli=bitcoin-cli$bin_name_postfix

# Avoid fetching the binary if it already exists
if ! test -f $assets_dir/$drivechain; then
    echo Drivechain binary does not exist: $assets_dir/$drivechain

    # Fetch the drivechain binaries irregardless of what platform we're 
    # releasing for. 
    drivechain_file=L1-bitcoin-patched-latest-x86_64-$version_postfix.zip

    curl --fail -O $RELEASES/$drivechain_file

    echo unpacking: $unpack_cmd $drivechain_file
    $unpack_cmd $drivechain_file

    for file in $drivechain $drivechain_cli; do 
        mv L1-bitcoin-patched-latest-x86_64-$version_postfix/$file $assets_dir/$file
        chmod +x $assets_dir/$file
    done
fi 
enforcer=bip300301_enforcer$bin_name_postfix

# Avoid fetching the binary if it already exists
if ! test -f $assets_dir/$enforcer; then
    echo Enforcer binary does not exist: $assets_dir/$enforcer

    # Fetch the enforcer binary for the specified platform
    enforcer_file=bip300301-enforcer-latest-x86_64-$enforcer_version_postfix.zip

    curl --fail -O $RELEASES/$enforcer_file

    echo unpacking: $unpack_cmd $enforcer_file
    $unpack_cmd $enforcer_file

    # Use find to locate the enforcer binary. The naming is not always consistent..
    enforcer_binary=$(find . -name "bip300301_enforcer*$bin_name_postfix" -print -quit)

    if [ -z "$enforcer_binary" ]; then
        echo "Error: Could not find the enforcer binary in the extracted files."
        exit 1
    fi

    # Move the found binary to the assets directory and rename it to ensure consistency
    # The code will try to start a binary with this exact name.
    mv "$enforcer_binary" $assets_dir/$enforcer

    # Check if the move was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to move the enforcer binary. Please check the extracted directory structure."
        exit 1
    fi

    echo "Enforcer binary renamed to $enforcer"

    # Make the binary executable
    chmod +x $assets_dir/$enforcer
    echo "Made $enforcer executable"
fi

echo Going back to $old_cwd
cd $old_cwd

cd ../../servers/bitwindow
server_cwd=$(pwd)

# Build bdk-cli and bitwindowd
echo "Building bdk-cli and bitwindowd in $server_cwd"

# Build bdk-cli
echo "Building bdk-cli"
just build-bdk-cli

# Build bitwindowd
echo "Building bitwindowd"
just build-go

# Move the necessary binaries to the assets directory
mv bin/bitwindowd $assets_dir/

echo "bitwindowd with embedded bdk-cli have been built and moved to $assets_dir"

echo Going back to $old_cwd
cd $old_cwd