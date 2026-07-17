# Network Plan

## Identity

- Name: Forge
- Hostname: `forge`
- Local DNS/mDNS: `forge.local`
- Tailscale name: TBD

## LAN

- Reserved IP: TBD
- Router admin URL: TBD
- Ethernet MAC: TBD
- Wi-Fi: optional/not planned for v1

## URLs

| Service | URL |
| --- | --- |
| Homepage | `http://forge.local:3000` |
| Home Assistant | `http://forge.local:8123` |
| Node-RED | `http://forge.local:1880` |
| Uptime Kuma | `http://forge.local:3001` |
| MQTT | `forge.local:1883` |

## Firewall

Open on LAN:

- 22/tcp SSH
- 1880/tcp Node-RED
- 1883/tcp MQTT
- 3000/tcp Homepage
- 3001/tcp Uptime Kuma
- 8123/tcp Home Assistant

No router port forwards for v1.

Remote access should go through Tailscale.

## Notes

- Add Forge's reserved LAN IP to `compose/.env` under
  `HOMEPAGE_ALLOWED_HOSTS`.
- If `.local` names do not resolve from Windows, use the reserved IP or install
  Bonjour/mDNS support.

