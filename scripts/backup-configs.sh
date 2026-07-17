#!/usr/bin/env bash
set -euo pipefail

FORGE_ROOT="${FORGE_ROOT:-/opt/forge}"
BACKUP_DIR="$FORGE_ROOT/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="$BACKUP_DIR/forge-configs-$STAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "==> Creating backup: $ARCHIVE"
if [[ "${EUID}" -eq 0 ]]; then
  TAR=(tar)
else
  TAR=(sudo tar)
fi

"${TAR[@]}" \
  --exclude="$FORGE_ROOT/backups" \
  -czf "$ARCHIVE" \
  -C "$FORGE_ROOT" \
  homeassistant \
  homepage \
  mosquitto \
  node-red \
  uptime-kuma

if [[ "${EUID}" -ne 0 ]]; then
  sudo chown "$USER:$USER" "$ARCHIVE"
fi

echo "==> Backup complete"
ls -lh "$ARCHIVE"
