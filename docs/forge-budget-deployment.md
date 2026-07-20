# Forge Budget Local Deployment

Forge Budget is the first sensitive Forge app, so deploy it with a narrower
network posture than the general home automation services.

## Shape

- Source repo: `/home/forge/forge-budget`
- Data directory: `/srv/forge-data/budget`
- Container name: `forge-budget`
- LAN URL: `http://192.168.50.220:3010`
- Health URL: `http://192.168.50.220:3010/health`

The Compose port binding uses `FORGE_LAN_IP:3010:3010`, which keeps the app on
Forge's reserved LAN address instead of every interface.

If Forge ever moves to a different LAN subnet, update `FORGE_LAN_IP` in
`compose/.env` and the Forge Budget firewall rule in `scripts/bootstrap.sh`.

## First Deploy

On Forge:

```bash
git clone https://github.com/travisjslagle/forge-budget.git ~/forge-budget
git clone https://github.com/travisjslagle/forge.git ~/forge-infra
cd ~/forge-infra
cp compose/.env.example compose/.env
```

Check `compose/.env`:

```bash
FORGE_BUDGET_SOURCE=/home/forge/forge-budget
FORGE_BUDGET_DATA=/srv/forge-data/budget
FORGE_LAN_IP=192.168.50.220
```

Then run:

```bash
./scripts/bootstrap.sh
./scripts/update-forge.sh
./scripts/health-check.sh
```

Open `http://192.168.50.220:3010`.

## Monitoring

Add an Uptime Kuma HTTP monitor:

```text
Name: Forge Budget
URL: http://192.168.50.220:3010/health
```

## Access Rule

Forge Budget is LAN-only for v1. Do not add it to Tailscale funnels, router
port forwards, public tunnels, or cloud reverse proxies.

Tailscale can still be used for SSH admin access to Forge.

## Backup Note

The app stores working data under `/srv/forge-data/budget`. The Forge Budget
repo contains restic backup commands, but the encrypted backup and restore flow
still needs a full field test on Forge before relying on it.
