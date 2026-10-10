#!/bin/bash
# Build a standalone Windows executable or macOS app bundle of nanoKONTROL-Config with PyInstaller
#
# Uses a uv managed CPython (includes tkinter) plus the locked dependencies.
# MIDI is via python-rtmidi (WinMM on Windows, CoreMIDI on macOS).
#
# Usage: packaging/build-pyinstaller.sh [version]
# Requires: uv, bash (Git Bash on Windows).
# Output: dist/nanoKONTROL-Config-<version>-windows-<arch>.exe or dist/nanoKONTROL-Config-<version>-macos-<arch>.zip

set -eu

APP=nanoKONTROL-Config
PYTHON_VERSION=${PYTHON_VERSION:-3.12}
VERSION=${1:-$(git describe --tags --always --dirty 2>/dev/null || echo dev)}

ROOT=$(cd "$(dirname "$0")/.." && pwd)
case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) OS=windows; SEP=';'; ARCH=x86_64; ROOT=$(cd "$ROOT" && pwd -W) ;;
    Darwin) OS=macos; SEP=':'; ARCH=$(uname -m) ;;
    *) echo "Unsupported platform $(uname -s), use build-appimage.sh on Linux" >&2; exit 1 ;;
esac

BUILD=$ROOT/build/pyinstaller
DIST=$ROOT/dist

rm -rf "$BUILD"
mkdir -p "$BUILD" "$DIST"
cd "$ROOT"

run() {
    uv run --frozen --no-dev --managed-python --python "$PYTHON_VERSION" --with pyinstaller "$@"
}

# Square icon generated from the device picture (PyInstaller converts it to .ico / .icns)
run python - "$ROOT/nanoKONTROL2.png" "$BUILD/icon.png" <<'EOF'
import sys
from PIL import Image
img = Image.open(sys.argv[1]).convert('RGBA')
img.thumbnail((256, 256), Image.LANCZOS)
icon = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
icon.paste(img, ((256 - img.width) // 2, (256 - img.height) // 2), img)
icon.save(sys.argv[2])
EOF

DATA=()
for f in *.png LICENSE; do
    DATA+=(--add-data "$ROOT/$f$SEP.")
done

ARGS=(--noconfirm --clean --windowed --name "$APP" --icon "$BUILD/icon.png"
    --distpath "$BUILD/dist" --workpath "$BUILD/work" --specpath "$BUILD"
    --exclude-module alsa_midi "${DATA[@]}")

if [ "$OS" = windows ]; then
    run pyinstaller "${ARGS[@]}" --onefile nanoKONTROL.py
    OUT=$DIST/$APP-$VERSION-$OS-$ARCH.exe
    cp "$BUILD/dist/$APP.exe" "$OUT"
else
    run pyinstaller "${ARGS[@]}" --osx-bundle-identifier cat.cheetah.nanokontrol-config nanoKONTROL.py
    OUT=$DIST/$APP-$VERSION-$OS-$ARCH.zip
    rm -f "$OUT"
    ditto -c -k --keepParent "$BUILD/dist/$APP.app" "$OUT"
fi
echo "Built $OUT"
