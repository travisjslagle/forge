# Recovery

Forge should be rebuildable from:

1. A fresh Ubuntu Server install
2. This repo
3. A backup of `/opt/forge`
4. A backup of `/srv/forge-data/budget`

## Restore From Backup

Stop services:

```bash
cd ~/forge-infra
docker compose --env-file compose/.env -f compose/docker-compose.yml down
```

Extract a backup:

```bash
sudo tar -xzf /path/to/forge-configs-YYYYMMDD-HHMMSS.tar.gz -C /opt/forge
sudo chown -R "$USER:$USER" /opt/forge
```

Restore Forge Budget data from the latest tested encrypted backup into
`/srv/forge-data/budget`.

Start services:

```bash
./scripts/update-forge.sh
```

## Rebuild Host

1. Install Ubuntu Server.
2. Set hostname to `forge`.
3. Install SSH.
4. Clone this repo.
5. Copy `compose/.env.example` to `compose/.env`.
6. Run `./scripts/bootstrap.sh`.
7. Restore `/opt/forge` backup.
8. Run `./scripts/update-forge.sh`.

## Common Checks

```bash
systemctl status docker
docker ps
docker compose --env-file compose/.env -f compose/docker-compose.yml ps
./scripts/health-check.sh
```

## If A Service Is Broken

Inspect logs:

```bash
docker logs forge-homeassistant --tail=100
docker logs forge-node-red --tail=100
docker logs forge-uptime-kuma --tail=100
docker logs forge-mosquitto --tail=100
docker logs forge-homepage --tail=100
docker logs forge-budget --tail=100
docker logs forge-mealie --tail=100
```

Restart one service:

```bash
docker restart forge-homeassistant
```

Mealie trial data lives under `/opt/forge/mealie` and is included in
`scripts/backup-configs.sh`. Mealie also has its own UI backup/export flow;
use that before version upgrades. Preserve `/opt/forge/mealie` during rollback
unless the trial data is intentionally being discarded.
