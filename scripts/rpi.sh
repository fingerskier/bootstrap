#!/usr/bin/env bash
# rpi.sh — idempotent dev/edge bootstrap for Raspberry Pi 5 on Pi OS.
#
# Skips desktop-only stuff (VS Code apt repo, casks). Adds Pi-only
# bits: GPIO libs, raspi-config interface toggles, eeprom update.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/rpi.sh | bash

set -euo pipefail

log()  { printf '\033[36m>> %s\033[0m\n' "$*"; }
skip() { printf '\033[90m   %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

if ! have apt; then
    echo "This script targets Raspberry Pi OS (apt). Bailing." >&2
    exit 1
fi

# Sanity warn if not on Pi hardware (allow override).
if [ -r /proc/device-tree/model ]; then
    model=$(tr -d '\0' </proc/device-tree/model)
    case "$model" in
        *"Raspberry Pi"*) : ;;
        *) echo "Warning: /proc/device-tree/model = $model (not a Pi). Continuing." >&2 ;;
    esac
fi

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

log "apt update + upgrade"
sudo apt-get update
sudo apt-get -y full-upgrade

log "Pi EEPROM update (safe to re-run)"
sudo rpi-eeprom-update -a || true

apt_install \
    build-essential git gh curl ca-certificates gnupg wget unzip \
    neovim tmux direnv \
    ripgrep fd-find bat jq fzf zoxide \
    python3-venv python3-pip \
    i2c-tools libgpiod2 python3-libgpiod

# Shim fd / bat names.
mkdir -p "$HOME/.local/bin"
if have fdfind && ! have fd;  then ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd";  fi
if have batcat && ! have bat; then ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"; fi

# Enable common interfaces non-interactively (0 = enable in raspi-config nonint).
if have raspi-config; then
    log "Enabling I2C, SPI, SSH"
    sudo raspi-config nonint do_i2c 0 || true
    sudo raspi-config nonint do_spi 0 || true
    sudo raspi-config nonint do_ssh 0 || true
fi

# Starship
if ! have starship; then
    log "Installing starship"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# uv (Python)
if ! have uv; then
    log "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
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

# AWS CLI v2 (aarch64 zip installer)
if have aws; then
    skip "aws cli already installed"
else
    log "Installing AWS CLI v2 (aarch64)"
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o /tmp/awscliv2.zip
    unzip -q /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install --update
    rm -rf /tmp/awscliv2.zip /tmp/aws
fi

# AI dev CLIs once npm exists.
if have npm; then
    for p in @anthropic-ai/claude-code @openai/codex @google/gemini-cli \
             xlii wrangler underrow; do
        if npm ls -g --depth=0 "$p" >/dev/null 2>&1; then
            skip "npm -g: $p already installed"
        else
            log "npm -g: $p"
            npm install -g "$p"
        fi
    done
fi

cat <<'EOF'

Done. Add the following to your ~/.bashrc if not present:

  export PATH="$HOME/.local/bin:$PATH"
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  eval "$(starship init bash)"
  eval "$(zoxide init bash)"
  eval "$(direnv hook bash)"

Pi-specific reminders:
  - Pi 5 uses lgpio / gpiozero, NOT RPi.GPIO.
  - See rpi.md §8 for SSH hardening (key-only auth).
EOF
