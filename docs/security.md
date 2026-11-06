# Security and privacy

## What the plugin is

Markdown skills and a manifest. No code runs except the `rzv`, `ssh`, `scp` and `rsync` commands Codex shows you, plus `rm -f ~/.ssh/rzv/<id>.conf` to remove a deleted sandbox's SSH alias. All logic is in the public [`rzv` CLI](https://github.com/Runzivo/rzv-cli).

## Credentials

- `rzv` keeps your Runzivo sign-in in its own owner-only file. The plugin never reads, prints or passes it on.
- When you are not signed in, the skills ask you to run `rzv login` yourself. They never ask for a token.
- The plugin has no AI provider keys. To use an AI tool inside a sandbox, sign in there with your own account. Never copy keys from your machine into `/workspace`.

## Your code

The plugin does not read your code. Files reach a sandbox only when you ask Codex to copy them (`scp` or `rsync` over SSH). Nothing is collected about your development activity. Sandboxes are named `codex-<slug>` so you can tell which ones Codex made.

## Access and SSH

Each `rzv` call uses Runzivo's workspace roles: you reach only sandboxes in workspaces where your role allows it. SSH uses a 15-minute user certificate, strict host checks against the Runzivo host CA, and an authenticated relay through `rzv`. Agent forwarding is off.

## Clean-up

`delete` asks you to confirm, deletes the sandbox and all its files, and removes its SSH alias. A sandbox you forget still stops at the end of its lifetime.

Back to the [README](../README.md).
