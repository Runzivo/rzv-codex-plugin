#!/usr/bin/env bash
# End-to-end test of the Codex plugin against a live Runzivo environment.
# Codex runs each skill through `codex exec`; rzv checks the result.
#
#   OPENAI_KEY_FILE=<mode-600 file> RZV_PROFILE=<profile> scripts/20-shared-e2e.sh
#
# E2E_ENV        environment rzv must report (default: shared); aborts otherwise
# E2E_MODEL      Codex model (default: gpt-5-nano)
# E2E_SOURCE     marketplace source (default: this checkout), e.g. Runzivo/rzv-codex-plugin@v0.1.0
# E2E_LOCK_DIR   optional directory used as a lock so only one test uses sandboxes
# E2E_WORK       work and evidence directory (default: a new temp directory)
#
# The OpenAI key goes to Codex on stdin and lives in a mode-700 CODEX_HOME that
# is deleted at the end. Evidence has secrets redacted. The sandbox it makes is
# deleted, including after a failure.
set -euo pipefail

rzv="${RZV_BIN:-$(command -v rzv || echo "$HOME/.local/bin/rzv")}"
model="${E2E_MODEL:-gpt-5-nano}"
root="$(cd "$(dirname "$0")/.." && pwd)"
source="${E2E_SOURCE:-$root}"
work="${E2E_WORK:-$(mktemp -d "${TMPDIR:-/tmp}/rzv-codex-e2e.XXXXXX")}"
evidence="$work/evidence"
name="codex-e2e-$(date +%s)"
sandbox="" lock=""
timeout_cmd="$(command -v timeout || command -v gtimeout || true)"
mkdir -p "$evidence" "$work/cwd"
export CODEX_HOME="$work/codex-home"
log() { printf '%s %s\n' "$(date -u +%H:%M:%S)" "$*" | tee -a "$evidence/log.txt" >&2; }
fail() { log "FAIL: $*"; exit 1; }
redact() { sed -E 's/sk-[A-Za-z0-9_-]{8,}/sk-REDACTED/g; s/(Bearer )[A-Za-z0-9._-]+/\1REDACTED/g'; }
field() { python3 -I -c 'import json,sys; d=json.load(sys.stdin)["sandbox"]; print(d.get(sys.argv[1]))' "$1"; }
get() { "$rzv" sandboxes get "$sandbox" --json; }

cleanup() {
  status="${1:-$?}"
  if [ -n "$sandbox" ]; then
    log "cleanup: deleting $sandbox"
    "$rzv" sandboxes delete "$sandbox" --json 2>&1 | tee -a "$evidence/log.txt" >&2 || log "cleanup delete failed: delete $sandbox by hand"
    rm -f "$HOME/.ssh/rzv/$sandbox.conf"
  fi
  rm -rf "$CODEX_HOME"
  [ -n "$lock" ] && rmdir "$lock" 2>/dev/null
  if [ "$status" -eq 0 ]; then log "PASS"; else log "exit $status"; fi
  log "evidence: $evidence"
}
trap cleanup EXIT
unlock_and_cleanup() { s=$?; rm -f "$lock/owner"; cleanup "$s"; }

# codex <step> <prompt>: run one skill through Codex, keep a redacted transcript.
codex_run() {
  step="$1"; shift
  # Each step gets at most 10 minutes, so a hung run cannot hold the sandbox.
  ${timeout_cmd:+$timeout_cmd 600} codex exec -m "$model" -c model_reasoning_effort=medium --sandbox danger-full-access \
    --skip-git-repo-check -C "$work/cwd" --json "$1" < /dev/null 2>&1 | redact > "$evidence/$step.jsonl" || true
  python3 -I -c 'import json,sys
for l in open(sys.argv[1]):
    try: e=json.loads(l)
    except ValueError: continue
    if e.get("type")=="item.completed" and e["item"].get("type")=="agent_message": print(e["item"]["text"])' \
    "$evidence/$step.jsonl" > "$evidence/$step.txt"
}
wait_status() {
  for _ in $(seq 1 40); do
    st="$(get | field status)"; [ "$st" = "$1" ] && return 0; sleep 10
  done
  fail "sandbox did not reach $1 (last: $st)"
}

"$rzv" whoami | grep -q "^Environment: ${E2E_ENV:-shared} " || fail "rzv is not signed in to ${E2E_ENV:-shared}"
[ -r "${OPENAI_KEY_FILE:-}" ] || fail "set OPENAI_KEY_FILE to a readable key file"
if [ -n "${E2E_LOCK_DIR:-}" ]; then
  until mkdir "$E2E_LOCK_DIR" 2>/dev/null; do log "waiting for $E2E_LOCK_DIR"; sleep 30; done
  lock="$E2E_LOCK_DIR"; echo "rzv-codex-plugin e2e $$" > "$lock/owner"
  trap unlock_and_cleanup EXIT
fi
log "rzv: $("$rzv" --version)"; log "codex: $(codex --version)"

mkdir -m 700 "$CODEX_HOME"
codex login --with-api-key < "$OPENAI_KEY_FILE" > /dev/null
codex plugin marketplace add "$source" > /dev/null
codex plugin add runzivo@runzivo | tee -a "$evidence/log.txt" >&2

log "1. create through \$runzivo:create"
codex_run create "Use \$runzivo:create to create a sandbox named $name with size 2vcpu-8gb and lifetime 8h, and wait until it runs."
sandbox="$("$rzv" sandboxes list --json | python3 -I -c 'import json,sys
print(next((s["id"] for s in json.load(sys.stdin)["sandboxes"] if s["name"]==sys.argv[1] and s["status"]!="deleted"),""))' "$name")"
[ -n "$sandbox" ] || fail "Codex did not create $name"
wait_status running
log "   $sandbox ($name)"

log "2. connect and run a task through \$runzivo:connect"
codex_run connect "Use \$runzivo:connect with sandbox $sandbox: create /workspace/hello.py that prints 6*7, then run it there and tell me the output."
"$rzv" sandboxes ssh-config "$sandbox" --write > /dev/null
[ "$(ssh -o BatchMode=yes "$sandbox.rzv" 'python3 /workspace/hello.py')" = 42 ] || fail "the task did not run in the sandbox"

log "3. status through \$runzivo:status"
codex_run status "Use \$runzivo:status to show sandbox $sandbox with its time left and credits used."
grep -q "$sandbox\|$name" "$evidence/status.txt" || fail "status did not show the sandbox"
get | python3 -I -c 'import json,sys; s=json.load(sys.stdin)["sandbox"]
assert s["expires_at"] and 0 < s["remaining_seconds"] <= 8*3600 and s["credits_used"] is not None, s
print("expires", s["expires_at"], "credits", s["credits_used"])' >&2 || fail "expiry or credits missing"

log "4. sleep through \$runzivo:sleep-wake"
codex_run sleep "Use \$runzivo:sleep-wake to put sandbox $sandbox to sleep."
wait_status stopped
c1="$(get | field credits_used)"; sleep 60; c2="$(get | field credits_used)"
log "   credits while stopped: $c1 -> $c2"; [ "$c1" = "$c2" ] || fail "credits grew while stopped"

log "5. wake through \$runzivo:sleep-wake; /workspace is kept"
codex_run wake "Use \$runzivo:sleep-wake to wake sandbox $sandbox."
wait_status running
"$rzv" sandboxes ssh-config "$sandbox" --write > /dev/null
[ "$(ssh -o BatchMode=yes "$sandbox.rzv" 'python3 /workspace/hello.py')" = 42 ] || fail "/workspace lost across sleep and wake"
sleep 65; c3="$(get | field credits_used)"; log "   credits after a running minute: $c2 -> $c3"
python3 -I -c 'import sys; sys.exit(float(sys.argv[2]) <= float(sys.argv[1]))' "$c2" "$c3" || fail "no usage metered while running"

log "6. delete through \$runzivo:delete"
codex_run delete "Use \$runzivo:delete to delete sandbox $sandbox ($name). I confirm: yes, delete $sandbox."
if out="$(get 2>&1)"; then st="$(echo "$out" | field status)"
elif echo "$out" | grep -q '"not_found"'; then st=deleted
else fail "could not read the sandbox after delete: $out"; fi
case "$st" in deleting|deleted|cleanup_pending) sandbox="" ;; *) fail "status after delete: $st" ;; esac
log "   status after delete: $st"

log "7. clear error when not signed in"
RZV_PROFILE="e2e-signed-out-$$" codex_run signed-out "Use \$runzivo:status to list my Runzivo sandboxes."
grep -q "rzv login" "$evidence/signed-out.txt" || fail "no sign-in hint when signed out"
