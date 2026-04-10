set -e
set -o pipefail

original_cwd=$(pwd)
assets_dir=$original_cwd/assets/bin
mkdir -p $assets_dir

cd ../sidechain-orchestrator

echo "Building orchestratord in $(pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Forcing amd64 GOARCH"
    export GOARCH=amd64
fi

go build -o ./bin/orchestratord ./cmd/orchestratord/

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    mv bin/orchestratord $assets_dir/orchestratord.exe
    echo "moved orchestratord to $assets_dir/orchestratord.exe"
else
    mv bin/orchestratord $assets_dir/orchestratord
    echo "moved orchestratord to $assets_dir/orchestratord"
fi

cd $original_cwd
