# Changelog

All notable changes to the **helper-com** documentation repository are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-11-14

### Major Modernization & Security Hardening Overhaul

This release represents a comprehensive overhaul across the entire repository to transform raw scratch notes into a production-grade, hardened systems administration and incident response knowledge base.

#### Phase 0: Security & Quality Audit
- Conducted an in-depth repository audit documented in [**`AUDIT.md`**](AUDIT.md).
- Identified security anti-patterns (e.g. world-writable permissions, unauthenticated HTTP servers, piped partition manipulation scripts, default database credentials).
- Verified absence of leaked production secrets, private keys, or active authentication tokens.

#### Phase 1: Structural Reorganization
- Reorganized repository directory structure and naming conventions documented in [**`STRUCTURE.md`**](STRUCTURE.md).
- Renamed all documentation files from `.txt` to `.md` using `git mv` (100% commit history preserved).
- Standardized file and directory names to lowercase `kebab-case`.
- Fixed typos (`partation` $\to$ `partition`, `statis` $\to$ `static`).
- Preserved all original Bengali documentation side-by-side as `<name>.bn.md`.
- Renamed `backdoor/` $\to$ `incident-response/` (clarifying defensive forensic purpose) and `hidden_service/` $\to$ `tor-onion-service/`.
- Added standardized `README.md` index files to every subfolder.

#### Phase 2: Root README Redesign
- Fully redesigned root [**`README.md`**](README.md) with status badges, license indicator, and Pre-Flight Safety Notice.
- Added a 33-entry clickable Table of Contents verified for 100% anchor match.
- Consolidated overlapping commands into a unified Monitoring & Troubleshooting section with cross-references.
- Formatted all core command entries with descriptions, flags tables, real-world examples, and safety warnings.
- Added quick reference tables for signals, exit codes, and Linux distribution directories.

#### Phase 3: Content Hardening by Folder
- **Step 1 (`Linux/`)**:
  - Replaced insecure `chmod -R 777` with standard `755`/`644` permissions and `www-data` ownership; added explanation of world-writable risks.
  - Reconfigured Python HTTP server to bind strictly to loopback (`127.0.0.1`) by default.
  - Added backup pre-flight checks and modern `parted` instructions for GPT disks; isolated destructive commands.
  - Documented kernel parameter implications (`mce=off`) in firmware guide.
- **Step 2 (`network/`)**:
  - Replaced dangerous reboot commands with an automated configuration rollback schedule (`at now + 5 minutes`).
  - Added warnings about `ifdown && ifup` dropouts over remote SSH connections.
  - Added DNS troubleshooting workflows (`systemd-resolved` vs `/etc/resolv.conf`) and a 7-step static IP troubleshooting checklist.
- **Step 3 (`gitHelp/`)**:
  - Removed all personal identifiers, emails, usernames, and hardcoded repository URLs.
  - Organized git workflows into 10 sections covering staging, branching, safe undo operations, and Conventional Commits.
- **Step 4 (`MySql/`)**:
  - Enforced strict angle-bracket placeholders (`<DB_USER>`, `<DB_PASSWORD>`, `<DB_NAME>`).
  - Replaced blank `ALL PRIVILEGES` with least-privilege permission grants.
  - Added UTF-8 database creation, authentication plugin handling (`caching_sha2_password` vs `auth_socket`), and `mysqldump` backup/restore recipes.
- **Step 5 (`PHP/`)**:
  - Hardened CLI password hashing utility (`password_hash` with Argon2id / Bcrypt and constant-time validation).
  - Documented complete PHP-FPM memory sizing formulas and pool tuning (`pm.max_children`).
  - Added production `php.ini` security directives (`disable_functions`, `expose_php = Off`).
- **Step 6 (`volume-swap/`)**:
  - Cleaned conversational chat text into structured administration playbooks.
  - Preserved original piped heredoc `fdisk` script in a marked legacy warning block while adding safe, non-destructive `growpart` instructions above it.
  - Documented swapfile creation with `dd` fallback, persistent `/etc/fstab` configuration with UUIDs, and kernel swappiness tuning.
- **Step 7 (`vps-default/`)**:
  - Translated inline Banglish comments to clear English.
  - Hardened Nginx default catch-all virtual host (`default.conf`) with Let's Encrypt webroot pass-through and dotfile deny rules.
  - Documented production recipes for WebSocket reverse proxies, HTTP security headers (HSTS, CSP), and rate limiting.
- **Step 8 (`tor-onion-service/`)**:
  - Added Legal & Authorized System Administration policy.
  - Documented complete step-by-step setup for v3 Onion Services, loopback-only binding (`127.0.0.1`), `/etc/tor/torrc` configuration, and mode `700` directory permissions.
  - Added OpSec hardening checklist (header stripping, CDN leak prevention, UNIX domain sockets).
- **Step 9 (`incident-response/`)**:
  - Clarified defensive security mission and preserved Bengali versions.
  - Formatted all forensic search commands (`find`, `grep`, `sed`, `crontab`, `ps`) with flags tables and warnings.
  - Added simulated crawler verification via `curl` to diagnose conditional SEO casino redirects.
  - Structured end-to-end NIST/SANS 6-phase incident response methodology and forensic evidence preservation procedures.

#### Phase 4: Quality & Tooling
- Added [**`CONTRIBUTING.md`**](CONTRIBUTING.md) detailing safety rules, command formatting, and pull request standards.
- Added [**`.gitignore`**](.gitignore) to prevent accidental commits of OS files, editor directories, and forensic audit dumps.
- Created [**`CHANGELOG.md`**](CHANGELOG.md) documenting complete upgrade trajectory.
- Added GitHub Actions workflow [**`.github/workflows/markdownlint.yml`**](.github/workflows/markdownlint.yml) for automated markdown linting and link verification.
- Verified 0 broken links and 100% balanced code fences across all 35+ markdown files.
