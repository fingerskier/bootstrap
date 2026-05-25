# GENERAL

Cross-OS principles and the tool index. Per-OS install steps live in
[`win11.md`](./win11.md), [`macos.md`](./macos.md),
[`linux.md`](./linux.md), [`rpi.md`](./rpi.md).

## Principles

1. **Package managers over installers.** `winget`, `brew`, `apt` — let
   the OS track versions. Reach for an `.exe`/`.dmg`/`.deb` only when
   no package exists.
2. **Version managers for runtimes.** Python via `pyenv` (or `uv`),
   Node via `nvm` (or `fnm`). Never the system interpreter for project
   work.
3. **Idempotent bootstrap.** Scripts in [`scripts/`](./scripts) should
   be safe to re-run. Detect-then-install; never assume a clean box.
4. **Public, no secrets.** This repo is intentionally public. No tokens,
   no hostnames, no personal paths. Everything here should be useful
   to a stranger.
5. **Shell hygiene.** Use a real prompt (Starship or similar), enable
   history search (`fzf` Ctrl-R), and standardize on one POSIX shell
   plus PowerShell 7 on Windows.
6. **One editor config per family.** VS Code `settings.json` and a
   minimal Neovim `init.lua` — kept in sync via dotfiles where
   reasonable.

## Tool index

### Runtimes

| Tool        | Why                                  | Install via            |
|-------------|--------------------------------------|------------------------|
| Python 3.12+| General scripting, ML, tooling       | `pyenv` / `uv`         |
| Node LTS    | JS/TS, CLIs, build tools             | `nvm` / `fnm`          |
| Rust        | `cargo` for system CLIs (rg, fd, …)  | `rustup`               |
| Go          | Some CLIs (gh extensions, etc.)      | OS pkg manager         |

### Source control

| Tool   | Why                                       |
|--------|-------------------------------------------|
| `git`  | Obvious                                   |
| `gh`   | GitHub CLI — PRs, issues, gists, releases |
| `lazygit` | TUI for review/stage/commit            |

### Shell / terminal

| Tool                | Why                              |
|---------------------|----------------------------------|
| Windows Terminal    | Win11 default after install      |
| PowerShell 7        | Cross-platform pwsh              |
| Starship            | Fast, configurable prompt        |
| `fzf`               | Fuzzy finder, Ctrl-R history     |
| `zoxide`            | Smarter `cd`                     |
| `direnv`            | Per-dir env vars                 |

### File / text power tools

| Tool       | Replaces / adds                |
|------------|---------------------------------|
| `ripgrep`  | `grep -r`, faster + saner       |
| `fd`       | `find`, saner CLI               |
| `bat`      | `cat` with syntax highlighting  |
| `eza`      | `ls` with git/icons             |
| `jq`       | JSON slicing                    |
| `yq`       | YAML/TOML slicing               |
| `delta`    | Pretty git diffs                |

### Editors / IDEs

| Tool       | Notes                                       |
|------------|---------------------------------------------|
| VS Code    | Primary IDE; extension list per-OS guide    |
| Neovim     | Quick edits, SSH sessions, low-RAM boxes    |

### AI dev CLIs

| Tool          | Source                                          |
|---------------|-------------------------------------------------|
| Claude Code   | `npm i -g @anthropic-ai/claude-code`            |
| Codex CLI     | `npm i -g @openai/codex`                        |
| Gemini CLI    | `npm i -g @google/gemini-cli`                   |

### JS/TS niche

| Tool        | Why                                          |
|-------------|----------------------------------------------|
| `xlii`      | Roman numeral CLI / lib                      |
| `wrangler`  | Cloudflare Workers deploy + dev              |
| `underrow`  | Markdown knowledgebase / todo CLI            |

### Containers / cloud

| Tool             | Why                              |
|------------------|----------------------------------|
| Docker Desktop   | Local containers (Win/macOS)     |
| Docker Engine    | Linux/Pi native                  |
| `kubectl`        | If you touch a cluster           |

### Optional power-ups

- **`uv`** — fast Python package/resolver (replaces `pip`+`venv`).
- **`pnpm`** — disk-efficient Node package manager.
- **`mise`** — single tool for managing multiple runtime versions.
- **`tmux`** — terminal multiplexer (Linux/macOS/WSL).

## Workflow conventions

- All project code lives under a single top-level dev directory
  (`~/dev` on Unix, `C:\dev` on Windows). Keeps tooling, search, and
  backups predictable.
- Each project gets its own runtime version pinned in a file the
  version manager understands (`.python-version`, `.nvmrc`, etc.).
- Global npm/pip installs are limited to true CLIs. Library deps
  belong in a project.
