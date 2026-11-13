# PHP Helpers & Server Administration

This directory contains command-line utilities, production tuning guides, and security hardening procedures for PHP runtime environments and PHP-FPM daemons on Linux.

---

## Documents & Scripts in This Folder

- [**`php-fpm-tuning.md`**](php-fpm-tuning.md): Production PHP-FPM process manager calculations (`pm.max_children`), pool configuration (`www.conf`), service lifecycle commands, `php.ini` security directives, multiple version management, and cross-distribution comparison.
- [**`make_hash.php`**](make_hash.php): Standalone interactive command-line utility for generating cryptographically secure bcrypt password hashes using PHP's native `password_hash()` API with input validation.

---

## How to Use These Guides

1. **CLI Password Hashing**: Run the password generator directly from your terminal session without exposing plaintext passwords in shell history:
   ```bash
   php make_hash.php
   ```
2. **Process Manager Sizing**: Never guess `pm.max_children` values. Use the calculation formula in `php-fpm-tuning.md` to prevent web traffic spikes from triggering memory exhaustion.
3. **Configuration Validation**: Always validate PHP-FPM syntax prior to reloading the service daemon:
   ```bash
   sudo php-fpm -t && sudo systemctl reload php-fpm
   ```
