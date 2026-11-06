#!/usr/bin/env bash
# Static checks for the plugin: manifests, listing limits, skills and shell scripts.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 -I - <<'PY'
import json, os, re, sys
errors = []
def err(msg): errors.append(msg)
market = json.load(open(".agents/plugins/marketplace.json"))
entry = next(p for p in market["plugins"] if p["name"] == "runzivo")
root = os.path.normpath(entry["source"]["path"])
m = json.load(open(os.path.join(root, ".codex-plugin/plugin.json")))
for key in ("name", "version", "description", "skills"):
    if not m.get(key): err("plugin.json: missing " + key)
if m["name"] != entry["name"]: err("plugin name differs from marketplace entry")
if not re.fullmatch(r"\d+\.\d+\.\d+", m["version"]): err("version is not semver")
if not m.get("author", {}).get("name"): err("author.name missing")
if m.get("requires_local_executor") is not True: err("requires_local_executor must be true: skills run rzv locally")
ui = m["interface"]
for key, limit in (("displayName", 30), ("shortDescription", 30), ("longDescription", 4000)):
    if not ui.get(key) or len(ui[key]) > limit: err("interface.%s missing or over %d chars" % (key, limit))
for key in ("developerName", "category", "capabilities", "logo", "composerIcon"):
    if not ui.get(key): err("interface." + key + " missing")
for key in ("websiteURL", "supportURL", "privacyPolicyURL", "termsOfServiceURL"):
    if not ui.get(key, "").startswith("https://"): err("interface." + key + " must be https")
for key in ("logo", "composerIcon"):
    if not os.path.isfile(os.path.join(root, ui[key])): err(key + " file missing")
listing = " ".join([m["description"], ui["shortDescription"], ui["longDescription"]] + ui.get("defaultPrompt", []))
if re.search(r"(?i)\b(price|pricing|\$\d|CA\$|free trial|discount|subscri|credit)", listing): err("listing mentions pricing or credit")
for bad in ("hooks", "apps", "mcpServers"):
    if bad in m: err("plugin.json must not declare " + bad)
skills = os.path.join(root, m["skills"])
names = []
for d in sorted(os.listdir(skills)):
    text = open(os.path.join(skills, d, "SKILL.md")).read()
    fm = re.match(r"---\nname: (\S+)\ndescription: \"([^\"]+)\"\n---\n\n(.+)", text, re.S)
    if not fm: err(d + ": bad frontmatter"); continue
    if fm.group(1) != d: err(d + ": name differs from directory")
    if len(fm.group(2)) > 1024: err(d + ": description too long")
    if "codex-" not in text and d == "create": err("create must name sandboxes codex-<slug>")
    if re.search(r"exec [^\n]*--env|sandboxes exec", text): err(d + ": must not use rzv sandboxes exec")
    names.append(d)
if names != ["connect", "create", "delete", "sleep-wake", "status"]: err("unexpected skills: %s" % names)
for path in [os.path.join(dp, f) for dp, _, fs in os.walk(".") if ".git" not in dp for f in fs if f != "10-check.sh"]:
    if path.endswith((".md", ".json", ".yaml", ".sh")) and re.search(r"(?i)internal\.|\.lan\b|tnt_[0-9a-f]{8}|sk-[A-Za-z0-9]{20}", open(path).read()):
        err(path + ": looks internal or secret")
if errors: sys.exit("\n".join(errors))
print("plugin ok:", m["name"], m["version"], names)
PY
shellcheck scripts/*.sh
