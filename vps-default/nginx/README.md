# Nginx Default Virtual Host & Holding Page

This directory provides a production-tested catch-all default server block, modern reverse proxy patterns, TLS automation, and a lightweight visitor terminal holding page.

---

## Table of Contents

- [Overview & File Catalog](#overview--file-catalog)
- [Distribution Path Differences](#distribution-path-differences)
- [Deployment Workflow](#deployment-workflow)
- [Command Reference](#command-reference)
  - [nginx -t](#nginx--t)
  - [systemctl reload nginx](#systemctl-reload-nginx)
  - [certbot --nginx](#certbot---nginx)
  - [curl test commands](#curl-test-commands)
- [Production Patterns & Recipes](#production-patterns--recipes)
  - [Reverse Proxy with WebSockets](#reverse-proxy-with-websockets)
  - [HTTP Security Headers](#http-security-headers)
  - [Rate Limiting](#rate-limiting)
- [Troubleshooting & Verification](#troubleshooting--verification)

---

## Overview & File Catalog

- [**`default.conf`**](default.conf): Production Nginx default virtual host configuration with:
  - Default catch-all listener (`listen 80 default_server`)
  - Let's Encrypt / Certbot ACME webroot challenge passthrough (`/.well-known/acme-challenge/`)
  - Hidden file / sensitive path blocking (`.git`, `.env`, `.htaccess`)
  - Lightweight visitor utility endpoints (`/api/ip`, `/api/ping`)
  - Safe default 404 handler for unmapped routes
- [**`index.html`**](index.html): Retro Matrix-style terminal holding page displaying visitor connection diagnostics (OS, browser, latency) and active system status without external JavaScript dependencies.

---

## Distribution Path Differences

Nginx configuration directory layout differs between Debian/Ubuntu and Enterprise Linux distributions:

| Component | Debian / Ubuntu | RHEL / Rocky Linux / AlmaLinux |
| :--- | :--- | :--- |
| **Main Config** | `/etc/nginx/nginx.conf` | `/etc/nginx/nginx.conf` |
| **Available Sites** | `/etc/nginx/sites-available/` | N/A (single directory model) |
| **Active Sites** | `/etc/nginx/sites-enabled/` (symlinked) | `/etc/nginx/conf.d/*.conf` |
| **Default Webroot** | `/var/www/html/` | `/usr/share/nginx/html/` |
| **Process User** | `www-data` | `nginx` |
| **SELinux Required** | No (AppArmor by default) | Yes (`setsebool -P httpd_can_network_connect 1` for reverse proxies) |

---

## Deployment Workflow

### 1. Deploy Configuration File

#### On Debian / Ubuntu:
```bash
sudo cp default.conf /etc/nginx/sites-available/default.conf
sudo ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf
# Remove legacy distribution default if present
sudo rm -f /etc/nginx/sites-enabled/default
```

#### On RHEL / Rocky Linux / AlmaLinux:
```bash
sudo cp default.conf /etc/nginx/conf.d/00-default.conf
```

### 2. Deploy Holding Page
```bash
sudo mkdir -p /var/www/html
sudo cp index.html /var/www/html/index.html
sudo chown -R www-data:www-data /var/www/html 2>/dev/null || sudo chown -R nginx:nginx /var/www/html
sudo chmod 644 /var/www/html/index.html
```

### 3. Test and Reload
```bash
sudo nginx -t && sudo systemctl reload nginx
```

---

## Command Reference

### nginx -t
Validate Nginx configuration syntax and test configuration files for errors before reloading.
```bash
sudo nginx -t
```
| Flag | Description |
| :--- | :--- |
| `-t` | Test configuration syntax and exit |
| `-T` | Test configuration syntax, dump the entire expanded configuration to stdout, and exit |
| `-q` | Suppress non-error messages during configuration testing |
| `-c <PATH>` | Use an alternative configuration file instead of the default `/etc/nginx/nginx.conf` |

**Real-world example:**
```bash
# Verify configuration and inspect full merged config blocks
sudo nginx -T | grep -E "server_name|listen"
```

> [!WARNING]
> Never execute `systemctl reload nginx` or `systemctl restart nginx` without running `nginx -t` first. If a configuration file contains syntax errors, restarting can take down your active web server entirely.

---

### systemctl reload nginx
Signal Nginx master process to load modified configuration files gracefully without dropping existing client connections.
```bash
sudo systemctl reload nginx
```
| Command | Description |
| :--- | :--- |
| `reload` | Graceful reload: starts new workers with the new config and gracefully shuts down old workers |
| `restart` | Complete service stop and start; will temporarily disrupt active TCP connections |
| `status` | Show service running state, process ID (PID), memory usage, and recent systemd journal entries |

**Real-world example:**
```bash
# Safely test and reload atomically
sudo nginx -t && sudo systemctl reload nginx
```

> [!TIP]
> Prefer `reload` over `restart` in production. Reload ensures zero downtime because existing worker processes finish active requests before terminating.

---

### certbot --nginx
Automate TLS certificate issuance and renewal configuration for Nginx virtual hosts using the Let's Encrypt ACME plugin.
```bash
sudo certbot --nginx -d <DOMAIN_NAME> -m <EMAIL> --agree-tos --redirect
```
| Flag | Description |
| :--- | :--- |
| `--nginx` | Use the Nginx authenticator and installer plugin |
| `-d <DOMAIN>` | Specify domain name(s) to include in the certificate (can repeat for multiple domains) |
| `-m <EMAIL>` | Contact email for security notices and expiration warnings |
| `--agree-tos` | Agree to the ACME server subscriber terms of service automatically |
| `--redirect` | Automatically inject HTTP-to-HTTPS 301 redirection into the server block |
| `--dry-run` | Perform a test run against the Let's Encrypt staging environment without saving certificates |

**Real-world example:**
```bash
# Test certificate issuance against staging environment first
sudo certbot --nginx --dry-run -d <DOMAIN_NAME> -m <EMAIL> --agree-tos
```

> [!WARNING]
> Do not request production certificates in a test loop without `--dry-run`. Let's Encrypt enforces strict rate limits (typically 5 duplicate certificates per week for the exact set of hostnames).

---

### curl test commands
Test HTTP response status codes, headers, and endpoints from the command line.
```bash
curl -I http://127.0.0.1
```
| Flag | Description |
| :--- | :--- |
| `-I, --head` | Fetch HTTP headers only |
| `-v, --verbose` | Show complete request and response headers plus connection handshake details |
| `-s, --silent` | Silent mode: suppress progress meter and error output |
| `-H <HEADER>` | Pass a custom HTTP header (useful for testing virtual host names with `Host: <DOMAIN>`) |

**Real-world example:**
```bash
# Test default catch-all response and visitor endpoints
curl -I http://127.0.0.1/
curl -s http://127.0.0.1/api/ping
curl -s http://127.0.0.1/api/ip
```

---

## Production Patterns & Recipes

### Reverse Proxy with WebSockets

To proxy requests to a backend application (Node.js, Python, Go, Ruby) running on an internal port with full WebSocket support, place this location block inside your domain's server block:

```nginx
location / {
    proxy_pass http://127.0.0.1:<APP_PORT>;
    proxy_http_version 1.1;

    # WebSocket upgrade headers
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # Standard client identification headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # Timeouts
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
}
```

> [!NOTE]
> On RHEL / Rocky / AlmaLinux with SELinux enforcing, Nginx is blocked from connecting to network ports by default. Enable the SELinux network connection boolean:
> ```bash
> sudo setsebool -P httpd_can_network_connect 1
> ```

---

### HTTP Security Headers

Harden your server by adding security headers inside the `http {}` block in `/etc/nginx/nginx.conf` or inside individual `server {}` blocks:

```nginx
# Prevent MIME type sniffing
add_header X-Content-Type-Options "nosniff" always;

# Prevent clickjacking / framing
add_header X-Frame-Options "SAMEORIGIN" always;

# Referrer Policy
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# Disable legacy XSS filter (modern browsers rely on CSP)
add_header X-XSS-Protection "0" always;

# HTTP Strict Transport Security (HSTS) - Enable ONLY on HTTPS server blocks
# add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

---

### Rate Limiting

Protect your application from brute-force attacks and denial-of-service bursts by defining a rate-limiting zone:

```nginx
# In the http {} block of /etc/nginx/nginx.conf:
limit_req_zone $binary_remote_addr zone=req_limit_per_ip:10m rate=10r/s;
limit_req_status 429;

# In your server {} or sensitive location {} block:
location /api/ {
    limit_req zone=req_limit_per_ip burst=20 nodelay;
    proxy_pass http://127.0.0.1:<APP_PORT>;
}
```

| Parameter | Meaning |
| :--- | :--- |
| `zone=req_limit_per_ip:10m` | Allocates 10 megabytes of shared memory (tracks ~160,000 unique IP addresses) |
| `rate=10r/s` | Allows an average rate of 10 requests per second per IP |
| `burst=20` | Allows a temporary traffic burst of up to 20 requests above the base rate |
| `nodelay` | Processes burst requests immediately without introducing artificial delay |

---

## Troubleshooting & Verification

| Issue | Diagnostic Step | Corrective Action |
| :--- | :--- | :--- |
| **Syntax error reported** | Run `sudo nginx -t` | Look at the specific file and line number indicated by the error output. |
| **Port 80 already in use** | Run `sudo ss -tulpn '( sport = :80 )'` | Stop competing web servers (e.g. Apache `systemctl stop apache2`). |
| **502 Bad Gateway** | Check upstream service status (`systemctl status <APP_SERVICE>`) | Verify backend is listening on `127.0.0.1:<APP_PORT>`. On RHEL, verify `httpd_can_network_connect`. |
| **403 Forbidden on static files** | Check file permissions (`ls -la /var/www/html`) | Ensure parent directories have execute (`755`) and files have read (`644`) permissions for `www-data` or `nginx`. |
| **ACME Challenge Fails** | Test local challenge path (`curl http://127.0.0.1/.well-known/acme-challenge/test`) | Ensure `location ^~ /.well-known/acme-challenge/` precedes hidden file blocks and points to existing webroot. |
