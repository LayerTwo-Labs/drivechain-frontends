set -e
set -o pipefail

original_cwd=$(pwd)
assets_dir=$original_cwd/assets/bin
# Ensure the binary folder is in place.
mkdir -p $assets_dir

cd ../sidechain-orchestrator
server_cwd=$(pwd)

# Build orchestratord
echo "Building orchestratord in $server_cwd"

# force building for x86_64 on macOS, so both new and old macs
# work
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Forcing amd64 GOARCH"
    export GOARCH=amd64
    export CGO_ENABLED=1
fi

go build -o ./bin/orchestratord ./cmd/orchestratord/

# Move the necessary binaries to the assets directory
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "moved bin/orchestratord to $assets_dir/orchestratord.exe"
    mv bin/orchestratord $assets_dir/orchestratord.exe
else
    echo "moved bin/orchestratord to $assets_dir/orchestratord"
    mv bin/orchestratord $assets_dir/orchestratord
fi

echo "orchestratord has been built and moved to $assets_dir"

cd $original_cwd
