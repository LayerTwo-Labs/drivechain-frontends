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

# The macOS app ships ONE frontend that must boot its embedded Go daemons
# natively on both Apple Silicon and Intel. So in CI (the distributed build)
# each darwin daemon is built for both arches, suffixed `-arm64` / `-x86_64`;
# copyBinariesFromAssets picks the host-arch one at launch. Local `just run`
# only needs the host arch, so build that alone for fast iteration. Other OSes
# build a single host-arch binary. Suffix tokens match Dart's currentArch()
# (arm64 / x86_64), not GOARCH.
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
        # CGO must stay on when cross-compiling amd64 on an arm host (Go defaults
        # it off for cross builds); macOS clang handles -arch from GOARCH.
        export CGO_ENABLED=1
        go build -o "$out" "./cmd/$cmd"
    )
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
done

# On macOS the loop above only writes arch-suffixed names. The release build
# (build-app.sh) bundles those and resolves the host-arch one at launch via
# embeddedAssetName. But `just run` execs the daemon straight from the source
# tree under its plain (no-suffix) name — binaries.dart resolves
# binDir(Directory.current)/<canonical> — so without a fresh no-suffix copy it
# silently launches a stale leftover. Stage host-arch copies under the plain
# names for that dev path. Gated on STAGE_PLAIN_BINARIES (set only by `just
# run`) rather than CI: the release build calls this script too, and must NOT
# get a duplicate plain binary bloating the bundle, CI or not.
if [[ "$os" == "darwin" && "${STAGE_PLAIN_BINARIES:-}" == "1" ]]; then
    host_token="$(uname -m)" # arm64 | x86_64, matches the suffix tokens above
    for daemon in bitwindowd orchestratord orchestratorctl; do
        cp -f "$assets_dir/${daemon}-${host_token}" "$assets_dir/${daemon}"
    done
fi

echo "embedded daemons built into $assets_dir"
