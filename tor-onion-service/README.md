# Tor Onion Service Administration

This folder provides administrative guides for securely configuring and hosting Tor Onion Services (hidden services) on Linux servers.

---

## Documents in This Folder

- [**`host-tor.md`**](host-tor.md): Step-by-step setup for creating a Tor Hidden Service using `/etc/tor/torrc`, mapping a local backend service (e.g. localhost port 8080), managing the Tor daemon via systemd, and retrieving the `.onion` hostname.

---

## Authorized Use & Security Policy

> **Important**: This documentation is provided strictly for legitimate system administration, privacy-preserving infrastructure, censorship-resistant services, and private administrative out-of-band management.
>
> ⚠️ **Hardening Checklist**:
> 1. **Bind to Localhost Only**: Always ensure your backend service binds strictly to `127.0.0.1` (never `0.0.0.0`) so it cannot be reached directly via public IPv4/IPv6.
> 2. **File Permissions**: The Tor hidden service directory (`/var/lib/tor/hidden_service/`) contains private keys and must be restricted to the Tor daemon user (`chmod 700`).
> 3. **Information Leakage**: Disable web server banners, detailed error messages, and server tokens (`server_tokens off;` in Nginx) to prevent adversaries from correlating your Onion service with your public IP.
