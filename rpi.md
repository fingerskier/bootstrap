# Raspberry Pi 5 (Raspberry Pi OS — Bookworm or newer)

Fresh Pi → working dev / edge box. Pi OS is Debian-based, so much of
[`linux.md`](./linux.md) applies — this file calls out the Pi-specific
bits and skips the desktop-only stuff.

Target: Raspberry Pi 5, 64-bit Pi OS, current release.

## 0. Pre-image (on your laptop)

Use **Raspberry Pi Imager**, "Edit settings" before write:

- Hostname (set whatever; not stored here).
- Enable SSH, set username + password.
- Configure Wi-Fi if not on Ethernet.
- Locale / keyboard layout.

This avoids ever needing a monitor.

## 1. First boot

```sh
ssh <you>@<host>.local
sudo apt update && sudo apt -y full-upgrade
sudo rpi-eeprom-update -a   # firmware
sudo reboot
```

## 2. One-shot bootstrap (optional)

```sh
curl -fsSL https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/rpi.sh | bash
```

## 3. Core packages

```sh
sudo apt -y install \
  build-essential git gh curl ca-certificates unzip \
  neovim tmux direnv \
  ripgrep fd-find bat jq fzf zoxide \
  python3-venv python3-pip
```

`fd` / `bat` aliasing note: same as in [`linux.md`](./linux.md#2-core-packages-apt).

Starship:

```sh
curl -sS https://starship.rs/install.sh | sh
```

## 4. Runtimes

### Python

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
uv python install 3.12
```

### Node (arm64)

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# Reopen shell.
nvm install --lts
nvm use --lts
```

## 5. Headless extras

```sh
# Pi-specific tools
sudo apt -y install i2c-tools libgpiod2 python3-libgpiod

# Enable interfaces non-interactively
sudo raspi-config nonint do_i2c 0    # 0 = enable
sudo raspi-config nonint do_spi 0
sudo raspi-config nonint do_ssh 0
```

For GPIO from Python on Pi 5, use [`gpiozero`](https://gpiozero.readthedocs.io)
or [`lgpio`](https://abyz.me.uk/lg/py_lgpio.html). RPi.GPIO is **not**
supported on Pi 5 — the chip changed.

```sh
uv tool install --python 3.12 gpiozero lgpio
```

## 6. AWS CLI

```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update
rm -rf /tmp/awscliv2.zip /tmp/aws
```

## 7. AI dev CLIs

Same as Linux — once Node is installed:

```sh
npm i -g @anthropic-ai/claude-code @openai/codex @google/gemini-cli
```

(Heads-up: these CLIs are fine on Pi 5's 8GB model. Don't expect a
great time on a Zero 2 W.)

## 8. Tighten it up

```sh
# Unattended security upgrades
sudo apt -y install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# SSH hardening: drop password auth once you've copied a key
ssh-copy-id <you>@<host>.local
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

## 9. Shell prompt

In `~/.bashrc`:

```sh
eval "$(starship init bash)"
eval "$(zoxide init bash)"
eval "$(direnv hook bash)"
```

## 10. Smoke test

```sh
git --version && gh --version && node --version && python3 --version \
  && nvim --version | head -n1 && aws --version
uname -m   # should be aarch64
```
