#!/usr/bin/env bash
set -e 

app_name="$1"
# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 app_name"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

# Name of executable when compiled
sed -i "s/sidesail/$lower_app_name/" windows/CMakeLists.txt    

# Name of main window
sed -i "s/SideSail/$app_name/" windows/runner/main.cpp

# Distribution stuff? No clue tbh  
sed -i "s/SideSail/$app_name/" windows/runner/Runner.rc
sed -i "s/sidesail/$lower_app_name/" windows/runner/Runner.rc