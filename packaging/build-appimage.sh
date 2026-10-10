#!/bin/sh
# Build a self-contained AppImage of nanoKONTROL-Config
#
# Bundles a relocatable CPython (python-build-standalone via uv, includes tkinter)
# plus the Python dependencies. libasound and libjack are used from the host system.
#
# Usage: packaging/build-appimage.sh [version]
# Requires: uv, curl. Output: dist/nanoKONTROL-Config-<version>-<arch>.AppImage

set -eu

APP=nanoKONTROL-Config
APP_ID=nanokontrol-config
PYTHON_VERSION=${PYTHON_VERSION:-3.12}
VERSION=${1:-$(git describe --tags --always --dirty 2>/dev/null || echo dev)}
ARCH=$(uname -m)

ROOT=$(cd "$(dirname "$0")/.." && pwd)
BUILD=$ROOT/build/appimage
APPDIR=$BUILD/AppDir
DIST=$ROOT/dist

rm -rf "$BUILD"
mkdir -p "$APPDIR/usr/share/$APP_ID" "$DIST"

# Relocatable Python interpreter
uv python install "$PYTHON_VERSION" --install-dir "$BUILD/python"
PYDIR=$(find "$BUILD/python" -maxdepth 1 -type d -name "cpython-$PYTHON_VERSION*" | head -n 1)
cp -a "$PYDIR" "$APPDIR/usr/python"
PY=$APPDIR/usr/python/bin/python3

# Python dependencies from the lock file
uv export --project "$ROOT" --frozen --no-dev --no-hashes --no-emit-project --format requirements-txt > "$BUILD/requirements.txt"
uv pip install --python "$PY" --break-system-packages -r "$BUILD/requirements.txt"

# Trim parts of the standard library the application does not use
PYLIB=$(find "$APPDIR/usr/python/lib" -maxdepth 1 -type d -name 'python3*' | head -n 1)
rm -rf "$PYLIB/test" "$PYLIB/idlelib" "$PYLIB/ensurepip" "$PYLIB/lib2to3" "$PYLIB/turtledemo" \
    "$PYLIB/tkinter/test" "$PYLIB"/config-*
find "$APPDIR/usr/python" -name '__pycache__' -type d -prune -exec rm -rf {} +

# Application files
cp "$ROOT"/nanoKONTROL.py "$ROOT"/ToolTips.py "$ROOT"/*.png "$ROOT"/LICENSE "$APPDIR/usr/share/$APP_ID/"

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE=$(dirname "$(readlink -f "$0")")
exec "$HERE/usr/python/bin/python3" -E -s "$HERE/usr/share/nanokontrol-config/nanoKONTROL.py" "$@"
EOF
chmod +x "$APPDIR/AppRun"

cat > "$APPDIR/$APP_ID.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=nanoKONTROL Config
Comment=Configuration tool for Korg nanoKONTROL
Exec=AppRun
Icon=$APP_ID
Categories=AudioVideo;Audio;Midi;
Terminal=false
EOF

# Square icon generated from the device picture
"$PY" - "$ROOT/nanoKONTROL2.png" "$APPDIR/$APP_ID.png" <<'EOF'
import sys
from PIL import Image
img = Image.open(sys.argv[1]).convert('RGBA')
img.thumbnail((256, 256), Image.LANCZOS)
icon = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
icon.paste(img, ((256 - img.width) // 2, (256 - img.height) // 2), img)
icon.save(sys.argv[2])
EOF
ln -sf "$APP_ID.png" "$APPDIR/.DirIcon"

# Package
APPIMAGETOOL=$BUILD/appimagetool
curl -fsSL -o "$APPIMAGETOOL" "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage"
chmod +x "$APPIMAGETOOL"
OUT=$DIST/$APP-$VERSION-$ARCH.AppImage
APPIMAGE_EXTRACT_AND_RUN=1 ARCH=$ARCH VERSION=$VERSION "$APPIMAGETOOL" --no-appstream "$APPDIR" "$OUT"
echo "Built $OUT"
