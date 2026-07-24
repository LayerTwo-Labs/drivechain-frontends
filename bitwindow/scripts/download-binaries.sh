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

# CI builds both macOS arches (suffixed -arm64 / -x86_64); dev builds host only.
if [[ "$os" == "darwin" ]]; then
    if [[ -n "${CI:-}" ]]; then
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
        # Bake the default network into orchestratord only.
        if [[ "$cmd" == "orchestratord" && -n "${BITWINDOW_DEFAULT_NETWORK:-}" ]]; then
            go build -ldflags "-X main.defaultNetwork=${BITWINDOW_DEFAULT_NETWORK}" -o "$out" "./cmd/$cmd"
        else
            go build -o "$out" "./cmd/$cmd"
        fi
    )
}

# the hwi-daemon is a persistent process to interact with the bitcoin core hwi cli.
# Built as a standalone binary to be able to cancel ongoing operations etc.
build_hwi_daemon() {
    local goarch="$1" out="$2"
    [[ -f "$out" ]] && { echo "hwi-daemon present ($out)"; return; }
    if ! command -v python3 >/dev/null 2>&1; then
        echo "python3 not found; cannot build hwi-daemon" >&2
        return 1
    fi
    local runner=()
    if [[ "$os" == "darwin" && "$goarch" == "amd64" && "$(uname -m)" == "arm64" ]]; then
        # Install Rosetta to cross-build the Intel daemon.
        softwareupdate --install-rosetta --agree-to-license >/dev/null 2>&1 || true
        runner=(arch -x86_64)
    fi
    local script="$original_cwd/../sidechain-orchestrator/hwi-daemon/hwi_daemon.py"
    local tmp
    tmp="$(mktemp -d)"
    echo "Building hwi-daemon (${goarch:-host}) — installs hwi + pyinstaller into a temp venv"
    "${runner[@]}" python3 -m venv "$tmp/venv"
    "${runner[@]}" "$tmp/venv/bin/pip" install --quiet --upgrade pip
    "${runner[@]}" "$tmp/venv/bin/pip" install --quiet "hwi==2.1.1" pyinstaller
    "${runner[@]}" "$tmp/venv/bin/pyinstaller" --onefile --name hwi-daemon --collect-all hwilib \
        --distpath "$(dirname "$out")" --workpath "$tmp/build" --specpath "$tmp" "$script"
    chmod +x "$out" 2>/dev/null || true
    rm -rf "$tmp"
}

for target in "${targets[@]}"; do
    goarch="${target%%:*}"
    token="${target##*:}"
    sfx=""
    [[ -n "$token" ]] && sfx="-$token"

    echo "Building embedded daemons (GOARCH=${goarch:-host}) -> *${sfx}${exe}"
    build_bitwindowd "$goarch" "$assets_dir/bitwindowd${sfx}${exe}"
    build_orch_tool  "$goarch" orchestratord   "$assets_dir/orchestratord${sfx}${exe}"
    build_orch_tool  "$goarch" orchestratorctl "$assets_dir/orchestratorctl${sfx}${exe}"
    build_hwi_daemon "$goarch" "$assets_dir/hwi-daemon${sfx}${exe}"
done

# `just run` execs the daemons by their plain names, so stage host-arch copies.
if [[ "$os" == "darwin" && "${STAGE_PLAIN_BINARIES:-}" == "1" ]]; then
    host_token="$(uname -m)"
    for daemon in bitwindowd orchestratord orchestratorctl hwi-daemon; do
        cp -f "$assets_dir/${daemon}-${host_token}" "$assets_dir/${daemon}"
    done
fi

echo "embedded daemons built into $assets_dir"
