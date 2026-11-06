#!/usr/bin/env bash
# Zip the committed plugin files for the OpenAI plugin submission portal: dist/runzivo-<version>.zip.
set -euo pipefail
cd "$(dirname "$0")/.."
git ls-files -z plugins/runzivo | python3 -I -c '
import json, os, sys, zipfile
version = json.load(open("plugins/runzivo/.codex-plugin/plugin.json"))["version"]
os.makedirs("dist", exist_ok=True)
out = "dist/runzivo-%s.zip" % version
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for p in sorted(f for f in sys.stdin.read().split("\0") if f):
        z.write(p, os.path.relpath(p, "plugins"))
print(out)'
