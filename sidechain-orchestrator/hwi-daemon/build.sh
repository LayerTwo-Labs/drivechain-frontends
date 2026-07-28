#!/usr/bin/env bash
# Freezes hwi_daemon.py into a standalone binary at $1.
set -e
set -o pipefail

out="${1:?usage: build.sh <output-path>}"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
    Darwin*)              os=darwin ;;
    MINGW*|MSYS*|CYGWIN*) os=windows ;;
    *)                    os=linux ;;
esac

py="$(command -v python3 || command -v python)" || {
    echo "python not found; cannot build hwi-daemon" >&2
    exit 1
}

bindir=bin
[[ "$os" == "windows" ]] && bindir=Scripts

name="$(basename "$out")"; name="${name%.exe}"
tmp="$(mktemp -d)"

# hwi dlopens libusb by name, which PyInstaller's import analysis never sees.
# Unfrozen it resolves to whatever the build machine happens to have installed.
libusb="" d=""
case "$os" in
    darwin)  libusb="$(brew --prefix libusb 2>/dev/null)/lib/libusb-1.0.dylib" ;;
    windows) libusb="${LIBUSB_DLL:-}" ;;
    linux)
        for d in /lib/x86_64-linux-gnu /lib/aarch64-linux-gnu /usr/lib64 /lib64 /usr/lib /lib; do
            [[ -f "$d/libusb-1.0.so.0" ]] && { libusb="$d/libusb-1.0.so.0"; break; }
        done
        ;;
esac
[[ -n "$libusb" && -f "$libusb" ]] || {
    echo "libusb not found${libusb:+ at $libusb}; hwi cannot reach devices without it" >&2
    echo "  macOS:   brew install libusb" >&2
    echo "  Linux:   apt-get install libusb-1.0-0-dev" >&2
    echo "  Windows: set LIBUSB_DLL to a libusb-1.0.dll" >&2
    exit 1
}

# PyInstaller keeps the source basename, and hwi asks for the unversioned name,
# so stage a copy under exactly the name it will look for.
case "$os" in
    darwin)  wanted=libusb-1.0.dylib ;;
    windows) wanted=libusb-1.0.dll ;;
    linux)   wanted=libusb-1.0.so ;;
esac
cp "$libusb" "$tmp/$wanted"

# PyInstaller splits --add-binary on the host os.pathsep.
sep=":" staged="$tmp/$wanted"
# MSYS mangles the ";"-joined argument instead of translating the path.
[[ "$os" == "windows" ]] && { sep=";"; staged="$(cygpath -w "$staged")"; }

echo "Building hwi-daemon — installs hwi + pyinstaller into a temp venv"
"$py" -m venv "$tmp/venv"
vpy="$tmp/venv/$bindir/python"
"$vpy" -m pip install --quiet --upgrade pip
"$vpy" -m pip install --quiet "hwi==2.1.1" pyinstaller
"$vpy" -m PyInstaller --onefile --name "$name" --collect-all hwilib --add-binary "$staged$sep." \
    --distpath "$(dirname "$out")" --workpath "$tmp/build" --specpath "$tmp" "$here/hwi_daemon.py"
chmod +x "$out" 2>/dev/null || true
rm -rf "$tmp"
