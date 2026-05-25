# bootstrap

My runbook for going from a fresh OS install to a productive dev box,
with as little ceremony as possible.

This repo is **intentionally public**. No secrets, no personal config,
no PII — just the tools, the order, and the commands. If you're a
power-dev setting up your own machine, copy what's useful and ignore
the rest.

## Why this exists

> "My laptop died. I have a new one. What do I install, in what order,
>  and what did I forget last time?"

This is the answer, kept in version control so future-me (and you) can
diff it.

## Layout

| File                                         | Purpose                                 |
|----------------------------------------------|-----------------------------------------|
| [`GENERAL.md`](./GENERAL.md)                 | Principles + cross-OS tool index        |
| [`win11.md`](./win11.md)                     | Windows 11 step-by-step                 |
| [`macos.md`](./macos.md)                     | macOS step-by-step                      |
| [`linux.md`](./linux.md)                     | Debian / Ubuntu step-by-step            |
| [`rpi.md`](./rpi.md)                         | Raspberry Pi 5 (Pi OS) step-by-step     |
| [`scripts/`](./scripts)                      | Idempotent one-shot bootstrap scripts   |
| [`scripts/vscode-extensions.txt`](./scripts/vscode-extensions.txt) | Starter VS Code extension list |

## Quickstart

Pick your OS, read the matching guide, optionally run the script.

```sh
# Windows 11 — from an elevated PowerShell:
irm https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/win11.ps1 | iex

# macOS:
curl -fsSL https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/macos.sh | bash

# Debian/Ubuntu:
curl -fsSL https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/linux.sh | bash

# Raspberry Pi 5 on Pi OS:
curl -fsSL https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/rpi.sh  | bash
```

> **Read before piping curl into a shell.** Always. These are short
> and commented for exactly that reason.

## What you get

A box with:

- `git`, `gh`, modern shell prompt (Starship), fuzzy finder, smart `cd`
- Python (via `uv`), Node (via `nvm` / `nvm-windows`), optional Rust
- The good text tools: `ripgrep`, `fd`, `bat`, `eza`, `jq`, `yq`, `delta`
- VS Code + a starter extension list, Neovim
- AI dev CLIs: Claude Code, Codex CLI, Gemini CLI
- Docker (where appropriate)

The script is the floor, not the ceiling — the per-OS guides cover
extras (WSL2, GPIO, SSH hardening, etc.) that don't belong in a
default bootstrap.

## Design principles

See [`GENERAL.md`](./GENERAL.md). Short version:

1. Package managers over installers.
2. Version managers for runtimes (`uv`, `nvm`).
3. Idempotent — safe to re-run.
4. Public-safe — no secrets, no personal paths.

## Contributing

It's my runbook, so I'm not soliciting PRs — but if you spot something
wrong (broken link, dead package ID, better tool), open an issue and
I'll take a look.

## License

[MIT](./LICENSE).
