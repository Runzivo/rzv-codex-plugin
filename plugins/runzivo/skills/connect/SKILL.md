---
name: connect
description: "Connect to a Runzivo sandbox over SSH: run commands in it, copy files in or out, or open a shell. Use when the user wants to work inside an existing Runzivo sandbox."
---

# Connect to a Runzivo sandbox

1. Find the sandbox: `"$RZV" sandboxes list --json`. Use the one the user named; if several are `running`, ask which. If it is `stopped`, offer to wake it with `$runzivo:sleep-wake`.
2. Make sure the SSH alias exists (safe to repeat): `"$RZV" sandboxes ssh-config <sandbox-id> --write`.
3. Run commands with `ssh -o BatchMode=yes <sandbox-id>.rzv '<command>'`. Work in `/workspace`.
4. Copy files only when the user asks: `scp -r <path> <sandbox-id>.rzv:/workspace/` or `rsync -a <path>/ <sandbox-id>.rzv:/workspace/<dir>/`.
5. For an interactive shell, tell the user to run `ssh <sandbox-id>.rzv` or `rzv sandboxes ssh <sandbox-id>` in their own terminal. Editors with Remote SSH can use the same host.

Each connection gets a 15-minute SSH certificate from rzv, renewed automatically. Agent forwarding is off; set up any Git or AI tool sign-in inside the sandbox yourself, never by copying keys from this machine.

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
