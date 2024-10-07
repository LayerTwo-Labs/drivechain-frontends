#!/usr/bin/env bash

set -e

app_name="$1"
client_dir="$2"

if [ "$app_name" = "" ] || [ "$client_dir" = "" ]; then
    echo "Usage: $0 app_name client_directory"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

echo Building $app_name

cd "$client_dir"

flutter build linux --dart-define-from-file=build-vars.env

old_cwd=$PWD
cd build/linux/x64/release/bundle

zip_name=$lower_app_name-x86_64-linux-gnu.zip 
echo Zipping into $zip_name

zip -q -r $zip_name *

release_dir="$old_cwd/release"
mkdir -p "$release_dir"
cp $zip_name "$release_dir"