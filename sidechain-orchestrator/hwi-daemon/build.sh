#!/usr/bin/env bash
# Freezes hwi_daemon.py into a standalone binary at $1, for macOS arch $2
# (arm64 or x86_64; default the host arch).
set -e
set -o pipefail

out="${1:?usage: build.sh <output-path> [arch]}"
arch="${2:-$(uname -m)}"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
    Darwin*)              os=darwin ;;
    MINGW*|MSYS*|CYGWIN*) os=windows ;;
    *)                    os=linux ;;
esac

# hwi 3.x, which reads current Ledger and Trezor models, needs Python 3.9-3.12.
supported() { "$1" -c 'import sys; sys.exit(not (3, 9) <= sys.version_info[:2] < (3, 13))' 2>/dev/null; }
py=""
if [[ "$arch" != "$(uname -m)" ]]; then
    [[ "$os" == "darwin" && "$arch" == "x86_64" ]] || {
        echo "cannot build hwi-daemon for $arch on $(uname -s) $(uname -m)" >&2
        exit 1
    }
    # PyInstaller freezes the running interpreter, so an x86_64 one runs under Rosetta.
    uv python install --quiet cpython-3.12-macos-x86_64-none
    py="$(uv python find cpython-3.12-macos-x86_64-none)"
fi
for candidate in python3.12 python3.11 python3.10 python3.9 python3 python; do
    if [[ -z "$py" ]] && command -v "$candidate" >/dev/null && supported "$candidate"; then
        py="$(command -v "$candidate")"
        break
    fi
done
if [[ -z "$py" ]] && command -v uv >/dev/null; then
    uv python install --quiet 3.12
    py="$(uv python find 3.12)"
fi
[[ -n "$py" ]] || {
    echo "no Python 3.9-3.12 found; install Python 3.12 to build hwi-daemon" >&2
    exit 1
}

bindir=bin
[[ "$os" == "windows" ]] && bindir=Scripts

name="$(basename "$out")"; name="${name%.exe}"
tmp="$(mktemp -d)"

echo "Building hwi-daemon — installs hwi + pyinstaller into a temp venv"
"$py" -m venv "$tmp/venv"
vpy="$tmp/venv/$bindir/python"
"$vpy" -m pip install --quiet --upgrade pip
# The x86_64 macOS wheels of cryptography 49 and 50 fail to load (_BIO_ADDR_free).
"$vpy" -m pip install --quiet "hwi==3.2.0" "cryptography==48.0.1" pyinstaller libusb-package

# hwi dlopens libusb by name, which PyInstaller's import analysis never sees.
# libusb-package ships it prebuilt, already under the name hwi asks for.
libusb="$("$vpy" -c 'import libusb_package; print(libusb_package.get_library_path() or "")')"
[[ -n "$libusb" ]] || {
    echo "libusb-package shipped no library for this platform" >&2
    exit 1
}

# PyInstaller splits --add-binary on the host os.pathsep.
sep=":"; [[ "$os" == "windows" ]] && sep=";"

"$vpy" -m PyInstaller --onefile --name "$name" --collect-all hwilib --add-binary "$libusb$sep." \
    --distpath "$(dirname "$out")" --workpath "$tmp/build" --specpath "$tmp" "$here/hwi_daemon.py"
chmod +x "$out" 2>/dev/null || true
rm -rf "$tmp"
