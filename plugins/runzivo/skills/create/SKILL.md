---
name: create
description: "Create a Runzivo cloud sandbox (a Linux microVM) with a chosen size and lifetime, and set up SSH to it. Use when the user asks for a Runzivo sandbox, cloud VM or remote machine."
---

# Create a Runzivo sandbox

1. Pick a name `codex-<slug>`: `<slug>` is 1 to 40 lowercase letters, digits or dashes from what the user asked for, for example `codex-api-tests`. Always keep the `codex-` prefix.
2. Size: `2vcpu-8gb` unless the user asks for more. `"$RZV" sandboxes sizes --json` lists the sizes on offer. Lifetime: `8h` unless the user asks for `12h` or `24h`. A lifetime cannot be extended.
3. Create it and wait for it to run:

```sh
"$RZV" sandboxes create --name codex-<slug> --size <size> --lifetime <lifetime> --json
"$RZV" sandboxes get <sandbox-id> --json
```

   Repeat `get` every 10 seconds until `sandbox.status` is `running` (up to 5 minutes). If it becomes `failed`, report `sandbox.error` and delete it.
4. Write the SSH alias: `"$RZV" sandboxes ssh-config <sandbox-id> --write`. The host is `<sandbox-id>.rzv`.
5. Tell the user the id, size, `expires_at`, and how to connect: `ssh <sandbox-id>.rzv`. Files go in `/workspace`.

Usage is billed in equivalent minutes from the workspace credit while the sandbox runs. Do not copy the user's files into the sandbox unless they ask.

## Find rzv

Run every command below with `"$RZV"`, set in the same shell command:

```sh
RZV="${RZV_BIN:-$(command -v rzv || echo "$HOME/.local/bin/rzv")}"; "$RZV" --version
```

If that fails, stop and tell the user to install rzv (0.26.0 or later), then run `rzv login`:
`curl -fsSL https://runzivo.dev/downloads/rzv/install.sh | sh`. rzv needs network access; ask the user to approve running it outside the Codex sandbox when prompted.

## Errors

rzv prints `{"error":"<code>","message":"..."}` with `--json`. Show the message and the next step:

- `authentication_required` or `reauth_required`: ask the user to run `rzv login` in their terminal. Never ask for a token.
- `credit_exhausted`: the workspace is out of credit; the owner adds credit in the Runzivo portal.
- `sandbox_limit_reached`: the workspace runs its maximum; stop or delete one (`$runzivo:status` lists them).
- `sandbox_capacity_busy` or `no_capacity`: Runzivo is busy; retry in a few minutes.
- `not_found`: the id is wrong or the sandbox was deleted; list sandboxes again.

Never print, store or pass on Runzivo or AI provider credentials.
