# Linux (Debian / Ubuntu)

Fresh install → working dev box. See [`GENERAL.md`](./GENERAL.md) for
philosophy and the full tool index. Tested on Ubuntu 24.04 and Debian
12; commands assume `apt`.

For Raspberry Pi OS specifically, see [`rpi.md`](./rpi.md).

## 0. Prereqs

```sh
sudo apt update && sudo apt -y full-upgrade
sudo apt -y install build-essential curl git ca-certificates gnupg unzip
```

## 1. One-shot bootstrap (optional)

```sh
curl -fsSL https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/linux.sh | bash
```

## 2. Core packages (apt)

```sh
sudo apt -y install \
  gh neovim tmux direnv \
  ripgrep fd-find bat jq \
  zoxide fzf
```

> Debian/Ubuntu ship `fd` as `fdfind` and `bat` as `batcat`. Add
> aliases in your shell rc, or symlink them once:
> ```sh
> mkdir -p ~/.local/bin
> ln -sf "$(command -v fdfind)" ~/.local/bin/fd
> ln -sf "$(command -v batcat)" ~/.local/bin/bat
> ```

### Things apt has but stale, or lacks

```sh
# Starship
curl -sS https://starship.rs/install.sh | sh

# eza (modern ls) — has its own repo
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
  | sudo tee /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt -y install eza

# git-delta
DELTA_VER=0.18.2
curl -fsSL -o /tmp/delta.deb \
  "https://github.com/dandavison/delta/releases/download/${DELTA_VER}/git-delta_${DELTA_VER}_amd64.deb"
sudo dpkg -i /tmp/delta.deb
```

## 3. Runtimes

### Python

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
uv python install 3.12
```

### Node

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# Reopen shell.
nvm install --lts
nvm use --lts
```

### Rust (optional)

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## 4. AI dev CLIs

```sh
npm i -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli
```

## 5. JS/TS niche tools

```sh
npm i -g xlii wrangler underrow
```

## 6. VS Code

```sh
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] \
  https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt -y install code
```

Then launch `code`, sign in, and let Settings Sync pull your extensions
and config. The repo does not curate an extension list.

## 7. AWS CLI

```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update
rm -rf /tmp/awscliv2.zip /tmp/aws
```

## 8. Shell prompt

In `~/.bashrc` or `~/.zshrc`:

```sh
eval "$(starship init bash)"     # or zsh
eval "$(zoxide init bash)"
eval "$(direnv hook bash)"
```

## 9. Git baseline

```sh
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor "code --wait"
```

Set `user.name` and `user.email` yourself.

## 10. Smoke test

```sh
git --version && gh --version && node --version && python3 --version \
  && code --version && nvim --version | head -n1 && aws --version
```
