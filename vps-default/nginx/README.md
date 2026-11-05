# Nginx Default Virtual Host & Holding Page

This folder provides a secure default catch-all server block and static landing page for web servers and VPS instances.

---

## Documents & Assets in This Folder

- [**`default.conf`**](default.conf): Production Nginx default virtual host configuration with:
  - Default catch-all listener (`listen 80 default_server`)
  - Let's Encrypt / Certbot webroot ACME challenge passthrough (`/.well-known/acme-challenge/`)
  - Hidden file / sensitive path blocking (`.git`, `.env`, `.htaccess`)
  - Lightweight visitor utility endpoints (`/api/ip`, `/api/ping`)
  - Safe default 404 handler for undefined routes
- [**`index.html`**](index.html): Retro Matrix-style terminal holding page showing client diagnostics (OS, browser, latency) and active system status.

---

## How to Deploy

1. **Deploy Nginx Configuration**:
   ```bash
   sudo cp default.conf /etc/nginx/sites-available/default
   sudo nginx -t && sudo systemctl reload nginx
   ```
2. **Deploy Holding Page**:
   ```bash
   sudo cp index.html /var/www/html/index.html
   ```
3. **Verify Configuration**:
   ```bash
   curl -I http://localhost
   curl http://localhost/api/ping
   ```
