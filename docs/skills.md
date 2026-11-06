# Skills and commands

Every skill finds `rzv` in `RZV_BIN`, then `PATH`, then `~/.local/bin/rzv`, and runs only these commands:

| Skill | rzv commands |
| --- | --- |
| `create` | `sandboxes sizes`, `sandboxes create --name codex-<slug> --size --lifetime`, `sandboxes get`, `sandboxes ssh-config <id> --write` |
| `connect` | `sandboxes list`, `sandboxes ssh-config <id> --write`, then `ssh`, `scp` or `rsync` to `<id>.rzv` |
| `status` | `sandboxes list`, `sandboxes get` |
| `sleep-wake` | `sandboxes stop`, `sandboxes start`, `sandboxes get` |
| `delete` | `sandboxes list`, `sandboxes delete` (after you confirm) |

## Sizes and lifetimes

Sizes are `2vcpu-8gb` (default), `4vcpu-16gb`, `8vcpu-32gb` and `16vcpu-64gb`. `rzv sandboxes sizes` shows what your environment offers. The lifetime is `8h` (default), `12h` or `24h` and cannot be extended. When it ends the sandbox stops and its temporary files are deleted.

## Sleep and wake

Sleep stops the sandbox's compute and ends running processes. Files in `/workspace` are kept and come back on wake. Keep your work in `/workspace`. The lifetime timer keeps running while the sandbox sleeps.

## Status and usage

`status` shows each sandbox's state, size, expiry, time left and the usage it has recorded (`credits_used` in `rzv sandboxes get --json`). Runzivo meters running sandboxes in equivalent minutes from your workspace; see `rzv billing` or the Runzivo portal.

## Running Codex inside a sandbox

Every sandbox includes Codex. Sign in there with your own account; see [Codex in a sandbox](https://github.com/Runzivo/rzv-cli/blob/main/docs/codex.md).

Back to the [README](../README.md).
