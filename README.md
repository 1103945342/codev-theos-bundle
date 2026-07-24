# CodeV Theos Bundle

Prebuilt Theos components for CodeV on ARM64 Termux.

This repository publishes immutable release assets consumed by the CodeV
in-app Theos installer. Each release is built from a fixed recursive upstream
Git checkout, applies the tracked ARM64 Termux compatibility script, and keeps
the main repository and submodule Git metadata required by Theos.

## Components

- `theos-core-1.0.1-arm64.tar.gz`: fixed recursive Git snapshot and Termux patches.
- `iphoneos16.5-sdk-1.0.1.tar.gz`: iPhoneOS 16.5 SDK snapshot.
- `ldid-1.0.1-arm64.tar.gz`: ARM64 Android `ldid` binary.
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

The manifest records the exact upstream commit and SHA-256 of the compatibility
script. Release generation never reads the active `$HOME/theos` tree except for
the separately supplied SDK snapshot.
