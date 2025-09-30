#!/usr/bin/env bash

set -e

app_name="$1"
client_dir="$2"
certificate_path="$3"
certificate_password="$4"
certificate_identity="$5"

if [ "$app_name" = "" ] || [ "$client_dir" = "" ]; then
    echo "Usage: $0 app_name client_dir [certificate_path] [certificate_password] [certificate_identity]"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

cd "$client_dir"

cmd="fastforge release --name prod --jobs windows-exe"
powershell.exe -Command "& {$cmd; if (\$LASTEXITCODE -ne 0) { exit \$LASTEXITCODE }}"
if [ $? -ne 0 ]; then
    echo "Error: fastforge release failed"
    exit 1
fi

mkdir -p release

# Copy installer from versioned subdirectory to main release directory
# Fastforge creates the installer in release/VERSION/ subdirectory
powershell.exe -Command "Get-ChildItem -Path release -Filter '*-windows-setup.exe' -Recurse | Select-Object -First 1 | Move-Item -Destination release\\$lower_app_name.exe; if (\$LASTEXITCODE -ne 0) { exit \$LASTEXITCODE }"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy installer"
    exit 1
fi