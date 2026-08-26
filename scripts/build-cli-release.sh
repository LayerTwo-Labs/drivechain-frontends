#!/usr/bin/env bash
# Builds the drivechain-cli client and the drivechaind daemon for one target, then
# zips the pair.
set -euo pipefail

version="${1:-dev}"
goos="${2:-$(go env GOOS)}"
goarch="${3:-$(go env GOARCH)}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
orch_dir="$repo_root/sidechain-orchestrator"
out_dir="$repo_root/dist"
stage="$out_dir/drivechain-cli-$version-$goos-$goarch"

exe=""
[[ "$goos" == "windows" ]] && exe=".exe"

rm -rf "$stage"
mkdir -p "$stage"

# drivechaind links mattn/go-sqlite3. A build with cgo off links a stub that
# fails at runtime instead of at compile time.
export CGO_ENABLED=1
export GOOS="$goos"
export GOARCH="$goarch"

(
    cd "$orch_dir"
    go build -ldflags "-X main.version=$version" -o "$stage/drivechain-cli$exe" ./cmd/drivechain-cli
    go build -ldflags "-X main.version=$version" -o "$stage/drivechaind$exe" ./cmd/drivechaind
)

zip_path="$out_dir/drivechain-cli-$version-$goos-$goarch.zip"
rm -f "$zip_path"
if command -v zip >/dev/null 2>&1; then
    (cd "$stage" && zip -q -X "$zip_path" "drivechain-cli$exe" "drivechaind$exe")
else
    # The Windows runner ships no zip. PowerShell reads no Git Bash path, so
    # hand it the Windows form of both.
    powershell -NoProfile -Command \
        "Compress-Archive -Path '$(cygpath -w "$stage")\\*' -DestinationPath '$(cygpath -w "$zip_path")'"
fi
[[ -f "$zip_path" ]] || { echo "no zip at $zip_path" >&2; exit 1; }
rm -rf "$stage"

echo "$zip_path"
