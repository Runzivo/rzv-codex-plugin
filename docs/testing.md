# Testing

CI (`check`) validates the manifests and skills and runs shellcheck: `scripts/10-check.sh`.

## Live test

`scripts/20-shared-e2e.sh` installs the plugin into a throwaway Codex home and runs each skill through `codex exec`, checking the result with `rzv`:

1. `create` makes `codex-e2e-<time>` (2vcpu-8gb, 8h) and it runs.
2. `connect` writes and runs a Python file in `/workspace`.
3. `status` shows the sandbox; expiry, time left and usage are set.
4. `sleep-wake` stops it; usage does not grow while stopped.
5. `sleep-wake` starts it; `/workspace` is kept and usage grows again.
6. `delete` deletes it after the prompt confirms.
7. Signed out, `status` tells you to run `rzv login`.

```sh
OPENAI_KEY_FILE=<mode-600 key file> RZV_PROFILE=<test profile> scripts/20-shared-e2e.sh
```

It aborts unless `rzv whoami` shows the test environment (`E2E_ENV`, default `shared`). The key reaches Codex on stdin and is deleted with the Codex home. `E2E_SOURCE=Runzivo/rzv-codex-plugin@v0.1.0` tests the published tag instead of the checkout. Use a cheap model (`E2E_MODEL`, default `gpt-5-nano`).

Back to the [README](../README.md).
