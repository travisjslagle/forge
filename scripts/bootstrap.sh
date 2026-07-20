#!/usr/bin/env bash
set -euo pipefail

FORGE_ROOT="${FORGE_ROOT:-/opt/forge}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_DIR="$REPO_ROOT/compose"

if [[ "${EUID}" -eq 0 ]]; then
  echo "Run this as your normal user with sudo privileges, not as root."
  exit 1
fi

echo "==> Updating apt packages"
sudo apt-get update

echo "==> Installing host packages"
sudo apt-get install -y \
  ca-certificates \
  curl \
  git \
  gnupg \
  lsb-release \
  restic \
  ufw \
  avahi-daemon \
  openssh-server

if ! command -v docker >/dev/null 2>&1; then
  echo "==> Installing Docker using Docker's convenience installer"
  curl -fsSL https://get.docker.com | sudo sh
fi

echo "==> Enabling Docker"
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

echo "==> Preparing Forge directories at $FORGE_ROOT"
sudo mkdir -p \
  /srv/forge-data/budget \
  "$FORGE_ROOT/backups" \
  "$FORGE_ROOT/homeassistant" \
  "$FORGE_ROOT/homepage" \
  "$FORGE_ROOT/mosquitto/config" \
  "$FORGE_ROOT/mosquitto/data" \
  "$FORGE_ROOT/mosquitto/log" \
  "$FORGE_ROOT/node-red" \
  "$FORGE_ROOT/uptime-kuma"

sudo cp "$REPO_ROOT/config/mosquitto/mosquitto.conf" "$FORGE_ROOT/mosquitto/config/mosquitto.conf"
sudo cp "$REPO_ROOT/config/homepage/settings.yaml" "$FORGE_ROOT/homepage/settings.yaml"
sudo cp "$REPO_ROOT/config/homepage/services.yaml" "$FORGE_ROOT/homepage/services.yaml"
sudo chown -R "$USER:$USER" "$FORGE_ROOT"
sudo chown -R "$USER:$USER" /srv/forge-data/budget

if [[ ! -f "$COMPOSE_DIR/.env" ]]; then
  echo "==> Creating compose/.env from example"
  cp "$COMPOSE_DIR/.env.example" "$COMPOSE_DIR/.env"
fi

echo "==> Configuring UFW firewall"
sudo ufw allow OpenSSH
sudo ufw allow 3000/tcp comment "Forge Homepage"
sudo ufw allow 8123/tcp comment "Home Assistant"
sudo ufw allow 1880/tcp comment "Node-RED"
sudo ufw allow 1883/tcp comment "MQTT"
sudo ufw allow 3001/tcp comment "Uptime Kuma"
sudo ufw allow from 192.168.50.0/24 to any port 3010 proto tcp comment "Forge Budget LAN"
sudo ufw --force enable

echo "==> Bootstrap complete"
echo "Log out and back in before running Docker without sudo, then run:"
echo "  cd $REPO_ROOT"
echo "  ./scripts/update-forge.sh"
