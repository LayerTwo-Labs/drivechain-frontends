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

# Create AppImage if appimagetool is available
if command -v appimagetool >/dev/null 2>&1; then
    echo "Creating AppImage for $app_name"
    
    # Create AppDir structure
    appdir_name="$app_name.AppDir"
    rm -rf "$appdir_name"
    mkdir -p "$appdir_name/usr/bin"
    mkdir -p "$appdir_name/usr/lib"
    
    # Copy the entire bundle to AppDir (excluding any existing AppDir)
    for item in *; do
        if [ "$item" != "$appdir_name" ]; then
            cp -r "$item" "$appdir_name/usr/bin/"
        fi
    done
    
    # Create .desktop file
    cat > "$appdir_name/$lower_app_name.desktop" << EOF
[Desktop Entry]
Type=Application
Name=$app_name
Exec=$lower_app_name
Icon=$lower_app_name
Categories=Utility;
EOF
    
    # Copy icon from assets
    icon_path="assets/$lower_app_name.png"
    cp "$old_cwd/$icon_path" "$appdir_name/$lower_app_name.png"
    
    # Make the main executable have the right name
    if [ -f "$appdir_name/usr/bin/$lower_app_name" ]; then
        chmod +x "$appdir_name/usr/bin/$lower_app_name"
    fi
    
    # Create AppRun script
    cat > "$appdir_name/AppRun" << EOF
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export LD_LIBRARY_PATH="\$HERE/usr/lib:\$LD_LIBRARY_PATH"
exec "\$HERE/usr/bin/$lower_app_name" "\$@"
EOF
    chmod +x "$appdir_name/AppRun"
    
    # Create the AppImage
    appimage_name="$app_name-x86_64.AppImage"
    
    # Use --no-appstream and other flags to work around FUSE issues in CI
    ARCH=x86_64 appimagetool --no-appstream "$appdir_name" "$appimage_name"
    
    if [ $? -eq 0 ]; then
        cp "$appimage_name" "$release_dir/"
        echo "AppImage created: $appimage_name"
        
        # Clean up AppDir
        rm -rf "$appdir_name"
    else
        echo "Failed to create AppImage with appimagetool, trying alternative method..."
        
        # Try using the runtime directly (fallback method)
        if command -v mksquashfs >/dev/null 2>&1; then
            echo "Attempting to create AppImage manually..."
            
            # Download AppImage runtime
            runtime_url="https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-x86_64"
            wget -O runtime "$runtime_url" 2>/dev/null || curl -L -o runtime "$runtime_url"
            
            if [ -f runtime ]; then
                # Create squashfs filesystem
                mksquashfs "$appdir_name" "$appdir_name.squashfs" -root-owned -noappend
                
                # Combine runtime and squashfs
                cat runtime "$appdir_name.squashfs" > "$appimage_name"
                chmod +x "$appimage_name"
                
                # Test if it was created successfully
                if [ -f "$appimage_name" ] && [ -s "$appimage_name" ]; then
                    cp "$appimage_name" "$release_dir/"
                    echo "AppImage created using fallback method: $appimage_name"
                    
                    # Clean up
                    rm -f runtime "$appdir_name.squashfs"
                    rm -rf "$appdir_name"
                else
                    echo "Fallback AppImage creation failed"
                    rm -rf "$appdir_name"
                fi
            else
                echo "Could not download AppImage runtime"
                rm -rf "$appdir_name"
            fi
        else
            echo "mksquashfs not available for fallback method"
            rm -rf "$appdir_name"
        fi
    fi
else
    echo "appimagetool not found, skipping AppImage creation"
    echo "Install it with: wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage && chmod +x appimagetool-x86_64.AppImage && sudo mv appimagetool-x86_64.AppImage /usr/local/bin/appimagetool"
fi