# rzv-codex-plugin agent guide

Runzivo-wide rules: [rzv-business/operating-policy.md](https://github.com/Runzivo/rzv-business/blob/main/operating-policy.md). This file adds only plugin guidance.

- The plugin is skills only: Markdown and manifests, no bundled code, hooks, apps or MCP servers. Lifecycle logic belongs in `rzv` (Runzivo/rzv-cli).
- Skills call only `rzv`, `ssh`, `scp` and `rsync`. No API calls, no stored tokens, no AI provider keys, nothing that reads the user's code.
- Sandboxes the plugin creates are named `codex-<slug>`.
- Listing text has no prices, plans or credit offers.
- Run `scripts/10-check.sh` before every push and the live test in docs/testing.md before a release.
- The repository is public: no internal hostnames, inventory, secrets or unreleased plans. Docs stay under 60 lines per file.
