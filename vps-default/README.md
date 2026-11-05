# VPS Default Configurations

This directory contains baseline default server configurations, holding pages, and initial provisioning templates for virtual private servers (VPS).

---

## Subdirectories

- [**`nginx/`**](nginx/README.md): Default catch-all Nginx virtual host configuration (`default.conf`) and a terminal-style landing page (`index.html`).

---

## Intended Purpose

When launching a new cloud server or VPS, unconfigured domains pointing to the server's public IP address or unmapped hostnames should hit a secure, low-overhead default catch-all host rather than exposing internal administration interfaces or throwing raw errors. These configurations ensure:
1. Automated scanners do not discover unlinked host configurations.
2. Certbot ACME webroot challenges succeed smoothly.
3. Access to hidden files (`.git`, `.env`) is unconditionally denied.
