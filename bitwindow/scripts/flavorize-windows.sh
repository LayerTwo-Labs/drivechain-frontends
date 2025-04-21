#!/usr/bin/env bash
set -e 

app_name="$1"
# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 app_name"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

# Name of executable + app
sed -i "s/BitWindow/$app_name/" windows/CMakeLists.txt    

# Name of main window
sed -i "s/BitWindow/$app_name/" windows/runner/main.cpp

# Distribution stuff? No clue tbh  
sed -i "s/BitWindow/$app_name/" windows/runner/Runner.rc
sed -i "s/bitwindow/$lower_app_name/" windows/runner/Runner.rc

# Names of app and installer. Have to be a bit smart
# about the sed expressions in order to only touch the
# msix_config stanza
sed -i "s/display_name: BitWindow/display_name: $app_name/" pubspec.yaml
sed -i "s/output_name: BitWindow/output_name: $app_name/" pubspec.yaml
sed -i "s/bitwindow/$lower_app_name/" pubspec.yaml
