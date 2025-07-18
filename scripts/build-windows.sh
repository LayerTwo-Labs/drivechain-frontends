#!/usr/bin/env bash

set -e

app_name="$1"
client_dir="$2"
certificate_path="$3"

if [ "$app_name" = "" ] || [ "$client_dir" = "" ]; then
    echo "Usage: $0 app_name client_dir [certificate_path]"
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
git config --system core.longpaths true
clean_cmd="flutter clean"
build_cmd="flutter build windows --dart-define-from-file=build-vars.env"

# Build and create an MSIX
powershell.exe -Command "& {$clean_cmd; $build_cmd; exit}"

# Check if we should build signed MSIX
if [ -n "$certificate_path" ]; then
    echo "Building signed MSIX with certificate $certificate_path"
    msix_cmd="dart run msix:create --store false --certificate-path \"$certificate_path\""
    powershell.exe -Command "& {$msix_cmd; exit}"
else
    echo "Building unsigned MSIX (no certificate provided)"
    msix_cmd="dart run msix:create"
    powershell.exe -Command "& {$msix_cmd; exit}"
fi

# Prepare the release directory with correct names
zip_name=$lower_app_name-win64.zip
mkdir -p release

# Then zip everything from Release directory including the renamed MSIX
powershell.exe -Command "Compress-Archive -Force build\windows\x64\runner\Release\* release/$zip_name"