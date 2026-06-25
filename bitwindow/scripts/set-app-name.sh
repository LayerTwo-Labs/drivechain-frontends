#!/usr/bin/env bash

set -e

# Same name/icon for every variant (default-network-only variants, no rebrand).
app_name=BitWindow

# BITWINDOW_VARIANT selects the build flavor: "standard" (default) or "forknet".
# The forknet variant ships an identical app that simply defaults to ForkNet and
# self-updates from its own appcast feed. Everything below is the only build-time
# difference between the two.
: "${BITWINDOW_VARIANT:=standard}"

if [ "$BITWINDOW_VARIANT" = "forknet" ]; then
    # Flutter compile-time defines (consumed via --dart-define-from-file).
    {
        echo "BITWINDOW_NETWORK=forknet"
        echo "BITWINDOW_APPCAST=appcast-bitwindow-forknet.xml"
    } > build-vars.env
    # Picked up by download-binaries.sh to embed the default network into
    # orchestratord (-ldflags -X main.defaultNetwork). This is the authoritative
    # lever — orchestratord owns the first-run network; Flutter follows it.
    export BITWINDOW_DEFAULT_NETWORK=forknet
else
    echo "" > build-vars.env
fi

# Export so the parent build script (and the binary build it spawns) see them.
export app_name BITWINDOW_VARIANT