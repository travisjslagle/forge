#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_DIR="$REPO_ROOT/compose"

if [[ ! -f "$COMPOSE_DIR/.env" ]]; then
  echo "Missing $COMPOSE_DIR/.env. Copy .env.example first."
  exit 1
fi

echo "==> Pulling container images"
docker compose --env-file "$COMPOSE_DIR/.env" -f "$COMPOSE_DIR/docker-compose.yml" pull --ignore-buildable

echo "==> Starting Forge services"
docker compose --env-file "$COMPOSE_DIR/.env" -f "$COMPOSE_DIR/docker-compose.yml" up -d --build

echo "==> Current services"
docker compose --env-file "$COMPOSE_DIR/.env" -f "$COMPOSE_DIR/docker-compose.yml" ps
