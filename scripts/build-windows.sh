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

# Build Flutter app
git config --system core.longpaths true
clean_cmd="flutter clean"
build_cmd="flutter build windows --dart-define-from-file=build-vars.env"


# Create signed MSIX
if [ -n "$certificate_path" ]; then
    echo "Building signed MSIX with certificate $certificate_path"
    # Extract filename and use relative path from client directory
    cert_filename=$(basename "$certificate_path")
    msix_cmd="dart run msix:create --store false --certificate-path \"../$cert_filename\""
else
    echo "Building unsigned MSIX (no certificate provided)"
    msix_cmd="dart run msix:create"
fi

powershell.exe -Command "& {$clean_cmd; $build_cmd; $msix_cmd; exit}"

# Prepare release directory
zip_name=$lower_app_name-win64.zip
mkdir -p release

# Copy MSIX to release directory
powershell.exe -Command "Copy-Item build\windows\x64\runner\Release\$app_name.msix release\$lower_app_name.msix"

# Create zip with the MSIX
powershell.exe -Command "Compress-Archive -Force release\$lower_app_name.msix $zip_name"
powershell.exe -Command "Move-Item $zip_name release\"