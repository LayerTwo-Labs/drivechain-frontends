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

# Build and create an MSIX
powershell.exe -Command "& {$clean_cmd; $build_cmd; $msix_cmd; exit}"

# Prepare the release directory with correct names
msix_name=$lower_app_name.msix
zip_name=$lower_app_name-win64.zip
mkdir -p release

# Then zip everything from Release directory including the renamed MSIX
powershell.exe -Command "Compress-Archive -Force build\windows\x64\runner\Release\* release/$zip_name"