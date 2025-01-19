#!/usr/bin/env bash
set -e 

app_name="$1"
# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 app_name"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

# Bundle identifier
sed -i "s/drivechain_launcher/$lower_app_name/" macos/Runner/Configs/AppInfo.xcconfig

# App name
sed -i "s/drivechain_launcher/$app_name/" macos/Runner/Configs/AppInfo.xcconfig
