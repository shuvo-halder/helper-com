# Contributing to helper-com

Thank you for your interest in contributing to **helper-com**! This repository is a production-hardened command reference and troubleshooting playbook for Linux system administrators, DevOps engineers, and security incident responders.

To ensure consistency, security, and copy-paste safety across all documentation, all contributions must adhere to the standards outlined below.

---

## Table of Contents

- [Core Principles & Safety Rules](#core-principles--safety-rules)
- [Mandatory Command Entry Format](#mandatory-command-entry-format)
- [Standard Placeholder Conventions](#standard-placeholder-conventions)
- [Language & Translation Policy](#language--translation-policy)
- [Markdown & Formatting Standards](#markdown--formatting-standards)
- [Git & Commit Conventions](#git--commit-conventions)
- [Pull Request Checklist](#pull-request-checklist)

---

## Core Principles & Safety Rules

1. **Copy-Paste Safety First**:
   - Commands should never cause irreversible data loss when pasted into a terminal.
   - Potentially destructive commands (`rm -rf`, `mkfs`, `fdisk`, `swapoff -a`, `dd`, `chmod -R 777`) must include an explicit `> [!WARNING]` or `> [!CAUTION]` callout and provide a safer, non-destructive alternative.
2. **Defensive & Authorized Incident Response**:
   - Any security or forensic tools added to `incident-response/` or `tor-onion-service/` must be strictly defensive.
   - Do not add or document offensive exploits, brute-forcers, automated attack scripts, or obfuscation tools.
3. **No Invented Facts**:
   - Every command and flag must be verified against official man pages or distribution documentation.
   - If a command flag varies between distributions or kernel versions and you cannot verify it across all platforms, append `<!-- VERIFY: reason -->` rather than guessing.

---

## Mandatory Command Entry Format

Every command documented in this repository must follow this three-part structure:

````markdown
### command
One-line summary explaining what the command accomplishes.

```bash
command [FLAGS] <ARGUMENTS>
```

| Flag / Option | Description |
| :--- | :--- |
| `-f` | Useful description of the flag |
| `-v` | Useful description of the flag |

**Real-world example:**
```bash
command -fv /path/to/target
```

> [!WARNING]
> Explain any risks (e.g. data loss, service restart, connection drop) and give the safer alternative.
````

---

## Standard Placeholder Conventions

Never use real usernames, server hostnames, public IP addresses, database passwords, or personal email addresses. Always use standardized angle-bracket placeholders:

| Asset Type | Standard Placeholder | Forbidden Example |
| :--- | :--- | :--- |
| **User Account** | `<USERNAME>` or `<APP_USER>` | `john`, `admin`, `sam` |
| **Domain Name** | `<DOMAIN_NAME>` or `<EXAMPLE.COM>` | `mysite.com`, `google.com` |
| **Email Address** | `<YOUR_EMAIL>` or `<ADMIN@EXAMPLE.COM>` | `user@gmail.com` |
| **IPv4 Address** | RFC 5737 ranges (`192.0.2.x`, `198.51.100.x`, `203.0.113.x`) | `1.1.1.1`, `192.168.1.100` |
| **Database Credentials**| `<DB_USER>`, `<DB_PASSWORD>`, `<DB_NAME>` | `root`, `password123`, `test` |
| **Webroot Path** | `<WEB_ROOT>/<APP_NAME>` | `/var/www/myproject` |
| **Network Interface** | `<INTERFACE>` | `eth0`, `ens33` (unless labeled as distro example) |

---

## Language & Translation Policy

- **Primary Language**: English is the primary language for all main `.md` files and folder `README.md` documents.
- **Bengali Parallel Documentation**: The repository maintains Bengali originals and translations side-by-side using the `<name>.bn.md` naming convention (e.g. `find.bn.md` alongside `find.md`).
- **Preservation**: When editing an English guide, do not overwrite or delete the companion `*.bn.md` file. Always link to it from the top of the English document and from the directory index.

---

## Markdown & Formatting Standards

1. **File Naming**: Use lowercase `kebab-case.md` for all markdown documentation. Avoid spaces, uppercase letters, or non-standard file extensions (`.txt`).
2. **Code Fences**: Always specify the language identifier on triple-backtick fences (`bash`, `nginx`, `php`, `ini`, `sql`, `yaml`, `text`).
3. **Internal Links**: Use relative file links with explicit `.md` extensions (e.g. `[Webroot Guide](Linux/var-www-html.md)`). Verify that all links point to existing files.
4. **GitHub Alerts**: Use standard GFM alert syntax:
   - `> [!NOTE]` for helpful context or background details.
   - `> [!TIP]` for operational shortcuts and best practices.
   - `> [!IMPORTANT]` for essential operational prerequisites or legal notices.
   - `> [!WARNING]` for commands that could cause downtime or lockouts.
   - `> [!CAUTION]` for destructive commands involving potential data loss.

---

## Git & Commit Conventions

Commit messages must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `docs(<scope>): <description>` (e.g. `docs(nginx): add websocket reverse proxy recipe`)
- `fix(<scope>): <description>` (e.g. `fix(swap): correct parted sector calculation`)
- `ci: <description>` (e.g. `ci: add markdownlint workflow`)

Valid scopes: `linux`, `network`, `git`, `mysql`, `php`, `swap`, `nginx`, `tor`, `ir`, `quality`.

---

## Pull Request Checklist

Before submitting a Pull Request, confirm that:

- [ ] All code fences are properly opened and closed with valid syntax highlighting tags.
- [ ] Every new command includes a description, flags table, real-world example, and safety warning where appropriate.
- [ ] All credentials, emails, and IPs use standard `<PLACEHOLDER>` syntax or RFC 5737 test addresses.
- [ ] No historical `*.bn.md` files were deleted or overwritten.
- [ ] All relative links resolve to existing files (no 404 dead links).
- [ ] The change has been tested in a local VM or sandbox environment where applicable.
