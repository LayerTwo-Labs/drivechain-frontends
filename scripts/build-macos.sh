#!/usr/bin/env bash

set -e

app_name="$1"
client_dir="$2"
notarization_key_path="$3"
notarization_key_password="$4"
notarization_identity="$5"
notarization_key_id="$6"
notarization_issuer_id="$7"

if [ "$app_name" = "" ] || [ "$client_dir" = "" ]; then
    echo "Usage: $0 app_name client_directory [notarization_key_path notarization_identity notarization_key_id notarization_issuer_id]"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

echo Building $app_name

cd "$client_dir"

flutter clean
flutter build macos --dart-define-from-file=build-vars.env

old_cwd=$PWD
cd ./build/macos/Build/Products/Release 

if test -n "$notarization_identity"; then 
    echo Signing $app_name with identity "'$notarization_identity'"
    
    # We FIRST need to sign the binaries, and then the app itself. Otherwise, the 
    # notarization server reports "a sealed resource is missing or invalid"
    assets_bin_dir=$app_name.app/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/bin
    mkdir -p $assets_bin_dir

    # Only try to sign binaries if the directory exists and has files
    if [ -d "$assets_bin_dir" ] && [ "$(ls -A $assets_bin_dir 2>/dev/null)" ]; then
        for asset in "$assets_bin_dir"/* ; do 
            # Skip if no files match the pattern
            [ -e "$asset" ] || continue
            echo Signing binary asset $(basename "$asset")
            codesign --verbose --deep --force --options runtime --sign \
                "$notarization_identity" "$asset"
        done
    else
        echo "No binary assets to sign in $assets_bin_dir (directory does not exist or is empty)"
    fi

    codesign --verbose --deep --force --options runtime \
        --entitlements $old_cwd/macos/Runner/Release.entitlements \
        --sign "$notarization_identity" $app_name.app
fi

zip_name=$lower_app_name-osx64.zip 
echo Zipping into $zip_name

ditto -c -k --sequesterRsrc --keepParent $app_name.app $zip_name
if test -n "$notarization_key_path"; then
    echo Notarizing $app_name with key "$notarization_key_path" "($notarization_key_id)" and issuer ID "$notarization_issuer_id"
    
    # Retry notarization up to 3 times if it fails with bus error
    max_retries=3
    retry_count=0
    notarization_success=false
    
    while [ $retry_count -lt $max_retries ] && [ "$notarization_success" = false ]; do
        if xcrun notarytool submit $zip_name \
            --wait --key $notarization_key_path \
            --key-id $notarization_key_id \
            --issuer $notarization_issuer_id; then
            notarization_success=true
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                echo "Notarization attempt $retry_count failed, retrying..."
                sleep 5
            fi
        fi
    done

    if [ "$notarization_success" = false ]; then
        echo "Failed to notarize after $max_retries attempts"
        exit 1
    fi

    # Ensure Gatekeeper can verify notarization status offline
    xcrun stapler staple $app_name.app

    # Verify we signed and notarized correctly
    spctl --assess --verbose=4 $app_name.app
    xcrun stapler validate $app_name.app
fi

# Create DMG
echo "Creating DMG for $app_name"
dmg_name=$lower_app_name-osx64.dmg

# Install create-dmg if not already installed
if ! command -v create-dmg &> /dev/null; then
    echo "Installing create-dmg..."
    brew install create-dmg
fi

# Create the DMG with nice formatting
create-dmg \
    --volname "$app_name Installer" \
    --window-pos 200 120 \
    --window-size 800 529 \
    --icon-size 130 \
    --text-size 14 \
    --icon "$app_name.app" 260 250 \
    --hide-extension "$app_name.app" \
    --app-drop-link 540 250 \
    --hdiutil-quiet \
    --sandbox-safe \
    "$dmg_name" \
    "$app_name.app"


echo "DMG created: $dmg_name"

release_dir="$old_cwd/release"
mkdir -p "$release_dir"
cp $zip_name "$release_dir"
cp $dmg_name "$release_dir"
