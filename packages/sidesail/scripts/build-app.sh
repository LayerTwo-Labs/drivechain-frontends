#!/usr/bin/env bash

set -e

# normalize to lower case!
platform=$(echo "$1" | tr '[:upper:]' '[:lower:]')
chain=$(echo "$2" | tr '[:upper:]' '[:lower:]')
identity="$3"
notarization_key_path="$4"
notarization_key_id="$5"
notarization_issuer_id="$6"

if test -z "$platform" -o -z "$chain"; then
    echo "Usage: $0 <linux/macos/windows> <testchain/ethereum/zcash> [code_sign_identity]"
    exit 1
fi

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
bash ./scripts/build-$platform.sh $app_name \
    "$identity" "$notarization_key_path" \
    "$notarization_key_id" "$notarization_issuer_id"

# Reset to the pre-flavorized versions.
git checkout -- windows macos linux pubspec.yaml
rm build-vars.env
