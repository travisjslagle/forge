#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_DIR="$REPO_ROOT/compose"

if [[ ! -f "$COMPOSE_DIR/.env" ]]; then
  echo "Missing $COMPOSE_DIR/.env. Copy .env.example first."
  exit 1
fi

set -a
# shellcheck disable=SC1091
source "$COMPOSE_DIR/.env"
set +a

required_vars=(
  FORGE_ROOT
  FORGE_BUDGET_SOURCE
  FORGE_BUDGET_DATA
  FORGE_LAN_IP
  FORGE_BUDGET_SESSION_SECRET
  PUID
  PGID
)

for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "Missing $var_name in $COMPOSE_DIR/.env."
    echo "Compare it with $COMPOSE_DIR/.env.example and add the new Forge Budget settings."
    exit 1
  fi
done

if [[ ! -f "$FORGE_BUDGET_SOURCE/Dockerfile" ]]; then
  echo "Forge Budget source was not found at $FORGE_BUDGET_SOURCE."
  echo "Clone https://github.com/travisjslagle/forge-budget.git there or update FORGE_BUDGET_SOURCE."
  exit 1
fi

echo "==> Syncing service config"
sudo mkdir -p \
  "$FORGE_ROOT/homepage" \
  "$FORGE_ROOT/mealie" \
  "$FORGE_ROOT/mosquitto/config" \
  "$FORGE_BUDGET_DATA"
sudo cp "$REPO_ROOT/config/homepage/settings.yaml" "$FORGE_ROOT/homepage/settings.yaml"
sudo cp "$REPO_ROOT/config/homepage/services.yaml" "$FORGE_ROOT/homepage/services.yaml"
sudo cp "$REPO_ROOT/config/mosquitto/mosquitto.conf" "$FORGE_ROOT/mosquitto/config/mosquitto.conf"
sudo chown -R "$USER:$USER" "$FORGE_ROOT/homepage" "$FORGE_ROOT/mealie" "$FORGE_ROOT/mosquitto" "$FORGE_BUDGET_DATA"

echo "==> Pulling container images"
docker compose --env-file "$COMPOSE_DIR/.env" -f "$COMPOSE_DIR/docker-compose.yml" pull --ignore-buildable

echo "==> Starting Forge services"
docker compose --env-file "$COMPOSE_DIR/.env" -f "$COMPOSE_DIR/docker-compose.yml" up -d --build

echo "==> Reloading Homepage config"
docker restart forge-homepage >/dev/null 2>&1 || true

echo "==> Current services"
docker compose --env-file "$COMPOSE_DIR/.env" -f "$COMPOSE_DIR/docker-compose.yml" ps
