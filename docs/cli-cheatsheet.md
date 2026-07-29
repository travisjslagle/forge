# Forge CLI Cheatsheet

Use this when you remember the shape of Forge but not the exact commands.

## From Windows PowerShell

SSH into Forge through Tailscale/MagicDNS:

```powershell
ssh forge@forge
```

SSH into Forge through the reserved LAN IP:

```powershell
ssh forge@192.168.50.220
```

Check Tailscale devices from Windows:

```powershell
tailscale status
tailscale ping forge
```

Open Forge services in a browser:

```text
http://forge:3000              Homepage
http://forge:8123              Home Assistant
http://forge:1880              Node-RED
http://forge:3001              Uptime Kuma
http://192.168.50.220:9925     Mealie

http://192.168.50.220:3000     Homepage by LAN IP
```

Exit SSH cleanly:

```bash
exit
```

Closing PowerShell is also okay; it just ends the SSH session.

## First Commands After SSH

```bash
hostname
ip -br addr
uptime
df -h
free -h
```

## Forge Health

```bash
cd ~/forge-infra
bash scripts/health-check.sh
```

Useful direct checks:

```bash
docker ps
docker compose --env-file compose/.env -f compose/docker-compose.yml ps
```

## Start, Restart, Or Update Services

Pull current container images and start/recreate services:

```bash
cd ~/forge-infra
bash scripts/update-forge.sh
```

Restart one service:

```bash
docker restart forge-homepage
docker restart forge-homeassistant
docker restart forge-node-red
docker restart forge-uptime-kuma
docker restart forge-mosquitto
docker restart forge-mealie
```

Force-recreate Homepage after editing `compose/.env`:

```bash
cd ~/forge-infra
docker compose --env-file compose/.env -f compose/docker-compose.yml up -d --force-recreate homepage
```

Stop all Forge services:

```bash
cd ~/forge-infra
docker compose --env-file compose/.env -f compose/docker-compose.yml down
```

Start all Forge services:

```bash
cd ~/forge-infra
docker compose --env-file compose/.env -f compose/docker-compose.yml up -d
```

## Logs

Show recent logs:

```bash
docker logs forge-homepage --tail=100
docker logs forge-homeassistant --tail=100
docker logs forge-node-red --tail=100
docker logs forge-uptime-kuma --tail=100
docker logs forge-mosquitto --tail=100
docker logs forge-mealie --tail=100
```

Follow live logs:

```bash
docker logs -f forge-uptime-kuma
```

Docker/system logs:

```bash
journalctl -u docker --since "24 hours ago"
journalctl -u ssh --since "24 hours ago"
journalctl --since "24 hours ago"
```

Network logs:

```bash
journalctl -u NetworkManager --since "24 hours ago"
journalctl -u systemd-networkd --since "24 hours ago"
```

One of those network commands may be empty depending on which network stack
Ubuntu is using.

## Backups

Create a backup of service config/state:

```bash
cd ~/forge-infra
sudo bash scripts/backup-configs.sh
ls -lh /opt/forge/backups
```

Important data lives under:

```text
/opt/forge/
```

The repo describes how Forge is built; `/opt/forge` contains the live state.

## Tailscale

Install Tailscale:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Check Tailscale on Forge:

```bash
tailscale status
tailscale ip -4
```

Known Forge Tailscale IP during setup:

```text
100.124.207.61
```

Preferred access command:

```powershell
ssh forge@forge
```

## Homepage Allowed Hosts

If Homepage says "Host validation failed", edit:

```bash
cd ~/forge-infra
nano compose/.env
```

Known good value:

```bash
HOMEPAGE_ALLOWED_HOSTS=forge.local,localhost,127.0.0.1,192.168.50.220,192.168.50.220:3000,forge,forge:3000
```

Apply the change:

```bash
docker compose --env-file compose/.env -f compose/docker-compose.yml up -d --force-recreate homepage
```

Verify the container received it:

```bash
docker exec forge-homepage printenv HOMEPAGE_ALLOWED_HOSTS
```

## Mealie Trial

Mealie is pinned in Compose. Before bumping the image tag, read the Mealie
release notes and create a Mealie UI backup plus the normal Forge config
backup.

Useful checks:

```bash
docker logs forge-mealie --tail=100
curl -fsS http://192.168.50.220:9925 >/dev/null && echo "Mealie reachable"
```

## Uptime Kuma Monitor Targets

Use LAN IPs inside Uptime Kuma because it runs in Docker and may not resolve
`forge` the same way Windows does.

```text
HTTP(s)  Homepage         http://192.168.50.220:3000
HTTP(s)  Home Assistant   http://192.168.50.220:8123
HTTP(s)  Node-RED         http://192.168.50.220:1880
HTTP(s)  Uptime Kuma      http://192.168.50.220:3001
HTTP(s)  Mealie           http://192.168.50.220:9925
Port     MQTT             192.168.50.220 / 1883
Ping     Router           192.168.50.1
Ping     Internet         1.1.1.1
```

## OS Updates

Manual maintenance:

```bash
sudo apt update
sudo apt upgrade -y
cd ~/forge-infra
bash scripts/update-forge.sh
bash scripts/health-check.sh
```

## Reboot And Shutdown

Reboot recovery test:

```bash
sudo reboot
```

Clean shutdown:

```bash
sudo poweroff
```

or:

```bash
sudo shutdown now
```

Normal Linux shutdown will stop containers cleanly.

## Wi-Fi Notes

Show wireless interfaces and signal details:

```bash
iw dev
iwconfig
```

Disable Wi-Fi power saving for the current session, replacing interface name as
needed:

```bash
sudo iwconfig wlp2s0 power off
```
