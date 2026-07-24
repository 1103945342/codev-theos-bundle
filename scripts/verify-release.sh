#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

VERSION="${1:-1.0.1}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
WORK_ROOT="${WORK_ROOT:-$HOME/.cache/codev-theos-release-test}"
THEOS="$WORK_ROOT/theos"
TEST_HOME="$WORK_ROOT/home"
CLI="$WORK_ROOT/cli"
UIKIT="$WORK_ROOT/uikit"

rm -rf "$WORK_ROOT"
mkdir -p "$WORK_ROOT" "$TEST_HOME" "$CLI" "$UIKIT/Resources"
tar -xzf "$DIST/theos-core-$VERSION-arm64.tar.gz" -C "$WORK_ROOT"
mkdir -p "$THEOS/sdks"
tar -xzf "$DIST/iphoneos16.5-sdk-$VERSION.tar.gz" -C "$THEOS/sdks"
tar -xzf "$DIST/ldid-$VERSION-arm64.tar.gz" -C "$THEOS/bin"
chmod 755 "$THEOS/bin/ldid"

test -d "$THEOS/.git"
for path in vendor/dm.pl vendor/include vendor/lib vendor/logos vendor/nic \
  vendor/orion vendor/orion/fishhook vendor/swift-support vendor/templates; do
  test -e "$THEOS/$path/.git"
done
test -f "$THEOS/vendor/include/CydiaSubstrate.h"
test -f "$THEOS/vendor/lib/CydiaSubstrate.framework/CydiaSubstrate.tbd"
test -x "$THEOS/toolchain/linux/iphone/bin/clang"
test -x "$THEOS/bin/dm.pl"

printf 'SHELL := %s/bin/termux-shell\n' "$THEOS" > "$TEST_HOME/.theosrc"

cat > "$CLI/Makefile" <<'EOF'
TARGET := iphone:clang:16.5:12.0
ARCHS := arm64
include $(THEOS)/makefiles/common.mk
TOOL_NAME := codevtest
codevtest_FILES := main.c
codevtest_INSTALL_PATH := /usr/local/bin
include $(THEOS_MAKE_PATH)/tool.mk
EOF
cat > "$CLI/control" <<'EOF'
Package: com.codev.theostest
Name: CodeV Theos Test
Version: 1.0.0
Architecture: iphoneos-arm
Description: Release smoke test
Maintainer: CodeV
Author: CodeV
Section: Utilities
EOF
printf '#include <stdio.h>\nint main(void){puts("CodeV");return 0;}\n' > "$CLI/main.c"

cat > "$UIKIT/Makefile" <<'EOF'
TARGET := iphone:clang:16.5:12.0
ARCHS := arm64
PACKAGE_FORMAT := ipa
TARGET_CODESIGN := true
include $(THEOS)/makefiles/common.mk
APPLICATION_NAME := CodeVTest
CodeVTest_FILES := main.m
CodeVTest_FRAMEWORKS := UIKit
CodeVTest_CFLAGS := -fobjc-arc
include $(THEOS_MAKE_PATH)/application.mk
EOF
cat > "$UIKIT/control" <<'EOF'
Package: com.codev.uikittest
Name: CodeV UIKit Test
Version: 1.0.0
Architecture: iphoneos-arm
Description: Release UIKit smoke test
Maintainer: CodeV
Author: CodeV
Section: Applications
EOF
cat > "$UIKIT/main.m" <<'EOF'
#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic,strong) UIWindow *window;
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)options {
 self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
 self.window.rootViewController = [UIViewController new];
 [self.window makeKeyAndVisible]; return YES;
}
@end
int main(int argc, char **argv) { @autoreleasepool {
 return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
} }
EOF
cat > "$UIKIT/Resources/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.codev.uikittest</string>
<key>CFBundleName</key><string>CodeVTest</string>
<key>CFBundleExecutable</key><string>CodeVTest</string>
<key>CFBundlePackageType</key><string>APPL</string>
</dict></plist>
EOF

export HOME="$TEST_HOME"
export THEOS
export PATH="$PREFIX/bin:/system/bin"
make -C "$CLI" clean package FINALPACKAGE=1
make -C "$UIKIT" clean package FINALPACKAGE=1
test -n "$(find "$CLI/packages" -name '*.deb' -print -quit)"
test -n "$(find "$UIKIT/packages" -name '*.ipa' -print -quit)"
dpkg-deb -I "$CLI"/packages/*.deb >/dev/null
unzip -t "$UIKIT"/packages/*.ipa >/dev/null
file "$UIKIT"/.theos/obj/arm64/CodeVTest.app/CodeVTest | grep -q 'Mach-O 64-bit arm64'
printf 'Theos %s release verification passed.\n' "$VERSION"
