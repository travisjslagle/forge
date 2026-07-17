#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_DIR="$REPO_ROOT/compose"

echo "==> Host"
hostnamectl --static || hostname

echo
echo "==> IP addresses"
hostname -I || true

echo
echo "==> Docker"
docker --version
docker compose version

echo
echo "==> Services"
docker compose --env-file "$COMPOSE_DIR/.env" -f "$COMPOSE_DIR/docker-compose.yml" ps

echo
echo "==> Tailscale"
if command -v tailscale >/dev/null 2>&1; then
  tailscale status || true
else
  echo "Tailscale is not installed yet."
fi

echo
echo "==> Listening ports"
ss -tulpn | grep -E ':(1880|1883|3000|3001|8123)\b' || true

