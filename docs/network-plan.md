# Network Plan

## Identity

- Name: Forge
- Hostname: `forge`
- Local DNS/mDNS: `forge.local`
- Tailscale name: `forge`

## LAN

- Reserved IP: `192.168.50.220`
- Router admin URL: TBD
- Ethernet MAC: TBD
- Wi-Fi: active for short-term office placement; move to Ethernet when easy.

## URLs

| Service | URL |
| --- | --- |
| Homepage | `http://forge.local:3000` |
| Home Assistant | `http://forge.local:8123` |
| Node-RED | `http://forge.local:1880` |
| Uptime Kuma | `http://forge.local:3001` |
| Forge Budget | `http://192.168.50.220:3010` |
| MQTT | `forge.local:1883` |

## Firewall

Open on LAN:

- 22/tcp SSH
- 1880/tcp Node-RED
- 1883/tcp MQTT
- 3000/tcp Homepage
- 3001/tcp Uptime Kuma
- 3010/tcp Forge Budget, bound to `192.168.50.220` only
- 8123/tcp Home Assistant

No router port forwards for v1.

Remote admin access should go through Tailscale for SSH. Forge Budget should
stay LAN-only and should not be exposed through Tailscale, router port
forwards, or a public tunnel.

## Notes

- Add Forge's reserved LAN IP to `compose/.env` under
  `HOMEPAGE_ALLOWED_HOSTS`.
- If `.local` names do not resolve from Windows, use the reserved IP or install
  Bonjour/mDNS support.
