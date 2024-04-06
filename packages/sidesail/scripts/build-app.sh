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

case "$chain" in 
    "testchain")
    app_name=TestSail
    ;;

    "ethereum")
    app_name=EthSail
    ;;

    "zcash")
    app_name=ZSail
    ;;

    *)
    echo unsupported chain: $chain
    exit 1
esac

echo Downloading binaries for $platform + $chain
bash ./scripts/download-binaries.sh $platform $chain

echo Flavorizing for $platform
echo SIDESAIL_CHAIN=$chain > build-vars.env
bash ./scripts/flavorize-$platform.sh $app_name

echo Building $app_name release 
bash ./scripts/build-$platform.sh $app_name

# Reset to the pre-flavorized versions.
git checkout -- windows macos linux pubspec.yaml
rm build-vars.env
