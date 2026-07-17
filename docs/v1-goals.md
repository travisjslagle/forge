# Forge V1 Goals

Forge v1 is a stable local infrastructure host.

It is not trying to be a local AI server, coding workstation, NAS, or business
automation platform yet.

## Success Criteria

- Forge boots without a keyboard or monitor attached.
- Forge is reachable on the LAN at `forge.local`.
- Forge is reachable remotely through Tailscale.
- SSH works from the primary laptop.
- Docker and Docker Compose are installed.
- The v1 services start after reboot.
- Service data lives under `/opt/forge`.
- A basic backup archive can be created.
- The install can be reproduced from this repo.

## V1 Services

| Service | Port | Purpose |
| --- | ---: | --- |
| Homepage | 3000 | Local launchpad |
| Home Assistant | 8123 | Smart home hub |
| Mosquitto | 1883 | MQTT message broker |
| Node-RED | 1880 | Visual automation workbench |
| Uptime Kuma | 3001 | Monitoring |

## Deferred

- Local LLM hosting
- Coding agents
- Gmail/document summarization
- Public web hosting
- Complex business workflows
- Multi-drive storage layout
- Network segmentation/VLANs

Those become easier after Forge is boring, reachable, and backed up.

