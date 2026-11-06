#!/usr/bin/env bash
# Zip the plugin for the OpenAI plugin submission portal: dist/runzivo-<version>.zip.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 -I - <<'PY'
import json, os, zipfile
version = json.load(open("plugins/runzivo/.codex-plugin/plugin.json"))["version"]
os.makedirs("dist", exist_ok=True)
out = "dist/runzivo-%s.zip" % version
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for dp, dirs, files in os.walk("plugins/runzivo"):
        dirs.sort()
        for f in sorted(files):
            if f != ".DS_Store":
                p = os.path.join(dp, f)
                z.write(p, os.path.relpath(p, "plugins"))
print(out)
PY
