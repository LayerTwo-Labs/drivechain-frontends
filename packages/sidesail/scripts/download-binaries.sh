#!/usr/bin/env bash

set -e

# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <linux/macos/windows> <testchain/ethereum/zcash>"
    exit 1
fi

# normalize to lower case!
platform=$(echo "$1" | tr '[:upper:]' '[:lower:]')
chain=$(echo "$2" | tr '[:upper:]' '[:lower:]')

case "$platform" in 
    "windows")
    version_postfix=w64-mingw32
    bin_name_postfix=.exe
    unpack_cmd="unzip"
    ;;

    "linux")
    version_postfix=unknown-linux-gnu
    unpack_cmd="unzip"
    ;;

    "macos")
    version_postfix=apple-darwin
    unpack_cmd="tar -xf"
    ;;

    *)
    echo unsupported platform: $platform
    exit 1
esac

case "$chain" in 
    "testchain")
    sidechain_slot=0
    sidechain_bin_name=testchaind
    sidechain_cli_name=testchain-cli
    sidechain_file_name=Testchain-latest
    ;;

    "ethereum")
    sidechain_slot=6
    sidechain_bin_name=sidegeth
    sidechain_file_name=EthSide-latest
    ;;

    "zcash")
    sidechain_slot=5
    sidechain_bin_name=zsided
    sidechain_cli=zside-cli
    sidechain_file_name=ZSide-latest
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

echo Changing into temporary download dir $dl_dir
cd $dl_dir

# Fetch the binaries we're going to bundle alongside the UI. Currently 
# re-using binaries from the Drivechain Launcher. 
# 
# Note: strictly speaking we should be differentiating on CPU architectures
# here. We're skipping that! On macOS Rosetta can run the binaries reasonably 
# well if we're on ARM, and for Linux and Windows we're not bothering with 
# compatability at this stage. 

RELEASES="https://releases.drivechain.info"

drivechain=drivechaind$bin_name_postfix
drivechain_cli=drivechain-cli$bin_name_postfix

# Avoid fetching the binary if it already exists
if ! test -f $bin_dir/$drivechain; then
    echo Mainchain binary does not exist: $bin_dir/$drivechain

    # Fetch the drivechain binaries irregardless of what platform we're 
    # releasing for. 
    drivechain_file=L1-Mainchain-latest-x86_64-$version_postfix.zip

    curl --fail -O $RELEASES/$drivechain_file
    $unpack_cmd $drivechain_file

    for file in $drivechain $drivechain_cli; do 
        mv L1-Mainchain-latest-x86_64-$version_postfix/$file $bin_dir/$file
    done
fi 

cp $bin_dir/$drivechain $assets_dir/$drivechain
cp $bin_dir/$drivechain_cli $assets_dir/$drivechain_cli

sidechain=$sidechain_bin_name$bin_name_postfix
sidechain_cli=$sidechain_cli_name$bin_name_postfix

if ! test -f $bin_dir/$sidechain; then
    echo Sidechain binary does not exist: $bin_dir/$sidechain

    # Only fetch binaries for the specific sidechain we're interested in
    sidechain_file=L2-S$sidechain_slot-$sidechain_file_name-x86_64-$version_postfix
    curl --fail -O $RELEASES/$sidechain_file.zip
    $unpack_cmd $sidechain_file.zip

    mv $sidechain_file/$sidechain $bin_dir/$sidechain

    # Not all sidechains have CLIs! Remember to check for existence
    cli_file=$sidechain_file/$sidechain_cli 
    if test -e $cli_file; then 
        mv $cli_file $bin_dir/$sidechain_cli
    fi 
fi;

cp $bin_dir/$sidechain $assets_dir/$sidechain

cd $old_cwd
