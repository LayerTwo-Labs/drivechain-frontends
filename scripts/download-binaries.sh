#!/usr/bin/env bash

set -e

# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <linux/macos/windows> <testchain/ethereum/zcash>"
    exit 1
fi

platform="$1"
chain="$2"

case "$platform" in 
    "windows")
    version_postfix=win64
    extension="zip"
    bin_name_postfix=.exe
    unpack_cmd="unzip"
    ;;

    "linux")
    version_postfix=x86_64-linux-gnu
    extension="tar.gz"
    unpack_cmd="tar -xf"
    ;;

    "macos")
    version_postfix=osx64
    extension="tar.gz"
    unpack_cmd="tar -xf"
    ;;

    *)
    echo unsupported platform: $platform
    exit 1
esac

case "$chain" in 
    "testchain")
    sidechain_version="18.01.00"
    sidechain_bin_name=testchaind
    ;;

    "ethereum")
    ;;

    "zcash")
    ;;

    *)
    echo unsupported chain: $chain
    exit 1
esac
 
# Remove any lingering binaries from dev activity. 
git clean -Xf assets

# Ensure the binary folder is in place. 
mkdir -p assets/bin

dl_dir=$(mktemp -d)

echo Working directory: $dl_dir

old_cwd=$(pwd)
cd $dl_dir

# Fetch the binaries we're going to bundle alongside the UI. Currently 
# re-using binaries from the Drivechain Launcher. 
# 
# Note: strictly speaking we should be differentiating on CPU architectures
# here. We're skipping that! On macOS Rosetta can run the binaries reasonably 
# well if we're on ARM, and for Linux and Windows we're not bothering with 
# compatability at this stage. 

# In the browser this is available under release.drivechain.info, but that's
# for some reason just an iframe to this location. 
RELEASES="http://172.105.148.135/drivechain/launcher"

DC_VERSION="0.45.00"

# Fetch the drivechain binaries irregardless of what platform we're 
# releasing for. 
drivechain_file=mainchain-$DC_VERSION-$version_postfix.$extension
curl -O $RELEASES/$drivechain_file
$unpack_cmd $drivechain_file

mv mainchain-$DC_VERSION/bin/drivechaind$bin_name_postfix $old_cwd/assets/bin

# Only fetch binaries for the specific sidechain we're interested in
sidechain_file=$chain-$sidechain_version-$version_postfix.$extension
curl -O $RELEASES/$sidechain_file
$unpack_cmd $sidechain_file

mv $chain-$sidechain_version/bin/$sidechain_bin_name$bin_name_postfix $old_cwd/assets/bin

cd $old_cwd
