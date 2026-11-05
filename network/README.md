# Linux Networking Helpers

This folder contains configuration guides, troubleshooting steps, and automation overrides for Linux network interfaces.

---

## Documents in This Folder

- [**`debian-net-conf.md`**](debian-net-conf.md): Configuring static IP addresses, gateways, netmasks, and DNS servers using Debian's `/etc/network/interfaces`.
  - [বাংলা সংস্করণ / Original Bengali Version](debian-net-conf.bn.md)
- [**`static-ip-fails.md`**](static-ip-fails.md): Resolving static IP configuration resets on reboot caused by cloud-init on virtual cloud instances (AWS, Hetzner, DigitalOcean).

---

## How to Use These Guides

1. **Pre-Flight Verification**: Always verify active network interfaces and routes before editing network configurations:
   ```bash
   ip addr
   ip route
   ```
2. **Prevent SSH Lockout**: Double-check your IP address, subnet netmask, and default gateway. An invalid gateway or subnet mask will disconnect active remote SSH sessions.
3. **Cloud Instances**: If your static IP configuration disappears after a server reboot, see `static-ip-fails.md` to prevent cloud-init from regenerating network interface files.
