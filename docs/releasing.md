# Releasing

1. Bump `version` in `plugins/runzivo/.codex-plugin/plugin.json` and add a `CHANGELOG.md` entry.
2. Merge to `main` after `check` passes.
3. Tag `vX.Y.Z` on `main` and push the tag. Users install it with `codex plugin marketplace add Runzivo/rzv-codex-plugin --ref vX.Y.Z`.
4. Run the live test against the tag: `E2E_SOURCE=Runzivo/rzv-codex-plugin@vX.Y.Z scripts/20-shared-e2e.sh`.
5. Create a GitHub release for the tag.

## Plugin Directory

The plugin is submitted to the OpenAI Plugin Directory as a skills-only plugin. Because it runs `rzv` on your computer it sets `requires_local_executor`, so the directory lists it as **Desktop only**. Upload a ZIP of `plugins/runzivo/` (`scripts/30-package.sh`) in the [plugin submission portal](https://developers.openai.com/plugins/deploy/submission).

Back to the [README](../README.md).
