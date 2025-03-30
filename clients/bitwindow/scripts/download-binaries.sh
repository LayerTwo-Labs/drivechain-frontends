#!/usr/bin/env bash

set -e

# Check if less than 1 argument is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <linux/macos/windows>"
    exit 1
fi

# Ensure the binary folder is in place. 
mkdir -p assets/bin
old_cwd=$(pwd)
assets_dir=$old_cwd/assets/bin

cd ../../servers/bitwindow
# Build bitwindowd
echo "Building bitwindowd"
just build-go

# Move the necessary binaries to the assets directory
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "moved bin/bitwindowd to $assets_dir/bitwindowd.exe"
    mv bin/bitwindowd $assets_dir/bitwindowd.exe
else
    echo "moved bin/bitwindowd to $assets_dir/bitwindowd"
    mv bin/bitwindowd $assets_dir/bitwindowd
fi

echo "bitwindowd has been built and moved to $assets_dir"

echo Going back to $old_cwd
cd $old_cwd