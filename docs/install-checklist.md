# Install Checklist

Use this when the mini PC arrives.

## 1. Hardware Check

- Confirm the power adapter is included.
- Install the intended M.2 NVMe drive if ready.
- Connect Ethernet.
- Connect keyboard/monitor for first boot.
- Boot to BIOS.
- Confirm there is no BIOS/admin password.
- Enable "Power On After AC Loss" or equivalent.
- Confirm boot mode is UEFI.
- Confirm NVMe drive is detected.

## 2. Install Ubuntu Server

- Download Ubuntu Server LTS.
- Create a boot USB.
- Install Ubuntu Server on the NVMe drive.
- Hostname: `forge`
- User: your normal admin username.
- Enable OpenSSH during install.
- Do not install a desktop environment.

## 3. First Login

From your laptop:

```bash
ssh <user>@forge.local
```

If `.local` does not resolve yet, use the IP shown by your router.

## 4. Router Reservation

In the router admin UI:

- Find Forge in connected devices.
- Reserve its current IP.
- Record it in `docs/network-plan.md`.

## 5. Clone Repo And Bootstrap

```bash
git clone <repo-url> ~/forge-infra
git clone https://github.com/travisjslagle/forge-budget.git ~/forge-budget
cd ~/forge-infra
cp compose/.env.example compose/.env
./scripts/bootstrap.sh
```

Log out and back in so Docker group membership applies.

```bash
cd ~/forge-infra
./scripts/update-forge.sh
./scripts/health-check.sh
```

## 6. Tailscale

Install Tailscale:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

Follow the login URL.

After that, record the Tailscale machine name in `docs/network-plan.md`.

## 7. First Service Setup

Open these from your laptop:

- `http://forge.local:3000`
- `http://forge.local:8123`
- `http://forge.local:1880`
- `http://forge.local:3001`
- `http://192.168.50.220:3010`

Create first admin accounts for:

- Home Assistant
- Node-RED, if prompted/configured
- Uptime Kuma
- Forge Budget is LAN-only and should use `http://192.168.50.220:3010`.

## 8. First Backup

```bash
cd ~/forge-infra
./scripts/backup-configs.sh
```

Copy the backup somewhere off Forge once storage plans are settled.
