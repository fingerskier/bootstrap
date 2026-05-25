# Windows 11

Fresh install → working dev box. See [`GENERAL.md`](./GENERAL.md) for
philosophy and the full tool index.

## 0. Prereqs

- Windows 11 (any edition). Sign in with the account you'll use.
- Run an elevated **PowerShell 7** when you see `pwsh>`. Stock
  `powershell.exe` (5.1) works for almost everything in this guide,
  but pwsh is what you'll want long-term.

```pwsh
# Verify winget exists (ships with App Installer).
winget --version
```

If `winget` is missing: install **App Installer** from the Microsoft
Store, then reopen the terminal.

## 1. One-shot bootstrap (optional)

```pwsh
# From an elevated pwsh:
irm https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/win11.ps1 | iex
```

That script does everything in §2–§4 and §10 idempotently. Read it
before running.

## 2. Core packages (winget)

```pwsh
winget install --id Git.Git -e
winget install --id GitHub.cli -e
winget install --id Microsoft.PowerShell -e
winget install --id Microsoft.WindowsTerminal -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Neovim.Neovim -e
winget install --id Starship.Starship -e
winget install --id junegunn.fzf -e
winget install --id BurntSushi.ripgrep.MSVC -e
winget install --id sharkdp.fd -e
winget install --id sharkdp.bat -e
winget install --id eza-community.eza -e
winget install --id jqlang.jq -e
winget install --id MikeFarah.yq -e
winget install --id ajeetdsouza.zoxide -e
winget install --id dandavison.delta -e
```

## 3. Runtimes

### Python

Prefer [`uv`](https://github.com/astral-sh/uv) — it manages
interpreters and venvs in one binary.

```pwsh
winget install --id astral-sh.uv -e
uv python install 3.12
```

### Node

`nvm-windows` is the pragmatic choice on Win11.

```pwsh
winget install --id CoreyButler.NVMforWindows -e
# Reopen terminal so nvm is on PATH.
nvm install lts
nvm use lts
```

### Rust (optional)

```pwsh
winget install --id Rustlang.Rustup -e
rustup default stable
```

## 4. AI dev CLIs

After Node is installed:

```pwsh
npm i -g @anthropic-ai/claude-code
npm i -g @openai/codex
npm i -g @google/gemini-cli
```

## 5. JS/TS niche tools

```pwsh
npm i -g xlii wrangler underrow
```

## 6. WSL2 (recommended)

```pwsh
wsl --install -d Ubuntu
# Reboot, finish Ubuntu first-run, then inside WSL follow linux.md.
```

## 7. Editor setup

- **VS Code** — launch it, sign in, let Settings Sync pull your
  extensions and config. The repo does not curate an extension list.
- **Neovim** — drop a minimal `init.lua` into `$env:LOCALAPPDATA\nvim\`.

## 8. Shell prompt

In your `$PROFILE` (run `notepad $PROFILE` to create/edit):

```pwsh
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
```

## 9. Git baseline

```pwsh
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.autocrlf input
git config --global core.editor "code --wait"
```

Set `user.name` and `user.email` yourself — not in this repo.

## 10. AWS CLI

Install the official AWS CLI v2 MSI:

```pwsh
$msi = "$env:TEMP\AWSCLIV2.msi"
Invoke-WebRequest -Uri https://awscli.amazonaws.com/AWSCLIV2.msi -OutFile $msi
Start-Process msiexec.exe -Wait -ArgumentList "/i $msi /qn"
Remove-Item $msi
```

## 11. Smoke test

```pwsh
git --version
gh --version
node --version
python --version
code --version
nvim --version | Select-Object -First 1
aws --version
```

All six should print versions. If any fail, restart the terminal so
PATH refreshes and try again.
