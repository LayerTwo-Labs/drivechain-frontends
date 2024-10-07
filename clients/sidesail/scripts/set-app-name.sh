#!/usr/bin/env bash

set -e

chain=$(echo "${1:-}" | tr '[:upper:]' '[:lower:]')

if test -z "$chain"; then
    echo "Usage: $0 <testchain/ethereum/zcash>"
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
    echo "Unsupported chain: $chain"
    exit 1
    ;;
esac

if [ -z "$app_name" ]; then
    echo "Error: Invalid app name. Exiting."
    exit 1
fi

echo "SIDESAIL_CHAIN=$chain" > build-vars.env

# Export the app_name variable so it's available to the parent script
export app_name