#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

THEOS="$1"
TERMUX_PREFIX="/data/data/com.termux/files/usr"

replace_shebang() {
  local file="$1"
  local expected="$2"
  local replacement="$3"
  local current
  current="$(head -n 1 "$file")"
  if [[ "$current" != "$expected" ]]; then
    printf 'Unexpected shebang in %s: %s\n' "$file" "$current" >&2
    exit 1
  fi
  sed -i "1c\\$replacement" "$file"
}

for file in \
  bin/convert_xml_plist.sh \
  bin/fakeroot.sh \
  bin/install-sdk \
  bin/install-theos \
  bin/install.copyFile \
  bin/install.exec \
  bin/install.mergeDir \
  bin/package_version.sh \
  bin/post-update \
  bin/update-theos; do
  replace_shebang "$THEOS/$file" '#!/usr/bin/env bash' \
    "#!$TERMUX_PREFIX/bin/bash"
done

replace_shebang "$THEOS/vendor/dm.pl/dm.pl" '#!/usr/bin/env perl' \
  "#!$TERMUX_PREFIX/bin/perl"
for file in \
  vendor/logos/bin/logify.pl \
  vendor/logos/bin/logos.pl \
  vendor/nic/bin/denicify.pl \
  vendor/nic/bin/nic.pl \
  vendor/nic/bin/nicify.pl; do
  replace_shebang "$THEOS/$file" '#!/usr/bin/env perl' \
    "#!$TERMUX_PREFIX/bin/perl"
done

printf '%s\n' \
  "#!$TERMUX_PREFIX/bin/bash" \
  '' \
  'umask 022' \
  "exec $TERMUX_PREFIX/bin/bash \"\$@\"" \
  > "$THEOS/bin/termux-shell"
chmod 755 "$THEOS/bin/termux-shell"

mkdir -p "$THEOS/toolchain/linux/iphone/bin"
ln -sfn "$TERMUX_PREFIX/bin/clang" "$THEOS/toolchain/linux/iphone/bin/clang"
ln -sfn "$TERMUX_PREFIX/bin/clang++" "$THEOS/toolchain/linux/iphone/bin/clang++"
ln -sfn "$TERMUX_PREFIX/bin/ld64.lld" "$THEOS/toolchain/linux/iphone/bin/ld"
ln -sfn "$TERMUX_PREFIX/bin/llvm-ar" "$THEOS/toolchain/linux/iphone/bin/ar"
ln -sfn "$TERMUX_PREFIX/bin/llvm-ranlib" "$THEOS/toolchain/linux/iphone/bin/ranlib"
ln -sfn "$TERMUX_PREFIX/bin/llvm-strip" "$THEOS/toolchain/linux/iphone/bin/strip"
