set -e
set -o pipefail

original_cwd=$(pwd)
assets_dir=$original_cwd/assets/bin
mkdir -p $assets_dir

# OS detection via `uname -s` — matches the pattern used in bitwindow/justfile.
# `$OSTYPE` is unreliable on the GitHub Windows runner (sometimes empty),
# which silently fell through to the else branch and dropped the .exe suffix.
case "$(uname -s)" in
    Darwin*)             os=darwin ;;
    MINGW*|MSYS*|CYGWIN*) os=windows ;;
    *)                   os=linux ;;
esac

exe=""
if [[ "$os" == "windows" ]]; then
    exe=".exe"
fi

cd server
server_cwd=$(pwd)

echo "Building bitwindowd in $server_cwd"

# Force amd64 on macOS so binaries run on both Apple Silicon (via Rosetta) and Intel.
if [[ "$os" == "darwin" ]]; then
    echo "Forcing amd64 GOARCH"
    export GOARCH=amd64
fi

just build-go

echo "moved bin/bitwindowd to $assets_dir/bitwindowd$exe"
mv bin/bitwindowd $assets_dir/bitwindowd$exe

echo "bitwindowd has been built and moved to $assets_dir"

cd $original_cwd/../sidechain-orchestrator

echo "Building orchestratord"
go build -o "$assets_dir/orchestratord$exe" ./cmd/orchestratord
echo "orchestratord has been built and moved to $assets_dir"

echo "Building orchestratorctl"
go build -o "$assets_dir/orchestratorctl$exe" ./cmd/orchestratorctl
echo "orchestratorctl has been built and moved to $assets_dir"

cd $original_cwd
