set -e
set -o pipefail

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

# force building for x86_64 on macOS, so both new and old macs 
# work
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Forcing amd64 GOARCH"
    export GOARCH=amd64
fi

just build-go

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