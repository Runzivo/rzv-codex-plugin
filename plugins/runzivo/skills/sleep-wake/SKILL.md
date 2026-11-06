---
name: sleep-wake
description: "Put a Runzivo sandbox to sleep (stop) to pause it, or wake (start) it again. Use when the user wants to pause, stop, resume or start a sandbox."
---

# Sleep and wake a Runzivo sandbox

Sleep: `"$RZV" sandboxes stop <sandbox-id> --json`. Running processes end and compute metering stops. Files in `/workspace` are kept. The lifetime timer keeps running while it sleeps.

Wake: `"$RZV" sandboxes start <sandbox-id> --json`, then repeat `"$RZV" sandboxes get <sandbox-id> --json` every 10 seconds until `sandbox.status` is `running`. Run `"$RZV" sandboxes ssh-config <sandbox-id> --write` again, then reconnect with `ssh <sandbox-id>.rzv`.

Errors here:

- `sandbox_wrong_state`: it is already stopped or running, or still changing; check `$runzivo:status`.
- `sandbox_expired`: it reached its lifetime; create a new one with `$runzivo:create`.

## Find rzv

Run every `rzv` command in this skill as `"$RZV"`, set in the same shell command:

```sh
RZV="${RZV_BIN:-$(command -v rzv || echo "$HOME/.local/bin/rzv")}"; "$RZV" --version
```

If that fails, stop and tell the user to install rzv (0.26.0 or later), then run `rzv login`:
`curl -fsSL https://runzivo.dev/downloads/rzv/install.sh | sh`. rzv needs network access; `ssh`, `scp` and `rsync` to `<sandbox-id>.rzv` do too. Ask the user to approve running them outside the Codex sandbox when prompted.

## Errors

rzv prints `{"error":"<code>","message":"..."}` with `--json`. Show the message and the next step:

- `authentication_required` or `reauth_required`: ask the user to run `rzv login` in their terminal. Never ask for a token.
- `credit_exhausted`: the workspace is out of credit; the owner adds credit in the Runzivo portal.
- `sandbox_limit_reached`: the workspace runs its maximum; stop or delete one (`$runzivo:status` lists them).
- `no_capacity` or `sandbox_capacity_busy`: Runzivo is busy; retry in a few minutes.
- `not_found`: the id is wrong or the sandbox was deleted; list sandboxes again.

Never print, store or pass on Runzivo or AI provider credentials.
