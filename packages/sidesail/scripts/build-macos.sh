set -e

app_name="$1"
identity="$2"
notarization_key_path="$3"
notarization_key_id="$4"
notarization_issuer_id="$5"
# Check if exactly one argument is provided
if [ "$app_name" = "" ]; then
    echo "Usage: $0 app_name [identity notarization_key_path notarization_key_id notarization_issuer_id]"
    exit 1
fi

lower_app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

echo Building $app_name

flutter build macos --dart-define-from-file=build-vars.env

old_cwd=$PWD
cd ./build/macos/Build/Products/Release 

if test -n  "$identity"; then 
    echo Signing $app_name with identity "'$identity'"
    
    # We FIRST need to sign the binaries, and then the app itself. Otherwise, the 
    # notarization server reports "a sealed resource is missing or invalid"
    assets_bin_dir=$app_name.app/Contents/Frameworks/App.framework/Versions/A/Resources/flutter_assets/assets/bin
    for asset in $assets_bin_dir/* ; do 
        echo Signing binary asset $(basename $asset)

        codesign --verbose --deep --force --options runtime \
            --sign "$identity" $asset
    done

    codesign --verbose --deep --force --options runtime \
        --entitlements $old_cwd/macos/Runner/Release.entitlements \
        --sign "$identity" $app_name.app
fi

zip_name=$lower_app_name-osx64.zip 
echo Zipping into $zip_name

ditto -c -k --sequesterRsrc --keepParent $app_name.app $zip_name

if test -n "$notarization_key_path"; then
    echo Notarizing $app_name with key "$notarization_key_path" "($notarization_key_id)" and issuer ID "$notarization_issuer_id"
    xcrun notarytool submit $zip_name \
        --wait --key $notarization_key_path \
        --key-id $notarization_key_id \
        --issuer $notarization_issuer_id 

    # Ensure Gatekeeper can verify notarization status offline
    xcrun stapler staple $app_name.app

    # Verify we signed and notarized correctly
    spctl --assess --verbose=4 $app_name.app
    xcrun stapler validate $app_name.app
fi

mkdir -p $old_cwd/release
cp $zip_name $old_cwd/release/
