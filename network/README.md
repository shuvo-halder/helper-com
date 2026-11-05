# Linux Networking Helpers

This folder contains configuration guides, troubleshooting workflows, and cloud-init automation overrides for Linux network interfaces.

---

## Documents in This Folder

- [**`debian-net-conf.md`**](debian-net-conf.md): Configuring static and dynamic (DHCP) network interfaces on Debian via `/etc/network/interfaces`, managing DNS resolvers, and cross-distro comparison (Ubuntu Netplan & RHEL NetworkManager).
  - [বাংলা সংস্করণ / Original Bengali Version](debian-net-conf.bn.md): Historical original Bengali documentation preserved for reference.
- [**`static-ip-fails.md`**](static-ip-fails.md): Ordered 10-step troubleshooting checklist and diagnostic matrix for resolving interface failures, routing issues, IP conflicts (`arping`), and cloud-init overwrite issues on cloud VMs.

---

## How to Use These Guides

1. **Pre-Flight Safety**: Always verify active network devices and routing tables prior to modifying network configurations:
   ```bash
   ip -brief addr
   ip route
   ```
2. **Prevent Remote Lockouts**: Modifying network interfaces over SSH carries lockout risks. Always schedule an automatic rollback (`sudo shutdown -r +5`) before applying unverified changes, and cycle interfaces atomically (`sudo ifdown <INTERFACE> && sudo ifup <INTERFACE>`).
3. **Cloud Virtual Machines**: If your static IP configuration reverts to DHCP following a server reboot, refer to `static-ip-fails.md` to configure cloud-init overrides.
