# Linux Web Server Incident Response & Forensic Triage

This directory contains defensive forensic investigation guides and command references designed to detect webshells, backdoor injections, unauthorized code modifications, and spam redirects on compromised web servers (e.g., PHP / Laravel / WordPress).

---

## Table of Contents

- [Legal & Authorized-Use Policy](#legal--authorized-use-policy)
- [Document Index](#document-index)
- [Incident Response Framework (NIST / SANS)](#incident-response-framework-nist--sans)
  - [Phase 1: Identification & Triage](#phase-1-identification--triage)
  - [Phase 2: Evidence Preservation](#phase-2-evidence-preservation)
  - [Phase 3: Containment](#phase-3-containment)
  - [Phase 4: Eradication](#phase-4-eradication)
  - [Phase 5: Recovery & Verification](#phase-5-recovery--verification)
  - [Phase 6: Post-Incident Activity](#phase-6-post-incident-activity)
- [Forensic Evidence Preservation Commands](#forensic-evidence-preservation-commands)
  - [sha256sum (Cryptographic Integrity Verification)](#sha256sum-cryptographic-integrity-verification)
  - [stat (Inode Timestamp Inspection)](#stat-inode-timestamp-inspection)
  - [tar (Quarantine Packaging)](#tar-quarantine-packaging)
- [Related Hardening Guides](#related-hardening-guides)

---

## Legal & Authorized-Use Policy

> [!IMPORTANT]
> **Defensive Security Notice**:
> All techniques and commands in this folder are **strictly defensive**. They are intended for system administrators, security engineers, and site owners conducting authorized forensic investigations and incident response on systems they own or manage with explicit written consent.
>
> **Do not extend, add, or test offensive payloads, unauthorized access mechanisms, or anti-forensic persistence tools in this repository.**

---

## Document Index

| Guide | Purpose | Key Topics Covered | Language Versions |
| :--- | :--- | :--- | :--- |
| [**`find.md`**](find.md) | Filesystem Malware Triage | Modified files (`-mtime`), inode status changes (`-ctime`), suspicious PHP names, unauthorized files in uploads/storage, dangerous functions (`eval`, `base64_decode`), world-writable files (`777`), crontab persistence, active processes. | [English](find.md) \| [বাংলা](find.bn.md) |
| [**`find-1.md`**](find-1.md) | Injections & Conditional Redirects | Stealth entrypoint inspection (`sed`), `.user.ini` and `auto_prepend_file` tampering, hidden `.filename.php` scripts, base64 obfuscation, and SEO cloaking diagnostics via `curl`. | [English](find-1.md) \| [বাংলা](find-1.bn.md) |

---

## Incident Response Framework (NIST / SANS)

### Phase 1: Identification & Triage
1. Confirm the anomaly using non-destructive, read-only search commands documented in [**`find.md`**](find.md) and [**`find-1.md`**](find-1.md).
2. Determine the initial scope: compromised accounts, affected virtual hosts, modified files, and active unauthorized processes.
3. **Do not modify files in-place during initial triage**, as this alters access and modification timestamps (`atime`, `mtime`, `ctime`).

---

### Phase 2: Evidence Preservation
Before changing permissions, deleting backdoors, or rebooting the server:
1. Export process lists, network connections, and open sockets to an external audit folder:
   ```bash
   AUDIT_DIR=~/incident_audit_$(date +%Y%m%d_%H%M%S)
   mkdir -p "$AUDIT_DIR"
   ss -tulpn > "$AUDIT_DIR/open_sockets.txt"
   ps auxf > "$AUDIT_DIR/process_tree.txt"
   ```
2. Compute cryptographic hashes (SHA-256) of all suspicious files before taking them offline.

---

### Phase 3: Containment
Prevent further unauthorized access or data exfiltration without destroying forensic artifacts:
1. **Network Containment**: Temporarily restrict administrative access to trusted management IPs using `ufw` or `iptables`.
2. **Application Maintenance**: Put the affected web application into maintenance mode or disable the virtual host in Nginx/Apache.
3. **Session Revocation**: Invalidate all active user sessions, API tokens, and administrative login cookies.

---

### Phase 4: Eradication
1. Remove confirmed webshells and dropper scripts identified in the evidence archive.
2. Revert modified core application files cleanly using git:
   ```bash
   git diff <FILE>
   git checkout <FILE>
   ```
3. Audit and purge rogue cron jobs:
   ```bash
   crontab -l
   sudo ls -la /etc/cron.* /etc/crontab
   ```
4. Remove malicious directives from `.user.ini`, `.htaccess`, and web server virtual host configs.

---

### Phase 5: Recovery & Verification
1. Rotate all credentials:
   - Database passwords (see [MySQL Permissions Guide](../MySql/create-user-and-permission.md))
   - Application secrets, API keys, and `.env` salts
   - SSH keys and user account passwords
2. Restore proper filesystem permissions (see [Webroot Permissions Guide](../Linux/var-www-html.md)).
3. Restart PHP-FPM and web server daemons to clear opcode caches and close orphaned execution handles:
   ```bash
   sudo systemctl restart php-fpm || sudo systemctl restart php8.2-fpm
   sudo systemctl reload nginx
   ```
4. Verify with simulated crawler requests:
   ```bash
   curl -I -A "Googlebot" -e "https://www.google.com" http://127.0.0.1
   ```

---

### Phase 6: Post-Incident Activity
1. Document the root cause (e.g. unpatched CMS vulnerability, exposed admin credentials, vulnerable file upload handler).
2. Patch the entry vector and apply system updates (`sudo apt update && sudo apt upgrade`).
3. Harden PHP configuration (`disable_functions`) and enforce strict security headers (see [PHP-FPM Tuning Guide](../PHP/php-fpm-tuning.md) and [Nginx Production Guide](../vps-default/nginx/README.md)).

---

## Forensic Evidence Preservation Commands

### sha256sum (Cryptographic Integrity Verification)
Generate cryptographic hashes for all PHP files to verify integrity against clean release builds and detect modifications.
```bash
find . -type f -name "*.php" -exec sha256sum {} + > ~/security_audit/php_files.sha256
```
| Flag | Description |
| :--- | :--- |
| `-c <FILE>` | Verify checksums against a previously generated list of hashes |
| `--tag` | Create a BSD-style checksum output format |

**Real-world example:**
```bash
# Check if any hashed file has been altered
sha256sum -c ~/security_audit/php_files.sha256 | grep -v ": OK"
```

---

### stat (Inode Timestamp Inspection)
Display comprehensive inode metadata, including Access, Modify, and Change timestamps, for a suspected file.
```bash
stat <FILE_PATH>
```
| Flag | Description |
| :--- | :--- |
| `-c <FORMAT>` | Use specified format string instead of the default display |
| `-t` | Print the information in terse form |

**Real-world example:**
```bash
# Compare modify (mtime) and status change (ctime) timestamps
stat public/index.php
```

> [!TIP]
> If a file's `Modify` date is months old but its `Change` (`ctime`) date is recent, an attacker may have used `touch -t` (timestomping) to blend the webshell into older legitimate code.

---

### tar (Quarantine Packaging)
Create a compressed forensic archive of quarantined samples for offline analysis.
```bash
tar -czvf ~/security_audit/quarantine.tar.gz --exclude="*.log" <TARGET_DIR>
```
| Flag | Description |
| :--- | :--- |
| `-c` | Create a new archive |
| `-z` | Compress archive using gzip |
| `-v` | Verbosely list files processed |
| `-f <FILE>` | Use archive file or device `<FILE>` |

**Real-world example:**
```bash
# Create an evidence bundle and restrict permissions to root
sudo tar -czvf ~/evidence_$(date +%F).tar.gz /var/log/nginx/ ~/security_audit/
sudo chmod 600 ~/evidence_$(date +%F).tar.gz
```

---

## Related Hardening Guides

- [Webroot Ownership & Permission Hardening](../Linux/var-www-html.md): Proper `www-data` ownership and preventing world-writable vulnerabilities.
- [PHP-FPM Performance & Security Hardening](../PHP/php-fpm-tuning.md): Hardening `php.ini` directives (`disable_functions`, `expose_php = Off`).
- [Nginx Default Catch-All & Header Hardening](../vps-default/nginx/README.md): Blocking dotfiles, HTTP security headers, and rate limiting.
- [MySQL User & Privileges Hardening](../MySql/create-user-and-permission.md): Principle of least privilege for database accounts.
