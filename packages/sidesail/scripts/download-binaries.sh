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
    sidechain_bin_name=sidegeth
    ;;

    "zcash")
    sidechain_bin_name=zsided
    ;;

    *)
    echo unsupported chain: $chain
    exit 1
esac

# Ensure the binary folder is in place. 
mkdir -p assets/bin

dl_dir=$(mktemp -d)

old_cwd=$(pwd)
bin_dir=$old_cwd/bins
assets_dir=$old_cwd/assets/bin

cd $dl_dir

# Fetch the binaries we're going to bundle alongside the UI. Currently 
# re-using binaries from the Drivechain Launcher. 
# 
# Note: strictly speaking we should be differentiating on CPU architectures
# here. We're skipping that! On macOS Rosetta can run the binaries reasonably 
# well if we're on ARM, and for Linux and Windows we're not bothering with 
# compatability at this stage. 

RELEASES="https://releases.drivechain.info"

DC_VERSION="0.46.03"

drivechain=drivechaind$bin_name_postfix

# Avoid fetching the binary if it already exists
if ! test -f $bin_dir/$drivechain; then
    echo Mainchain binary does not exist: $bin_dir/$drivechain

    # Fetch the drivechain binaries irregardless of what platform we're 
    # releasing for. 
    drivechain_file=mainchain-$DC_VERSION-$version_postfix.$extension

    curl -O $RELEASES/$drivechain_file
    $unpack_cmd $drivechain_file

    mv mainchain-$DC_VERSION/bin/$drivechain $bin_dir/$drivechain
fi 

cp $bin_dir/$drivechain $assets_dir/$drivechain

sidechain=$sidechain_bin_name$bin_name_postfix

if ! test -f $bin_dir/$sidechain; then
    echo Sidechain binary does not exist: $bin_dir/$sidechain

    # Only fetch binaries for the specific sidechain we're interested in
    sidechain_file=$chain-$sidechain_version-$version_postfix.$extension
    curl -O $RELEASES/$sidechain_file
    $unpack_cmd $sidechain_file

    mv $chain-$sidechain_version/bin/$sidechain $bin_dir/$sidechain
fi;

cp $bin_dir/$sidechain $assets_dir/$sidechain

cd $old_cwd
