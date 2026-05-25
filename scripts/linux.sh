#!/usr/bin/env bash
# linux.sh — idempotent dev-box bootstrap for Debian/Ubuntu.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/linux.sh | bash
#
# Read before piping curl into bash. Always.

set -euo pipefail

log()  { printf '\033[36m>> %s\033[0m\n' "$*"; }
skip() { printf '\033[90m   %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

require_apt() {
    if ! have apt; then
        echo "This script targets Debian/Ubuntu (apt). Bailing." >&2
        exit 1
    fi
}

apt_install() {
    local missing=()
    for p in "$@"; do
        if ! dpkg -s "$p" >/dev/null 2>&1; then
            missing+=("$p")
        else
            skip "apt: $p already installed"
        fi
    done
    if [ "${#missing[@]}" -gt 0 ]; then
        log "apt install: ${missing[*]}"
        sudo apt-get install -y "${missing[@]}"
    fi
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

require_apt

log "apt update + upgrade"
sudo apt-get update
sudo apt-get -y full-upgrade

apt_install \
    build-essential curl git ca-certificates gnupg wget \
    gh neovim tmux direnv \
    ripgrep fd-find bat jq fzf zoxide

# Shim fd / bat names if they came in as fdfind / batcat.
mkdir -p "$HOME/.local/bin"
if have fdfind  && ! have fd;  then ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd";  fi
if have batcat  && ! have bat; then ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"; fi

# Starship
if ! have starship; then
    log "Installing starship"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# eza (custom apt repo)
if ! have eza; then
    log "Adding eza apt repo"
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo apt-get update
    sudo apt-get -y install eza
fi

# uv (Python)
if ! have uv; then
    log "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # uv installs to ~/.local/bin; PATH will pick it up next shell.
    export PATH="$HOME/.local/bin:$PATH"
fi
have uv && uv python install 3.12 || true

# nvm + Node
if [ ! -d "$HOME/.nvm" ]; then
    log "Installing nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090,SC1091
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
if have nvm; then
    log "nvm install --lts"
    nvm install --lts
    nvm use --lts
fi

# npm globals
if have npm; then
    for p in @anthropic-ai/claude-code @openai/codex @google/gemini-cli \
             xlii wrangler underrow; do
        npm_global "$p"
    done
fi

cat <<'EOF'

Done. Add the following to your ~/.bashrc (or ~/.zshrc) if not present:

  export PATH="$HOME/.local/bin:$PATH"
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  eval "$(starship init bash)"
  eval "$(zoxide init bash)"
  eval "$(direnv hook bash)"

Optional next steps live in linux.md (Docker, VS Code apt repo).
EOF
