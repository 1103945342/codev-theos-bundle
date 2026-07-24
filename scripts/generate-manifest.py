#!/data/data/com.termux/files/usr/bin/python
import hashlib
import json
import pathlib
import sys

version = sys.argv[1] if len(sys.argv) > 1 else "1.0.0"
root = pathlib.Path(__file__).resolve().parent.parent
dist = root / "dist"
repository = "1103945342/codev-theos-bundle"
names = [
    f"theos-core-{version}-arm64.tar.gz",
    f"iphoneos16.5-sdk-{version}.tar.gz",
    f"ldid-{version}-arm64.tar.gz",
]

components = []
for name in names:
    path = dist / name
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    components.append({
        "name": name,
        "size": path.stat().st_size,
        "sha256": digest,
        "url": (
            f"https://github.com/{repository}/releases/download/"
            f"v{version}/{name}"
        ),
    })

manifest = {
    "schemaVersion": 1,
    "version": version,
    "architecture": "arm64-v8a",
    "theosRevision": "16362d3aa83a0acd56df4493d575d34306d42478",
    "sdk": "iPhoneOS16.5.sdk",
    "components": components,
}
(dist / "manifest.json").write_text(
    json.dumps(manifest, ensure_ascii=False, indent=2) + "\n"
)
