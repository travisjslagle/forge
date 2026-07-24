# Forge Infra

Forge is the always-on home infrastructure host.

The first version is intentionally boring: a reachable Ubuntu Server machine that
runs a small set of local services with Docker Compose.

## V1 Services

- Homepage: local launchpad for Forge services
- Home Assistant: smart home hub
- Mosquitto: MQTT event broker
- Node-RED: visual automation workbench
- Uptime Kuma: service and network monitoring
- Forge Budget: LAN-only household budgeting app

## Target Host

- Hostname: `forge`
- Local name: `forge.local`
- Live service data: `/opt/forge`
- Forge Budget data: `/srv/forge-data/budget`
- Repo checkout: `/opt/forge/repo` or `~/forge-infra`

## Quick Start On Forge

After Ubuntu Server is installed and you can SSH into Forge:

```bash
git clone <repo-url> ~/forge-infra
git clone https://github.com/travisjslagle/forge-budget.git ~/forge-budget
cd ~/forge-infra
cp compose/.env.example compose/.env
./scripts/bootstrap.sh
./scripts/update-forge.sh
docker exec forge-budget python scripts/seed-pin-users.py
```

Then open:

- Homepage: `http://forge.local:3000`
- Home Assistant: `http://forge.local:8123`
- Node-RED: `http://forge.local:1880`
- Uptime Kuma: `http://forge.local:3001`
- Forge Budget: `http://192.168.50.220:3010`

## Daily Commands

```bash
cd ~/forge-infra
./scripts/health-check.sh
./scripts/update-forge.sh
./scripts/backup-configs.sh
```

For a fuller list of SSH, Docker, log, backup, Tailscale, and shutdown
commands, see [docs/cli-cheatsheet.md](docs/cli-cheatsheet.md).

## Future Apps

- [Product Direction](docs/product-direction.md): longer-term Forge thesis,
  wedge, platform boundaries, and mobile/security direction.
- [Forge Budget V1](docs/forge-budget-v1.md): local CSV imports, transaction
  categorization, and household spending reports.
- [Forge Budget CSV Importers](docs/forge-budget-csv-importers.md): observed bank export
  schemas and normalization notes.

## Repo Versus Live Data

This repo describes how Forge should be built.

The live service state lives under `/opt/forge`:

```text
/opt/forge/
  backups/
  homeassistant/
  homepage/
  mosquitto/
  node-red/
  uptime-kuma/
```

Back up `/opt/forge`, not just this repo.

Forge Budget keeps its financial data outside this repo at
`/srv/forge-data/budget`. Back it up separately with the app's encrypted backup
flow.
