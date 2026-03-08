set -e
set -o pipefail

original_cwd=$(pwd)
assets_dir=$original_cwd/assets/bin
# Ensure the binary folder is in place.
mkdir -p $assets_dir

cd server
server_cwd=$(pwd)

# Build thunderd
echo "Building thunderd in $server_cwd"

# force building for x86_64 on macOS, so both new and old macs
# work
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Forcing amd64 GOARCH"
    export GOARCH=amd64
fi

just build

# Move the necessary binaries to the assets directory
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "moved bin/thunderd to $assets_dir/thunderd.exe"
    mv bin/thunderd $assets_dir/thunderd.exe
else
    echo "moved bin/thunderd to $assets_dir/thunderd"
    mv bin/thunderd $assets_dir/thunderd
fi

echo "thunderd has been built and moved to $assets_dir"

cd $original_cwd
