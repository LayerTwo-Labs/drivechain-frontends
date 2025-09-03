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

# ibrew is a wrapper for brew that runs on x86_64 (intel) on macOS
function ibrew() {
    arch -x86_64 /usr/local/bin/brew "$@"
}

# force building for x86_64 on macOS, so both new and old macs 
# work
if [[ "$OSTYPE" == "darwin"* ]]; then

    if [[ ! -e /usr/local/bin/brew ]]; then
        echo "x86_64 (intel) brew is not installed"
        echo 
        echo "Do this by running this command:"
        echo '  arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    echo "Forcing amd64 GOARCH"
    export GOARCH=amd64

    export PKG_CONFIG_PATH="$(ibrew --prefix zeromq)/lib/pkgconfig:$PKG_CONFIG_PATH"
    export CGO_CFLAGS="-I$(ibrew --prefix zeromq)/include $CGO_CFLAGS"
    export CGO_LDFLAGS="-L$(ibrew --prefix zeromq)/lib $CGO_LDFLAGS"
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