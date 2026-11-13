# VPS Default Configurations

This directory contains baseline default server configurations, holding pages, and initial provisioning templates for virtual private servers (VPS).

---

## Directory Index

- [**`nginx/`**](nginx/README.md): Default catch-all Nginx virtual host configuration (`default.conf`), terminal-style diagnostics holding page (`index.html`), reverse proxy patterns, and TLS automation.

---

## Intended Purpose & Security Architecture

When provisioning a new cloud server or VPS, unmapped domains or automated internet scanners pointing to the server's public IP address should hit a secure, low-overhead default catch-all host rather than exposing application internals, administrative panels, or leaking default distribution credentials.

These templates enforce three fundamental security baseline requirements:

1. **Catch-All Isolation**:
   Requests without a matching `Host` header or targeting undefined subdomains hit a static default block that returns `404` or the holding page, preventing scanner discovery of internal virtual hosts.
2. **ACME Webroot Passthrough**:
   Allows Let's Encrypt / Certbot automated certificate validation (`/.well-known/acme-challenge/`) to succeed without complex routing rules.
3. **Information Disclosure Prevention**:
   Access to hidden dotfiles and sensitive directories (such as `.git/`, `.env`, `.htaccess`, `.DS_Store`) is unconditionally denied.

---

## Quick Deployment Reference

```bash
# 1. Install and activate Nginx default configuration
sudo cp nginx/default.conf /etc/nginx/sites-available/default.conf
sudo ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# 2. Deploy holding page
sudo mkdir -p /var/www/html
sudo cp nginx/index.html /var/www/html/index.html
sudo chmod 644 /var/www/html/index.html

# 3. Validate syntax and reload
sudo nginx -t && sudo systemctl reload nginx
```

For comprehensive instructions, reverse proxy configurations, and rate-limiting examples, see the [Nginx Virtual Host Documentation](nginx/README.md).
