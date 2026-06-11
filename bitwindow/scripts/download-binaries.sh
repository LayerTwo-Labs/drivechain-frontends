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
# natively on both Apple Silicon and Intel. So on darwin each daemon is built
# for both arches, suffixed `-arm64` / `-x86_64`; copyBinariesFromAssets picks
# the host-arch one at launch. Other OSes build a single host-arch binary.
# Suffix tokens match Dart's currentArch() (arm64 / x86_64), not GOARCH.
if [[ "$os" == "darwin" ]]; then
    targets=("arm64:arm64" "amd64:x86_64")
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

echo "embedded daemons built into $assets_dir"
