# Tor Onion Service Administration

This directory provides comprehensive documentation and administrative procedures for deploying, hardening, and maintaining Tor Onion Services (v3 hidden services) on Linux infrastructure.

---

## Table of Contents

- [Authorized Use & Security Policy](#authorized-use--security-policy)
- [Document Index](#document-index)
- [Architecture & Security Model](#architecture--security-model)
- [Security Hardening Checklist](#security-hardening-checklist)
- [Quick Deployment Summary](#quick-deployment-summary)
- [Related Documentation](#related-documentation)

---

## Authorized Use & Security Policy

> [!IMPORTANT]
> **Authorized Administration Policy**:
> This documentation is provided strictly for legitimate system administration, privacy-preserving infrastructure, censorship-resistant services, whistleblowing platforms, and secure out-of-band server administration. Operators must ensure compliance with all applicable local, national, and international laws and organizational regulations.

---

## Document Index

| Document | Purpose | Key Topics Covered |
| :--- | :--- | :--- |
| [**`host-tor.md`**](host-tor.md) | Step-by-step Onion service hosting guide | Package install, `/etc/tor/torrc` configuration, loopback backend binding, systemd service management, `.onion` address retrieval, and OpSec. |

---

## Architecture & Security Model

Tor Onion Services enable end-to-end encrypted TCP communication across the Tor overlay network without exposing the server's public IP address or requiring inbound firewall openings.

```
+-------------------+       +--------------------+       +-----------------------+
|   Client (User)   | ----> | Tor Network Relays | ----> | Tor Daemon (Host)     |
| (Tor Browser /    |       | (Encrypted onion   |       | (Outbound connection  |
|  SOCKS5 Proxy)    |       |  rendezvous circuit|       |  to directory/relays) |
+-------------------+       +--------------------+       +-----------------------+
                                                                     |
                                                                     v
                                                         +-----------------------+
                                                         | 127.0.0.1:<PORT>      |
                                                         | (Local App / Nginx)   |
                                                         +-----------------------+
```

### Core Security Guarantees
- **Inbound Port Concealment**: The host initiates all network connections outbound. No public inbound TCP/UDP ports need to be forwarded or exposed on edge firewalls.
- **End-to-End Encryption**: Traffic between the Tor client and the Onion service host is encrypted using ephemeral keys negotiated at rendezvous points.
- **Cryptographic Addressing**: v3 Onion addresses are derived directly from the service's ed25519 public key, preventing DNS spoofing and man-in-the-middle attacks.

---

## Security Hardening Checklist

Prior to bringing an Onion service into active service, verify each item on this checklist:

1. **Loopback Binding Only**:
   - Backend web servers (Nginx, Apache, Node.js, Python) must bind exclusively to `127.0.0.1` or a UNIX domain socket.
   - ⚠️ *Risk*: If bound to `0.0.0.0`, port scans on your public IP can discover the same service, completely de-anonymizing the host.
2. **Directory Permissions (Mode 700)**:
   - The directory defined in `HiddenServiceDir` contains `hs_ed25519_secret_key`.
   - Permissions must be restricted to mode `700`, owned by `debian-tor:debian-tor` (Debian/Ubuntu) or `tor:tor` (RHEL/Rocky).
3. **Banner and Signature Stripping**:
   - Set `server_tokens off;` in Nginx. Remove server headers, OS banners, and detailed stack traces.
4. **Zero Mixed Content & Third-Party CDN Calls**:
   - Never reference clearweb scripts, stylesheets, Google Fonts, or external tracking analytics in served HTML.
   - Client browsers attempting to resolve clearweb domains will generate unencrypted DNS lookups that compromise visitor anonymity.
5. **NTP Clock Synchronization**:
   - Tor consensus voting and circuit timing depend heavily on synchronized system time. Keep `systemd-timesyncd` or `chrony` active.

---

## Quick Deployment Summary

```bash
# 1. Install Tor
sudo apt update && sudo apt install -y tor

# 2. Append service configuration to /etc/tor/torrc
sudo tee -a /etc/tor/torrc << 'EOF'
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:8080
EOF

# 3. Secure permissions and restart daemon
sudo chmod 700 /var/lib/tor/hidden_service/
sudo systemctl restart tor

# 4. Display the generated .onion address
sudo cat /var/lib/tor/hidden_service/hostname
```

---

## Related Documentation

- [Linux Webroot & Permission Guide](../Linux/var-www-html.md): Proper `www-data` ownership and permission standards.
- [Python HTTP Server Reference](../Linux/python3-server.md): Local testing and bind address configuration.
- [Nginx Default Virtual Host](../vps-default/nginx/README.md): Production reverse proxy configuration and header hardening.
