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

echo "Building hwi-daemon — installs hwi + pyinstaller into a temp venv"
"$py" -m venv "$tmp/venv"
vpy="$tmp/venv/$bindir/python"
"$vpy" -m pip install --quiet --upgrade pip
"$vpy" -m pip install --quiet "hwi==2.1.1" pyinstaller libusb-package

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
