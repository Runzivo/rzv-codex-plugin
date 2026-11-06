---
name: status
description: "Show Runzivo sandboxes with their status, expiry, time left and recorded usage. Use when the user asks what sandboxes they have, how long one has left or how much it has run."
---

# Runzivo sandbox status

1. List: `"$RZV" sandboxes list --json`. Skip `deleted` and `expired` sandboxes unless asked.
2. For one sandbox: `"$RZV" sandboxes get <sandbox-id> --json`.
3. Show a short table from `sandbox` fields: `name`, `id`, `status`, `size`, `expires_at`, time left from `remaining_seconds` (hours and minutes), and usage from `credits_used` (equivalent minutes). `expires_at` is empty until the sandbox first runs; the timer starts then.
4. The workspace limit is `max_running` in the list output. For the account balance, point the user to `rzv billing` or the Runzivo portal.

When `expires_at` passes the sandbox stops and all its files, including `/workspace`, are deleted. A missing field from an older Runzivo service shows as `-`.

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
