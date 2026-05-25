# macOS

Fresh install → working dev box. See [`GENERAL.md`](./GENERAL.md) for
philosophy and the full tool index.

## 0. Prereqs

```sh
xcode-select --install    # Command Line Tools (git, clang, make)
```

Install Homebrew:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the post-install hints to add brew to your PATH (Apple silicon
puts it under `/opt/homebrew`).

## 1. One-shot bootstrap (optional)

```sh
curl -fsSL https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/macos.sh | bash
```

Read the script before piping curl into bash. Always.

## 2. Core packages (brew)

```sh
brew install \
  git gh lazygit \
  starship fzf zoxide direnv \
  ripgrep fd bat eza jq yq git-delta \
  neovim tmux \
  uv pnpm
brew install --cask visual-studio-code iterm2
```

## 3. Runtimes

### Python

```sh
uv python install 3.12
```

### Node

```sh
brew install nvm
mkdir -p ~/.nvm
# Add to ~/.zshrc:
#   export NVM_DIR="$HOME/.nvm"
#   [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh"
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

## 6. Shell prompt

In `~/.zshrc`:

```sh
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```

Then run `$(brew --prefix)/opt/fzf/install` to wire up Ctrl-R and
Ctrl-T.

## 7. Editor setup

Launch VS Code, sign in, let Settings Sync pull your extensions and
config. The repo does not curate an extension list.

## 8. AWS CLI

```sh
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o /tmp/AWSCLIV2.pkg
sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
rm /tmp/AWSCLIV2.pkg
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
