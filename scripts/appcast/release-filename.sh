#!/bin/bash

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <client> <macos|windows>" >&2
    exit 1
fi

CLIENT=$1
OS=$2

case "$OS" in
    macos) SUFFIX="x86_64-apple-darwin.zip" ;;
    windows) SUFFIX="x86_64-windows.exe" ;;
    *)
        echo "ERROR: unknown os: $OS" >&2
        exit 1
        ;;
esac

case "$CLIENT" in
    bitwindow) echo "BitWindow-latest-$SUFFIX" ;;
    thunder | truthcoin | photon | bitnames | bitassets | zside | coinshift) echo "test-$CLIENT-$SUFFIX" ;;
    *)
        echo "ERROR: unknown client: $CLIENT" >&2
        exit 1
        ;;
esac
