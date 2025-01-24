#!/usr/bin/env bash

set -e

app_name="$1"
client_dir="$2"
if [ "$app_name" = "" ] || [ "$client_dir" = "" ]; then
    echo "Usage: $0 app_name client_dir"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

cd $client_dir

# Dirty hack: we're running the big build script
# from within bash in WSL, and we need to go back
# to Windows land when doing the Flutter build.

# Screwing around with app names and such doesn't play
# nice with the Flutter caches. Do a proper clean
# before building.
clean_cmd="flutter clean"
build_cmd="flutter build windows --dart-define-from-file=build-vars.env"
# Create MSIX with specific options for CI
msix_cmd="dart run msix:create --build-windows false --install-certificate false"

# Build first
powershell.exe -Command "& {$clean_cmd; $build_cmd; exit}"

# Create MSIX
powershell.exe -Command "& {$msix_cmd; exit}"

# Create release directory and copy MSIX with fixed name
mkdir -p release

# Copy MSIX to release directory and rename it consistently
msix_name=$lower_app_name-win64.msix
cp build/windows/x64/runner/Release/*.msix "release/$msix_name"
