# bootstrap

My runbook for going from a fresh OS install to a productive dev box,
with as little ceremony as possible.

---

## Why this exists

> "My laptop died. I have a new one.  What do I install, in what order,
>  and what did I forget last time?"

---

## Layout

| File                           | Purpose                                 |
|--------------------------------|-----------------------------------------|
| [`GENERAL.md`](./GENERAL.md)   | Principles + cross-OS tool index        |
| [`win11.md`](./win11.md)       | Windows 11 step-by-step                 |
| [`macos.md`](./macos.md)       | macOS step-by-step                      |
| [`linux.md`](./linux.md)       | Debian / Ubuntu step-by-step            |
| [`rpi.md`](./rpi.md)           | Raspberry Pi 5 (Pi OS) step-by-step     |
| [`scripts/`](./scripts)        | Idempotent one-shot bootstrap scripts   |

---

## Quickstart

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
- VS Code, Neovim
- AI dev CLIs: Claude Code, Codex CLI, Gemini CLI
- AWS CLI v2

The script is the floor, not the ceiling — the per-OS guides cover
extras (WSL2, GPIO, SSH hardening, etc.) that don't belong in a
default bootstrap.

---

## Design principles

See [`GENERAL.md`](./GENERAL.md). Short version:

1. Package managers over installers.
2. Version managers for runtimes (`uv`, `nvm`).
3. Idempotent — safe to re-run.
4. Public-safe — no secrets, no personal paths.

---

## License

[MIT](./LICENSE).
