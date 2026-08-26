#!/usr/bin/env bash

set -e

# Same name/icon for every build.
app_name=BitWindow

# BITWINDOW_VARIANT selects the build flavor. Only "standard" ships today: the
# default network lives in the orchestrator, and every build reads that one
# value. A variant reappears the day two builds must default to two networks.
: "${BITWINDOW_VARIANT:=standard}"

echo "" > build-vars.env

# Export so the parent build script (and the binary build it spawns) see them.
export app_name BITWINDOW_VARIANT
