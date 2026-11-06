# Troubleshooting

| Message | What to do |
| --- | --- |
| rzv not found | Install it: `curl -fsSL https://runzivo.dev/downloads/rzv/install.sh \| sh`, or set `RZV_BIN` |
| `authentication_required`, `reauth_required` | Run `rzv login` in your terminal |
| `credit_exhausted` | The workspace is out of credit; its owner adds credit in the Runzivo portal |
| `sandbox_limit_reached` | Stop or delete a running sandbox first |
| `no_capacity`, `sandbox_capacity_busy` | Runzivo is busy; try again in a few minutes |
| `sandbox_wrong_state` | The sandbox is changing state; check status and retry |
| `sandbox_expired` | It reached its lifetime; create a new one |
| `not_found` | Wrong id, or it was deleted; ask for status |

## Codex cannot run rzv

Codex runs commands in its own sandbox, which blocks the network. Approve `rzv`, `ssh`, `scp` and `rsync` when Codex asks, or allow network access for the session.

## SSH asks for a password or fails host checks

Run `rzv sandboxes ssh-config <sandbox-id> --write` again. It renews the certificate and host settings. Check `~/.ssh/config` includes `~/.ssh/rzv/*.conf`.

Back to the [README](../README.md).
