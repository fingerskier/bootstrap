#!/usr/bin/env bash
# macos.sh — idempotent dev-box bootstrap for macOS.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/macos.sh | bash
#
# Read before piping curl into bash. Always.

set -euo pipefail

log()  { printf '\033[36m>> %s\033[0m\n' "$*"; }
skip() { printf '\033[90m   %s\033[0m\n' "$*"; }

have() { command -v "$1" >/dev/null 2>&1; }

ensure_brew() {
    if have brew; then return; fi
    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for this session (Apple silicon default).
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

brew_install() {
    local pkg=$1
    if brew list --formula "$pkg" >/dev/null 2>&1; then
        skip "brew: $pkg already installed"
        return
    fi
    log "brew: $pkg"
    brew install "$pkg"
}

brew_cask() {
    local pkg=$1
    if brew list --cask "$pkg" >/dev/null 2>&1; then
        skip "cask: $pkg already installed"
        return
    fi
    log "cask: $pkg"
    brew install --cask "$pkg"
}

npm_global() {
    local pkg=$1
    if npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
        skip "npm -g: $pkg already installed"
        return
    fi
    log "npm -g: $pkg"
    npm install -g "$pkg"
}

# --- Xcode CLT ---
if ! xcode-select -p >/dev/null 2>&1; then
    log "Installing Xcode Command Line Tools (GUI prompt may appear)"
    xcode-select --install || true
fi

ensure_brew

# --- formulae ---
for f in git gh lazygit \
         starship fzf zoxide direnv \
         ripgrep fd bat eza jq yq git-delta \
         neovim tmux \
         uv nvm pnpm; do
    brew_install "$f"
done

# --- casks ---
for c in visual-studio-code iterm2; do
    brew_cask "$c"
done

# --- AWS CLI v2 (official pkg) ---
if have aws; then
    skip "aws cli already installed"
else
    log "Installing AWS CLI v2 (pkg)"
    curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o /tmp/AWSCLIV2.pkg
    sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
    rm -f /tmp/AWSCLIV2.pkg
fi

# --- Python ---
if have uv; then
    log "uv python install 3.12"
    uv python install 3.12 || true
fi

# --- Node via nvm ---
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
NVM_SH="$(brew --prefix)/opt/nvm/nvm.sh"
# shellcheck disable=SC1090
[ -s "$NVM_SH" ] && . "$NVM_SH"

if have nvm; then
    log "nvm install --lts"
    nvm install --lts
    nvm use --lts
fi

# --- npm globals ---
if have npm; then
    for p in @anthropic-ai/claude-code @openai/codex @google/gemini-cli \
             xlii wrangler underrow; do
        npm_global "$p"
    done
else
    echo "npm not on PATH yet — open a new shell after sourcing nvm and re-run."
fi

cat <<'EOF'

Done. Add the following to your ~/.zshrc if not already present:

  export NVM_DIR="$HOME/.nvm"
  [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh"
  eval "$(starship init zsh)"
  eval "$(zoxide init zsh)"
  eval "$(direnv hook zsh)"

Then open a new terminal and follow macos.md §9 (smoke test).
EOF
