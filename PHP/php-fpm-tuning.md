# PHP-FPM Configuration, Tuning & Security Hardening Guide

This guide details process manager calculations (`pm`), performance tuning for PHP-FPM pools, `php.ini` production security hardening, version switching, and troubleshooting.

---

> [!IMPORTANT]
> ### Process Manager Memory Overhead
> A misconfigured `pm.max_children` directive can exhaust physical memory and trigger the Linux kernel Out-Of-Memory (OOM) killer, terminating database engines or web servers. Always calculate worker limits based on available system RAM and average PHP worker memory consumption before increasing defaults.

---

## 1. PHP-FPM Process Manager Calculation & Tuning

PHP-FPM worker pools are configured in:
- **Debian / Ubuntu**: `/etc/php/<PHP_VERSION>/fpm/pool.d/www.conf`
- **RHEL / Rocky Linux**: `/etc/php-fpm.d/www.conf`

### Sizing Formula for `pm.max_children`
To determine a safe maximum worker count:
$$\text{pm.max\_children} = \frac{\text{Total Available RAM} - \text{Buffer for OS \& DB}}{\text{Average Memory per PHP Process}}$$

*Example*: On an 8 GB RAM server where the OS, Nginx, and MySQL reserve 3 GB, leaving 5 GB (5120 MB) for PHP, and each worker averages 60 MB:
$$\text{pm.max\_children} = \frac{5120\text{ MB}}{60\text{ MB}} \approx 85$$

### Production Pool Directives (`www.conf`)
```ini
[www]
; Pool user and group
user = <WEB_USER>
group = <WEB_GROUP>

; FastCGI listening socket (UNIX domain socket is faster than TCP loopback)
listen = /run/php/php<PHP_VERSION>-fpm.sock
listen.owner = <WEB_USER>
listen.group = <WEB_GROUP>
listen.mode = 0660

; Process manager type (dynamic or ondemand)
pm = dynamic
pm.max_children = 85
pm.start_servers = 20
pm.min_spare_servers = 10
pm.max_spare_servers = 30

; Prevent memory leaks by recycling worker processes after serving requests
pm.max_requests = 1000

; Worker execution timeout
request_terminate_timeout = 60s
```

#### Directive Breakdown
| Directive | Description | Recommended Setting |
|---|---|---|
| `pm` | Process manager algorithm (`dynamic`, `ondemand`, `static`) | `dynamic` (standard web) or `ondemand` (low traffic/VPS) |
| `pm.max_children` | Maximum number of simultaneous child processes | Calculated via memory formula above |
| `pm.start_servers` | Number of child processes created on startup | $(\text{min\_spare} + \text{max\_spare}) / 2$ |
| `pm.min_spare_servers` | Minimum idle processes waiting for requests | $10\text{--}20\%$ of `pm.max_children` |
| `pm.max_spare_servers` | Maximum idle processes waiting for requests | $20\text{--}40\%$ of `pm.max_children` |
| `pm.max_requests` | Number of requests a worker serves before respawning | `500` to `2000` (mitigates memory leaks) |

---

## 2. Managing the PHP-FPM Service

### systemctl status php-fpm
Check service status, active worker processes, and error states.
```bash
sudo systemctl status php<PHP_VERSION>-fpm
```

#### Real-World Example
```bash
# Debian / Ubuntu (versioned service)
sudo systemctl status php8.2-fpm

# RHEL / Rocky Linux (unversioned service)
sudo systemctl status php-fpm
```

---

### systemctl reload php-fpm
Gracefully reload pool configuration without dropping active HTTP requests.
```bash
sudo systemctl reload php<PHP_VERSION>-fpm
```

#### Real-World Example
```bash
# Validate configuration syntax before reloading
sudo php-fpm<PHP_VERSION> -t && sudo systemctl reload php<PHP_VERSION>-fpm
```

> [!WARNING]
> Always test configuration syntax with `php-fpm -t` before issuing a restart or reload. A malformed `www.conf` will prevent PHP-FPM from starting, causing all web visitors to receive HTTP 502 Bad Gateway errors.

---

## 3. Production `php.ini` Security Hardening

Core PHP runtime configuration files:
- **CLI Configuration**: `/etc/php/<PHP_VERSION>/cli/php.ini`
- **FPM Configuration**: `/etc/php/<PHP_VERSION>/fpm/php.ini` (or `/etc/php.ini` on RHEL)

### Essential Security Directives
```ini
; 1. Prevent disclosing PHP version in HTTP headers
expose_php = Off

; 2. Disable displaying error details to web visitors (prevents information leaks)
display_errors = Off
display_startup_errors = Off

; 3. Log errors securely to dedicated file
log_errors = On
error_log = /var/log/php_errors.log

; 4. Prevent remote file inclusion vulnerabilities
allow_url_fopen = Off
allow_url_include = Off

; 5. Disable dangerous execution functions commonly targeted by webshells
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_multi_exec,parse_ini_file,show_source

; 6. Resource limits to protect against DoS attacks
max_execution_time = 30
max_input_time = 60
memory_limit = 256M
post_max_size = 32M
upload_max_filesize = 16M

; 7. Session hardening
session.cookie_httponly = 1
session.cookie_secure = 1
session.use_strict_mode = 1
```

---

## 4. Managing Multiple PHP Versions

On servers hosting multiple applications with differing PHP version requirements, use `update-alternatives` (Debian/Ubuntu) to switch CLI versions:

### update-alternatives --config php
Select the system-wide default command-line PHP interpreter interactively.
```bash
sudo update-alternatives --config php
```

#### Real-World Example
```bash
# Set default CLI interpreter to PHP 8.2 non-interactively
sudo update-alternatives --set php /usr/bin/php8.2
```

---

## 5. Password Hashing & Verification Standards

Modern web applications should use PHP's native password API instead of legacy hashing algorithms (`md5`, `sha1`).

### Generating a Secure Hash
```php
// Uses PASSWORD_DEFAULT (bcrypt with automatic salt and cost factor)
$hash = password_hash($plaintext_password, PASSWORD_DEFAULT);
```

### Verifying a Password
```php
// Timing-safe password verification
if (password_verify($user_input, $stored_hash)) {
    // Password matches
} else {
    // Authentication failed
}
```

---

## 6. Distribution Differences Comparison

| Feature | Debian / Ubuntu | RHEL / Rocky / AlmaLinux |
|---|---|---|
| **Package Names** | `php<VERSION>-fpm`, `php<VERSION>-mysql`, `php<VERSION>-xml` | `php-fpm`, `php-mysqlnd`, `php-xml` |
| **Service Name** | `php<VERSION>-fpm` (e.g. `php8.2-fpm`) | `php-fpm` |
| **Pool Directory** | `/etc/php/<VERSION>/fpm/pool.d/` | `/etc/php-fpm.d/` |
| **Default User/Group**| `www-data:www-data` | `apache:apache` (or `nginx:nginx`) |
| **Default Socket** | `/run/php/php<VERSION>-fpm.sock` | `/run/php-fpm/www.sock` <!-- VERIFY: version differences --> |
| **Configuration Check**| `sudo php-fpm<VERSION> -t` | `sudo php-fpm -t` |
