# CodeV Theos Bundle

Prebuilt Theos components for CodeV on ARM64 Termux.

This repository publishes immutable release assets consumed by the CodeV
in-app Theos installer. The bundle is based on a tested Termux setup and avoids
recursive Git clones on user devices.

## Components

- `theos-core-1.0.0-arm64.tar.gz`: Theos core and Termux compatibility patches.
- `iphoneos16.5-sdk-1.0.0.tar.gz`: iPhoneOS 16.5 SDK snapshot.
- `ldid-1.0.0-arm64.tar.gz`: ARM64 Android `ldid` binary.
- `manifest.json`: file sizes, hashes, and release URLs.

## Install layout

```text
$HOME/theos
$HOME/theos/sdks/iPhoneOS16.5.sdk
$HOME/theos/bin/ldid
$HOME/.cache/theos-build
```

The CodeV application downloads, verifies, stages, and atomically installs
these components.

## Provenance

- Theos: https://github.com/theos/theos
- SDK snapshot: https://github.com/theos/sdks
- ldid: https://github.com/ProcursusTeam/ldid

See `THIRD_PARTY_NOTICES.md` and the license files included in each component.
