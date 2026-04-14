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

# Build orchestratord
cd $original_cwd/../sidechain-orchestrator
echo "Building orchestratord"

if [[ "$OSTYPE" == "darwin"* ]]; then
    GOARCH=amd64 go build -o "$assets_dir/orchestratord" ./cmd/orchestratord
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    go build -o "$assets_dir/orchestratord.exe" ./cmd/orchestratord
else
    go build -o "$assets_dir/orchestratord" ./cmd/orchestratord
fi

echo "orchestratord has been built and moved to $assets_dir"

cd $original_cwd