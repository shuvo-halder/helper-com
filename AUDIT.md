# Repository Audit Report (`AUDIT.md`)

**Date**: November 5, 2026  
**Repository**: `helper-com`  
**Branch**: `docs/upgrade`  
**Auditor**: Senior Technical Writer & Linux/DevOps Engineer  

---

## Executive Summary

A comprehensive, line-by-line audit of all 23 files across 9 folders and root files was performed.

### Key Findings
1. **Critical Security Hazards**:
   - `Linux/var-www-html.txt` recommends `chmod -R 777 /var/www/html/...`, which grants global write privileges to web directories and invites webshell execution.
   - `volume-swap/debian.md` uses a blind, non-interactive `fdisk` script deleting partitions `vda5` and `vda2` without safeguards, which will destroy data if executed on non-matching partition layouts.
   - `MySql/createUserAndPermission.txt` creates a user with `IDENTIFIED BY 'password'` and grants `ALL PRIVILEGES ON *.* WITH GRANT OPTION`.
2. **Language Inconsistencies**:
   - `backdoor/find.md`, `backdoor/find-1.md`, and `network/debian-net-conf.md` are written entirely in Bengali with raw conversational chat transcripts, violating the English documentation standard.
   - `vps-default/nginx/default` contains Bengali inline comments.
3. **Outdated & Incomplete Documentation**:
   - Root `README.md` has plain-text Table of Contents entries (unlinked), dozens of bare commands without flags, descriptions, or examples (e.g. `usermod`, `pvcreate`, `rsync -avz`), and heavy duplication across CPU, Memory, Monitoring, and Troubleshooting sections.
   - Deprecated tools are used or referenced without modern equivalents (`netstat`/`ifconfig` vs `ss`/`ip`; `ifupdown` vs `systemd-networkd`/`Netplan`/`NetworkManager`).
4. **Naming & Structural Disorganization**:
   - Inconsistent extensions (`.txt` vs `.md` vs extensionless `default`).
   - Spaces and typographical errors in filenames: `partation.txt`, `Python3 server.txt`, `CentOS-swap partation.md`, `CentOS9 volume + swap partation extend.md`, `statis-ip-fails.md`.
5. **Special Folders (`backdoor/` and `hidden_service/`)**:
   - **`backdoor/`**: Despite its name, this folder does **not** contain malware, attack tools, or exploits. It contains **defensive incident response triage notes** and `grep`/`find` commands for investigating compromised PHP/Laravel web applications (e.g. hunting webshells, SEO/casino redirects, base64 obfuscation).
   - **`hidden_service/`**: Contains raw, incomplete setup notes for hosting a local web service over Tor using `python3 http.server` and `torrc`. Needs clear legal/authorized-use disclaimers, proper security hardening, and complete systemd service integration.
6. **Secrets & Personal Identifiers**:
   - Personal GitHub repository path in `gitHelp/gitHelp.txt` (`https://github.com/cybsam/linuxhelpertext.git`).
   - Weak/default credentials in `MySql/createUserAndPermission.txt` (`'password'`).
   - Hardcoded project path `/var/www/html/freechat/` in `Linux/var-www-html.txt`.
   - External API call to `https://ipwho.is/` in `vps-default/nginx/index.html`.
   - No active private keys, API secrets, or production passwords were found.

---

## Detailed Folder-by-Folder Audit

### 1. Root (`/`)
- **Files**:
  - `LICENSE`
  - `README.md`
- **Purpose**:
  - Project legal licensing (MIT) and quick reference handbook for Linux system engineers, sysadmins, and DevOps practitioners.
- **Problems Identified**:
  - **Broken Navigation**: Table of contents items are plain text (e.g. `- File & Directory`) rather than clickable Markdown anchors (`[File & Directory](#file--directory)`).
  - **Empty/Bare Commands**: Numerous entries simply list binary names without arguments, flags, or context (e.g., lines 136-146: `usermod`, `groupadd`, `groupdel`, `gpasswd`; line 186: `nice`, `renice`; lines 279-293: `pvcreate`, `vgcreate`, `lvcreate`, `lvextend`, `resize2fs`, `xfs_growfs`; lines 587-598: bare `tar`, `gzip`, `zip`, `7z`).
  - **Repetitive Redundancy**:
    - `top` and `htop` appear in Process Management, CPU, Monitoring, Performance Troubleshooting, and Useful One-Liners.
    - `ss -tulpn` appears in Network, Networking Troubleshooting, and Useful One-Liners.
    - `free -h` and `df -h` appear in Disk/Memory, System Information, and Useful One-Liners.
    - `vmstat`, `iostat`, `sar` appear in CPU and Performance Troubleshooting.
    - `Compression` and `Archive` sections are nearly identical duplicates.
  - **Dangerous Commands without Warnings**:
    - `rm -rf directory` (unprotected recursive deletion).
    - `swapoff -a` (can cause instant system OOM panic if RAM is full).
    - `kill -9 PID` (forceful SIGKILL without graceful SIGTERM attempt).
    - `history -c` (wipes shell history, risky during audit/troubleshooting).
    - Permission table lists `777` without security warnings.
  - **Missing Repository Index**: The root README does not reference or link to any subfolders (`Linux/`, `network/`, `gitHelp/`, `MySql/`, `PHP/`, `volume-swap/`, `vps-default/nginx/`, `hidden_service/`, `backdoor/`).
- **Missing Topics**:
  - Modern CLI alternatives (`ip` vs `ifconfig`/`route`, `ss` vs `netstat`, `nftables` vs `iptables`).
  - Systemd timer basics (`systemctl list-timers`).
  - Journalctl advanced filtering (`-u`, `-p`, `--since`, `-k`).
  - Logrotate recipes and configuration.
  - SSH hardening (`sshd_config`, disabling root password login, changing ports, ciphers).
  - Fail2ban basics.
  - Distro differences table (Debian/Ubuntu vs RHEL/Rocky/Alma).

---

### 2. `Linux/`
- **Files**:
  - `partation.txt`
  - `Python3 server.txt`
  - `UbuntuFirmware.txt`
  - `var-www-html.txt`
- **Purpose**:
  - Miscellaneous system administration notes: disk partitioning basics, running a Python HTTP testing server, kernel boot parameters, and web directory permissions.
- **Problems Identified**:
  - **File naming & format**: Mixed `.txt` extension instead of `.md`; spaces in `Python3 server.txt`; spelling mistake in `partation.txt`.
  - **Security Risk (`var-www-html.txt`)**: Recommends `chmod -R 777 /var/www/html/freechat/private` and `public`. This exposes sensitive files to arbitrary web execution.
  - **Security Risk (`Python3 server.txt`)**: `python3 -m http.server 7777` binds by default to `0.0.0.0`, exposing all files in the directory to the entire local network or internet.
  - **Low Quality / Incomplete (`partation.txt`)**: Contains three unformatted lines with typos (`"root parttation / is alwars begining partiion and..."`) and lacks actionable commands.
  - **Dubious Recommendations (`UbuntuFirmware.txt`)**:
    - Uses `sudo gedit` (GUI application as root; fails on headless servers and poses security issues; should use `sudo nano` or `sudoedit`).
    - Uses `mce=off loglevel=3` without explaining that disabling Machine Check Exceptions silences hardware and CPU faults.
- **Missing Topics**:
  - Modern partitioning tools (`parted`, `gdisk`, `fdisk`) with safe sector alignment.
  - Systemd unit template for background Python or microservice processes.
  - Proper web permission standards (`chown -R www-data:www-data`, `find . -type d -exec chmod 755 {} +`, `find . -type f -exec chmod 644 {} +`).
  - GRUB parameter management (`/etc/default/grub`, `update-grub` on Debian vs `grub2-mkconfig` on RHEL).

---

### 3. `gitHelp/`
- **Files**:
  - `gitGlobalConfigure.txt`
  - `gitHelp.txt`
- **Purpose**:
  - Git identity setup and initial repository creation/push cheat sheet.
- **Problems Identified**:
  - **Hardcoded Repository URL (`gitHelp.txt`)**: Contains personal repo link `https://github.com/cybsam/linuxhelpertext.git`.
  - **File formats**: Plain `.txt` without code fences or Markdown formatting.
  - **Limited scope**: Only covers initial commit and basic `git config`.
- **Missing Topics**:
  - Essential daily workflow (branching, switching, pulling with rebase, stashing).
  - Recovery recipes: Undoing accidental commits (`git reset --soft HEAD~1`), recovering deleted files/commits (`git reflog`), reverting public commits (`git revert`).
  - SSH key generation and authentication for GitHub/GitLab.
  - Creating and maintaining `.gitignore`.

---

### 4. `MySql/`
- **Files**:
  - `createUserAndPermission.txt`
- **Purpose**:
  - MySQL/MariaDB database user creation and permission management.
- **Problems Identified**:
  - **Syntax Error & Formatting**: Line 2 contains a mashed comment and query: `using specific database//GRANT PRIVILEGE ON database.table TO 'username'@'host';`.
  - **Overly Permissive**: Line 3 grants `ALL PRIVILEGES ON *.* WITH GRANT OPTION` to a local user, which is dangerous in production.
  - **Hardcoded Insecure Password**: Uses `'password'`.
  - **Outdated User Management**: Does not specify authentication plugin (e.g. `caching_sha2_password` vs `mysql_native_password`) or modern MariaDB vs MySQL differences.
- **Missing Topics**:
  - MySQL / MariaDB installation and initial lockdown (`mysql_secure_installation` / `mariadb-secure-installation`).
  - Database creation with UTF-8 character encoding (`utf8mb4`).
  - Database-specific, least-privilege granting recipes.
  - Backup and restore with `mysqldump` / `mariadb-dump` (including single DB, all DBs, compressed dumps).
  - Showing grants and revoking privileges (`SHOW GRANTS FOR ...`).

---

### 5. `PHP/`
- **Files**:
  - `make_hash.php`
- **Purpose**:
  - Interactive CLI utility script for hashing passwords using PHP's native `password_hash()` with `PASSWORD_DEFAULT`.
- **Problems Identified**:
  - Standalone raw PHP file with zero accompanying documentation or security notes.
  - No interactive input validation (trims, empty password handling).
  - Violates repository consistency (all other folders contain command references and administration guides; a standalone unreferenced PHP script is out of place without an explanatory guide).
- **Missing Topics**:
  - PHP-FPM pool configuration and tuning (`pm = dynamic`, `pm.max_children`, `pm.start_servers`).
  - Managing PHP extensions and multiple PHP versions (e.g., Debian `update-alternatives --config php`).
  - Security hardening in `php.ini` (`disable_functions`, `expose_php = Off`, `allow_url_fopen = Off`, `display_errors = Off`).
  - Password hashing and verification recipes (explaining `password_hash()` and `password_verify()` with bcrypt/Argon2id).

---

### 6. `network/`
- **Files**:
  - `debian-net-conf.md`
  - `statis-ip-fails.md`
- **Purpose**:
  - Debian static IP configuration and cloud-init network overwrite troubleshooting.
- **Problems Identified**:
  - **Language Violation**: `debian-net-conf.md` is written entirely in Bengali.
  - **Spelling Error in Filename**: `statis-ip-fails.md` (should be `static-ip-fails.md` or `cloud-init-network.md`).
  - **Under-explained Content**: `statis-ip-fails.md` is only 4 lines long and lacks context explaining why cloud-init overrides `/etc/network/interfaces` on cloud VMs (AWS, DigitalOcean, Hetzner, etc.).
  - **Legacy Networking**: `/etc/network/interfaces` (`ifupdown`) is largely legacy in modern Linux distributions (Debian 12 supports it if installed, but Ubuntu uses Netplan, and RHEL/Fedora uses NetworkManager).
  - **High Lockout Risk**: Modifying network interfaces or restarting networking via SSH can lock out the administrator if gateway, netmask, or interface names are incorrect. Requires explicit warnings and pre-flight verification steps.
- **Missing Topics**:
  - Modern interface and address management with `ip` (`ip addr`, `ip route`, `ip link`).
  - Socket and port inspection with `ss` (`ss -tulwn`, `ss -tulpn`).
  - Netplan configuration (Ubuntu 20.04/22.04/24.04).
  - NetworkManager CLI (`nmcli`) configuration for Rocky/RHEL/Debian.
  - DNS resolution debugging (`resolvectl status`, `/etc/resolv.conf`, `dig`, `nslookup`).
  - UFW and basic `nftables` syntax for network security.

---

### 7. `volume-swap/`
- **Files**:
  - `CentOS-swap partation.md`
  - `CentOS9 volume + swap partation extend.md`
  - `debian.md`
  - `readme.md`
  - `swap-extends.txt`
  - `volume-extends.txt`
- **Purpose**:
  - Storage volume resizing, partition expansion, LVM management, and swap partition/file creation for Debian and CentOS/RHEL.
- **Problems Identified**:
  - **File naming & formatting**: Spaces and typos in filenames (`CentOS-swap partation.md`, `CentOS9 volume + swap partation extend.md`). Mixed `.txt` and `.md`.
  - **Conversational Chat Spillover**: Files contain verbatim chat dialog ("Sure! Here's the same instruction translated...", "Alright brother...", "Yes brother, you can add...", "Would you like me to do that?").
  - **Extreme Data Loss Risk (`debian.md`)**:
    - Runs automated heredoc into fdisk: `fdisk /dev/vda <<EOF \n d \n 5 \n d \n 2 \n w \n EOF`.
    - If executed on any machine where partition 5 or 2 is not the intended target, or if sector boundaries differ, **partitions and filesystems will be immediately destroyed**.
  - **Redundancy & Fragmentation**:
    - Swap file instructions are split between `swap-extends.txt`, `CentOS-swap partation.md`, and `debian.md`.
    - LVM extension instructions are split between `volume-extends.txt`, `CentOS9 volume + swap partation extend.md`, and `readme.md`.
  - **Missing Safety Checks**:
    - No mention that XFS filesystems **cannot be shrunk** (only grown).
    - `fallocate` may create sparse files on certain filesystems (like XFS or CoW filesystems like Btrfs) that `mkswap`/`swapon` reject; `dd` fallback is required.
    - Missing warnings on `swapoff -a` (OOM trigger).
- **Missing Topics**:
  - Comprehensive, unified LVM workflow: Physical Volumes (`pvcreate`, `pvs`, `pvdisplay`), Volume Groups (`vgcreate`, `vgs`, `vgextend`), Logical Volumes (`lvcreate`, `lvs`, `lvextend`).
  - Clean, copy-paste-safe Swap File setup recipe (secure permissions, fstab persistence, swappiness tuning).
  - Safe partition enlargement using `growpart` with package name differences (`cloud-guest-utils` on Debian/Ubuntu vs `cloud-utils-growpart` on RHEL).
  - Filesystem growth commands: `resize2fs` (ext4) vs `xfs_growfs` (XFS).

---

### 8. `vps-default/nginx/`
- **Files**:
  - `default`
  - `index.html`
- **Purpose**:
  - Default catch-all Nginx virtual host configuration and a retro cyberpunk Matrix-style terminal holding/landing page.
- **Problems Identified**:
  - **Nesting and Extension**: The config file has no file extension (`default` instead of `default.conf`).
  - **Language Inconsistency**: `default` contains comments in Bengali (`# certbot (webroot) er jonno...`, `# onno shob kichu 404`).
  - **External Dependencies & Privacy (`index.html`)**: Queries third-party service `https://ipwho.is/` on client page load without user consent or fallback.
  - **Usability Impediment (`index.html`)**: Includes anti-inspect JavaScript blocking right-click and keyboard developer keys (`F12`, `Ctrl+Shift+I`).
- **Missing Topics**:
  - Production Nginx server block recipe for custom domain hosting.
  - Let's Encrypt TLS setup via Certbot (`certbot --nginx` and webroot mode).
  - Reverse proxy configuration with WebSocket support (`proxy_pass`, `proxy_set_header Upgrade`, `Host`, `X-Real-IP`).
  - Essential HTTP security headers (`Strict-Transport-Security`, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`).
  - Configuration testing and reloading workflow (`nginx -t && systemctl reload nginx`).

---

### 9. Special Handling: `hidden_service/`
- **Files**:
  - `hostTor.txt`
- **Detailed Content Inspection**:
  - 12-line plain text note describing:
    1. Running `python3 -m http.server --bind 127.0.0.1 8080`.
    2. Editing `/etc/tor/torrc` to uncomment `HiddenServiceDir` and `HiddenServicePort`.
    3. Pointing the hidden service to port 8080.
    4. Reading `/var/lib/tor/hidden_service/hostname` to retrieve the `.onion` address.
- **Assessment**:
  - This is a legitimate administrative topic for hosting a private Tor Onion Service (e.g. for private administrative dashboards or censorship-resistant web services).
  - It contains no malicious exploits, weaponized code, or unauthorized evasion techniques.
- **Problems Identified**:
  - Fragmented notes lacking step-by-step instructions (e.g. `"uncomment tor hidden service"`, `"bootstraping tor"`).
  - Missing package installation (`apt install tor` / `dnf install tor`).
  - Missing service management (`systemctl enable --now tor`).
  - Missing security warnings regarding local service exposure, web server information leaks (server headers, error pages revealing real public identity), and directory permissions on `/var/lib/tor/`.
- **Action Plan**:
  - Retain for legitimate sysadmin onion hosting.
  - Add explicit **Legal / Authorized-Use-Only** notice.
  - Provide a complete, hardened configuration guide with step-by-step verification.

---

### 10. Special Handling: `backdoor/`
- **Files**:
  - `find-1.md`
  - `find.md`
- **Detailed Content Inspection**:
  - Despite the folder name `backdoor/`, **neither file contains any backdoor, exploit, payload, reverse shell, persistence script, or evasion mechanism**.
  - **Actual Content**: Both files are **defensive incident response triage notes** designed to help a web administrator find and isolate webshells, spam injections, and unauthorized PHP files on a hacked PHP/Laravel web server.
  - Specific techniques documented:
    - Checking recently modified files: `find . -type f -mtime -30 | sort`.
    - Searching for suspicious file names (`shell.php`, `cmd.php`, `backdoor.php`, `test.php`).
    - Searching for PHP execution in upload and storage directories (`/storage/`, `/public/uploads/`).
    - Grepping for dangerous execution functions: `eval()`, `base64_decode()`, `gzinflate()`, `shell_exec()`, `passthru()`.
    - Auditing hidden files (`.*.php`, `.user.ini`, `.htaccess`).
    - Searching for malicious `auto_prepend_file` directives in `.user.ini` and `php.ini`.
    - Checking for SEO cloaking/spam (casino redirects targeting Google search crawler traffic).
    - Collecting forensic evidence into `~/security_audit/` before altering or deleting any files.
- **Problems Identified**:
  - **Misleading Name**: The folder name `backdoor/` suggests malware rather than incident response.
  - **Language**: Both files are written completely in Bengali, with raw conversational chat excerpts (`"ভালো খবর..."`, `"আপনি বলেছিলেন..."`, `"আমাকে দিন আমি বিশ্লেষণ করে বলব"`).
  - **Lack of Formal Structure**: Unorganized command dumps without clear triage phases (Detection -> Containment -> Eradication -> Recovery).
- **Action Plan**:
  - Retain purely as **defensive incident response / forensic triage** reference.
  - Under no circumstances add offensive capabilities.
  - Add a prominent **Legal / Authorized Incident Response Only** disclaimer.
  - Translate and organize into a professional Linux incident response and webshell investigation handbook.

---

## Secrets, Passwords, Tokens & Personal Identifiers Audit

| File | Item Found | Classification | Required Remediation |
|---|---|---|---|
| `gitHelp/gitHelp.txt` | `https://github.com/cybsam/linuxhelpertext.git` | Personal username & old repo name | Replace with placeholder `https://github.com/<USERNAME>/<REPOSITORY>.git`. |
| `MySql/createUserAndPermission.txt` | `CREATE USER 'sammy'@'localhost' IDENTIFIED BY 'password';` | Default user & weak hardcoded password | Replace with `'<DB_USER>'@'localhost'` and `'<SECURE_PASSWORD>'`. |
| `Linux/var-www-html.txt` | `/var/www/html/freechat/private` | Specific project directory name | Replace with generic `/var/www/html/<PROJECT_NAME>/`. |
| `network/debian-net-conf.md` | `192.168.1.100`, `192.168.1.1` | RFC 1918 Private IP examples | Mark clearly as `<STATIC_IP>` / `<GATEWAY_IP>` placeholders. |
| `vps-default/nginx/index.html` | Calls `https://ipwho.is/` | Third-party public geolocation API | Document privacy/rate-limit implications; make optional or local. |
| `LICENSE` | `Copyright (c) 2026 Shuvo Halder` | Project author copyright notice | Retain under MIT License guidelines. |

> **Credential Advisory**: No active cloud API keys, private SSH keys, database connection strings, or production credentials were detected in any file or commit history.

---

## Action Plan for Phase 1 & Subsequent Phases

1. **Phase 1 (Structure)**:
   - Propose clean `lowercase-kebab-case` naming schema in `STRUCTURE.md`.
   - Add modular `README.md` in each directory documenting its role, prerequisites, and copy-paste guidelines.
2. **Phase 2 (Root README.md)**:
   - Modernize the root reference, fix all TOC links, cross-reference duplicated monitoring/troubleshooting tools, and introduce an index to all modular sub-topics.
3. **Phase 3 (Content Upgrade)**:
   - Upgrade folder by folder (`Linux` -> `network` -> `gitHelp` -> `MySql` -> `PHP` -> `volume-swap` -> `vps-default/nginx` -> `hidden_service`).
   - Format each command with description, copy-paste-safe snippet, flag table, real-world example, and `⚠️ Warning` block where applicable.
   - Refactor `backdoor/` and `hidden_service/` strictly into defensive/hardened administrator guides with legal disclaimers.
4. **Phase 4 (Quality Pass)**:
   - Markdownlint validation, formatting normalization, adding `CONTRIBUTING.md`, `.gitignore`, and `CHANGELOG.md`.
5. **Phase 5 (Final Report)**:
   - Comprehensive audit completion summary.
