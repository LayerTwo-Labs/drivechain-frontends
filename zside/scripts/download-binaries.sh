#!/usr/bin/env bash

set -e

assets_dir=assets/bin
# Ensure the binary folder is in place. 
mkdir -p $assets_dir

# Download params if not present. The script makes sure
# to not double-download
bash ./scripts/zside-fetch-params.sh

# Find path for params, cribbed from zside-fetch-params.sh
uname_S=$(uname -s 2>/dev/null || echo not)
if [ "$uname_S" = "Darwin" ]; then
    PARAMS_DIR="$HOME/Library/Application Support/ZcashParams"
else
    PARAMS_DIR="$HOME/.zcash-params"
fi

# Copy params to the assets directory.
for asset in sapling-output.params sapling-spend.params sprout-groth16.params; do
    cp "$PARAMS_DIR/$asset" $assets_dir
done
