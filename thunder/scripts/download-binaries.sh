set -e
set -o pipefail

original_cwd=$(pwd)
assets_dir=$original_cwd/assets/bin
# Ensure the binary folder is in place.
mkdir -p $assets_dir

cd ../sidechain-orchestrator
server_cwd=$(pwd)

# Build drivechaind
echo "Building drivechaind in $server_cwd"

# force building for x86_64 on macOS, so both new and old macs
# work
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Forcing amd64 GOARCH"
    export GOARCH=amd64
    export CGO_ENABLED=1
fi

go build -o ./bin/drivechaind ./cmd/drivechaind/

# Move the necessary binaries to the assets directory
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "moved bin/drivechaind to $assets_dir/drivechaind.exe"
    mv bin/drivechaind $assets_dir/drivechaind.exe
else
    echo "moved bin/drivechaind to $assets_dir/drivechaind"
    mv bin/drivechaind $assets_dir/drivechaind
fi

echo "drivechaind has been built and moved to $assets_dir"

cd $original_cwd
