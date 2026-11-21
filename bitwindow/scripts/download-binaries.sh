set -e
set -o pipefail

original_cwd=$(pwd)
assets_dir=$original_cwd/assets/bin
mkdir -p $assets_dir

# uname -s over $OSTYPE, which is empty on the Windows runner.
case "$(uname -s)" in
    Darwin*)             os=darwin ;;
    MINGW*|MSYS*|CYGWIN*) os=windows ;;
    *)                   os=linux ;;
esac

exe=""
if [[ "$os" == "windows" ]]; then
    exe=".exe"
fi

# CI builds both macOS arches; dev builds host only.
# BITWINDOW_HOST_ARCH_ONLY forces the dev behaviour for a CI job that runs the
# app instead of releasing it.
if [[ "$os" == "darwin" ]]; then
    if [[ -n "${CI:-}" && -z "${BITWINDOW_HOST_ARCH_ONLY:-}" ]]; then
        targets=("arm64:arm64" "amd64:x86_64")
    elif [[ "$(uname -m)" == "arm64" ]]; then
        targets=("arm64:arm64")
    else
        targets=("amd64:x86_64")
    fi
else
    targets=(":")
fi

build_bitwindowd() {
    local goarch="$1" out="$2"
    (
        cd "$original_cwd/server"
        [[ -n "$goarch" ]] && export GOARCH="$goarch"
        just build-go
        mv bin/bitwindowd "$out"
    )
}

build_orch_tool() {
    local goarch="$1" cmd="$2" out="$3"
    (
        cd "$original_cwd/../sidechain-orchestrator"
        [[ -n "$goarch" ]] && export GOARCH="$goarch"
        # Keep CGO on for the amd64-on-arm cross build.
        export CGO_ENABLED=1
        # Bake the default network into every tool. The daemon and the control
        # CLI read one value, so a wipe cannot target a network the daemon
        # never ran.
        local ldflags="-s -w"
        if [[ -n "${BITWINDOW_DEFAULT_NETWORK:-}" ]]; then
            ldflags+=" -X github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config.DefaultNetwork=${BITWINDOW_DEFAULT_NETWORK}"
        fi
        go build -ldflags "$ldflags" -o "$out" "./cmd/$cmd"
    )
}

# the hwi-daemon is a persistent process to interact with the bitcoin core hwi cli.
# Built as a standalone binary to be able to cancel ongoing operations etc.
build_hwi_daemon() {
    local arch="$1" out="$2"
    local src="$original_cwd/../sidechain-orchestrator/hwi-daemon"
    [[ "$out" -nt "$src/hwi_daemon.py" && "$out" -nt "$src/build.sh" ]] && { echo "hwi-daemon current ($out)"; return; }
    "$src/build.sh" "$out" ${arch:+"$arch"}
}

# A debug run finds a flat daemon in assets/bin before the bundle, so delete the old flat files.
if [[ "$os" == "darwin" ]]; then
    for daemon in bitwindowd drivechaind drivechain-cli hwi-daemon; do
        rm -f "$assets_dir/$daemon" "$assets_dir/$daemon-arm64" "$assets_dir/$daemon-x86_64"
    done
fi

for target in "${targets[@]}"; do
    goarch="${target%%:*}"
    token="${target##*:}"
    out_dir="$assets_dir"
    # One folder per macOS arch keeps the canonical names, so each daemon finds the next by name.
    [[ -n "$token" ]] && out_dir="$assets_dir/macos-$token"
    mkdir -p "$out_dir"

    echo "Building embedded daemons (GOARCH=${goarch:-host}) -> $out_dir"
    build_bitwindowd "$goarch" "$out_dir/bitwindowd${exe}"
    build_orch_tool  "$goarch" drivechaind   "$out_dir/drivechaind${exe}"
    build_orch_tool  "$goarch" drivechain-cli "$out_dir/drivechain-cli${exe}"
    build_hwi_daemon "$token" "$out_dir/hwi-daemon${exe}"
done

echo "embedded daemons built into $assets_dir"
