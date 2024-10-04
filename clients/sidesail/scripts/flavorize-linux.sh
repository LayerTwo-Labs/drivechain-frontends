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
sed -i "s/sidesail/$lower_app_name/" linux/CMakeLists.txt    

# Name of main window
sed -i "s/SideSail/$app_name/" linux/my_application.cc
sed -i "s/SideSail/$lower_app_name/" linux/my_application.cc    