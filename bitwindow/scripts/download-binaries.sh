original_cwd=$(pwd)
assets_dir=$original_cwd/assets/bin
# Ensure the binary folder is in place. 
mkdir -p $assets_dir

cd server
server_cwd=$(pwd)

# Build bdk-cli and bitwindowd
echo "Building bitwindowd in $server_cwd"

# Build bitwindowd
echo "Building bitwindowd"
just build-go-x86

# Move the necessary binaries to the assets directory
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "moved bin/bitwindowd to $assets_dir/bitwindowd.exe"
    mv bin/bitwindowd $assets_dir/bitwindowd.exe
else
    echo "moved bin/bitwindowd to $assets_dir/bitwindowd"
    mv bin/bitwindowd $assets_dir/bitwindowd
fi

echo "bitwindowd has been built and moved to $assets_dir"

cd $original_cwd