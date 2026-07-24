#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

VERSION="${1:-1.0.1}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
WORK_ROOT="${WORK_ROOT:-$ROOT/work}"
WORK="$WORK_ROOT/theos-$VERSION"
UPSTREAM_COMMIT="16362d3aa83a0acd56df4493d575d34306d42478"
THEOS_GIT_URL="${THEOS_GIT_URL:-https://github.com/theos/theos.git}"
SOURCE_MIRROR="${SOURCE_MIRROR:-}"
SDK_SOURCE="${SDK_SOURCE:-$HOME/theos/sdks/iPhoneOS16.5.sdk}"
LDID="${LDID:-$PREFIX/bin/ldid}"

mkdir -p "$DIST" "$WORK_ROOT"
rm -rf "$WORK"
git clone --no-checkout "${SOURCE_MIRROR:-$THEOS_GIT_URL}" "$WORK"
git -C "$WORK" checkout --detach "$UPSTREAM_COMMIT"
if [[ -n "$SOURCE_MIRROR" ]]; then
  while read -r key path; do
    name="${key#submodule.}"
    name="${name%.path}"
    git -C "$WORK" config "submodule.$name.url" "$SOURCE_MIRROR/$path"
  done < <(git -C "$WORK" config -f .gitmodules --get-regexp '^submodule\..*\.path$')
  git -C "$WORK" -c protocol.file.allow=always submodule update --init
  git -C "$WORK/vendor/orion" config submodule.fishhook.url \
    "$SOURCE_MIRROR/vendor/orion/fishhook"
  git -C "$WORK" -c protocol.file.allow=always submodule update --init --recursive
else
  git -C "$WORK" submodule update --init --recursive
fi
bash "$ROOT/scripts/apply-termux-patches.sh" "$WORK"

test -d "$WORK/.git"
test -e "$WORK/vendor/include/.git"
test -e "$WORK/vendor/lib/.git"
test -f "$WORK/vendor/include/CydiaSubstrate.h"
test -e "$WORK/vendor/lib/libsubstrate.tbd"

tar \
  --sort=name \
  --mtime='UTC 2026-07-24 00:00:00' \
  --owner=0 --group=0 --numeric-owner \
  --transform='flags=r;s|^[^/]*|theos|' \
  --exclude="$(basename "$WORK")/sdks/*" \
  -C "$(dirname "$WORK")" \
  -czf "$DIST/theos-core-$VERSION-arm64.tar.gz" \
  "$(basename "$WORK")"

tar --sort=name --mtime='UTC 2026-07-24 00:00:00' \
  --owner=0 --group=0 --numeric-owner \
  -C "$(dirname "$SDK_SOURCE")" \
  -czf "$DIST/iphoneos16.5-sdk-$VERSION.tar.gz" \
  "$(basename "$SDK_SOURCE")"

tar --sort=name --mtime='UTC 2026-07-24 00:00:00' \
  --owner=0 --group=0 --numeric-owner \
  -C "$(dirname "$LDID")" \
  -czf "$DIST/ldid-$VERSION-arm64.tar.gz" \
  "$(basename "$LDID")"

python "$ROOT/scripts/generate-manifest.py" "$VERSION"
