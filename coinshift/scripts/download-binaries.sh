set -e
set -o pipefail

original_cwd=$(pwd)
assets_dir=$original_cwd/assets/bin
mkdir -p $assets_dir

cd ../sidechain-orchestrator

echo "Building drivechaind in $(pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Forcing amd64 GOARCH"
    export GOARCH=amd64
    export CGO_ENABLED=1
fi

go build -o ./bin/drivechaind ./cmd/drivechaind/

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    mv bin/drivechaind $assets_dir/drivechaind.exe
    echo "moved drivechaind to $assets_dir/drivechaind.exe"
else
    mv bin/drivechaind $assets_dir/drivechaind
    echo "moved drivechaind to $assets_dir/drivechaind"
fi

cd $original_cwd
