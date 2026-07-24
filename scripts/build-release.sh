#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

VERSION="${1:-1.0.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
THEOS="${THEOS:-$HOME/theos}"
SDK="$THEOS/sdks/iPhoneOS16.5.sdk"
LDID="${LDID:-$PREFIX/bin/ldid}"

mkdir -p "$DIST"

tar \
  --exclude='*/.git' \
  --exclude='*/.git/**' \
  --exclude='theos/sdks/*' \
  -C "$HOME" \
  -czf "$DIST/theos-core-$VERSION-arm64.tar.gz" \
  theos

tar -C "$THEOS/sdks" \
  -czf "$DIST/iphoneos16.5-sdk-$VERSION.tar.gz" \
  iPhoneOS16.5.sdk

tar -C "$(dirname "$LDID")" \
  -czf "$DIST/ldid-$VERSION-arm64.tar.gz" \
  "$(basename "$LDID")"

python "$ROOT/scripts/generate-manifest.py" "$VERSION"
