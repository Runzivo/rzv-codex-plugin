---
name: delete
description: "Delete a Runzivo sandbox and everything on it, after the user confirms. Use when the user wants to remove, destroy or clean up a sandbox."
---

# Delete a Runzivo sandbox

Deleting removes the sandbox and all its files, including `/workspace`. It cannot be undone.

1. Find it: `"$RZV" sandboxes list --json`. Show its name, id and status.
2. Ask the user to confirm deleting that exact sandbox. Do not delete without a clear yes, and never delete sandboxes the user did not name.
3. Delete: `"$RZV" sandboxes delete <sandbox-id> --json`. The status becomes `deleting`, then `deleted`.
4. Remove its SSH alias: `rm -f ~/.ssh/rzv/<sandbox-id>.conf`.

Charges stop when the delete starts.

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
