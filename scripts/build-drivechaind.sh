#!/usr/bin/env bash
# Usage: build-drivechaind.sh <assets/bin dir>
# Builds a stripped drivechaind: one per arch folder on macOS, one host binary elsewhere.
set -euo pipefail

assets_dir="$1"
orchestrator_dir="$(cd "$(dirname "$0")/../sidechain-orchestrator" && pwd)"

case "$(uname -s)" in
    Darwin*)             os=darwin ;;
    MINGW*|MSYS*|CYGWIN*) os=windows ;;
    *)                   os=linux ;;
esac

exe=""
[[ "$os" == "windows" ]] && exe=".exe"

# CI builds both macOS arches; dev builds host only.
if [[ "$os" == "darwin" ]]; then
    if [[ -n "${CI:-}" && -z "${BITWINDOW_HOST_ARCH_ONLY:-}" ]]; then
        targets=("arm64:arm64" "amd64:x86_64")
    elif [[ "$(uname -m)" == "arm64" ]]; then
        targets=("arm64:arm64")
    else
        targets=("amd64:x86_64")
    fi
    # A debug run finds a flat daemon in assets/bin before the bundle, so delete the old flat file.
    rm -f "$assets_dir/drivechaind"
else
    targets=(":")
fi

for target in "${targets[@]}"; do
    goarch="${target%%:*}"
    token="${target##*:}"
    out_dir="$assets_dir"
    [[ -n "$token" ]] && out_dir="$assets_dir/macos-$token"
    mkdir -p "$out_dir"

    echo "Building drivechaind (GOARCH=${goarch:-host}) -> $out_dir"
    (
        cd "$orchestrator_dir"
        [[ -n "$goarch" ]] && export GOARCH="$goarch"
        export CGO_ENABLED=1
        go build -ldflags "-s -w" -o "$out_dir/drivechaind$exe" ./cmd/drivechaind
    )
done
