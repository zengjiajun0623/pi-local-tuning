# Pi extensions from this tuning work

Two small Pi extensions, each a single file. They only take effect for the
models you point them at, so they are safe alongside other providers.

## Install

Copy the `.ts` files into Pi's extensions directory:

```bash
mkdir -p ~/.pi/agent/extensions
cp model-prompts.ts bash-default-timeout.ts ~/.pi/agent/extensions/
```

Pi loads them on next start. Both read config from environment variables, so
you can set them in your shell profile or a systemd environment block.

## model-prompts.ts

Per-provider instructions instead of a global `AGENTS.md`. Before each run, if
`<dir>/<provider>.md` exists for the active model's provider (for example
`halo.md` for a local Qwen), its text becomes the `model_guidance`
system-prompt section. Other providers get Pi's default prompt unchanged.

- Config (env): `PI_MODEL_PROMPTS_DIR`, default `~/.pi/agent/model-prompts`.
  Point it at another directory to A/B a variant; an empty directory disables it.
- Put your prompt files in that directory named `<provider>.md`, where
  `<provider>` is the provider key from `~/.pi/agent/models.json`.
- A ready-made prompt for a local Qwen-style model is in `../prompts/halo.md`.

Note: editing the prompt file busts the server's prefix cache once, so change
it deliberately, not constantly.

## bash-default-timeout.ts

Gives model-issued bash calls a default timeout. Pi's bash tool has no default
timeout, so a command that runs far longer than expected (for example an
O(n^2) script on a big input) blocks the agent until someone notices. With a
default, the model gets "Command timed out after N seconds" and can retry on
smaller input or pass a larger `timeout` explicitly.

- Config (env): `PI_BASH_DEFAULT_TIMEOUT` seconds, default 120; 0 disables.
- Calls that already set `timeout` are left alone. User `!` commands are not
  tool calls and are unaffected.
- Measured motivation: the local Qwen never sets a bash `timeout` itself, while
  a cloud model did on its own.
