# Linux Web Server Malware and Webshell Triage

> [!IMPORTANT]
> **Legal & Authorized Incident Response Notice**:
> This guide is strictly intended for defensive incident response, forensic triage, and security auditing on systems you own or manage with explicit written authorization. All commands in this guide are read-only diagnostic utilities designed to identify unauthorized modifications without altering or destroying forensic evidence.
>
> An original Bengali version of this guide is preserved at [**`find.bn.md`**](find.bn.md).

---

## Table of Contents

- [Pre-requisites & Workspace Setup](#pre-requisites--workspace-setup)
- [Diagnostic Command Reference](#diagnostic-command-reference)
  - [find -mtime (Recent File Modifications)](#find--mtime-recent-file-modifications)
  - [find with Regex Filter (Suspicious PHP Names)](#find-with-regex-filter-suspicious-php-names)
  - [find -path (Unauthorized PHP in Uploads/Storage)](#find--path-unauthorized-php-in-uploadsstorage)
  - [grep -RniE (Dangerous PHP Functions)](#grep--rnie-dangerous-php-functions)
  - [find . -name ".*" (Hidden Files)](#find--name--hidden-files)
  - [find -ctime (Recently Changed Inodes)](#find--ctime-recently-changed-inodes)
  - [find -perm (World-Writable Permissions)](#find--perm-world-writable-permissions)
  - [find .htaccess (Web Server Config Auditing)](#find-htaccess-web-server-config-auditing)
  - [crontab -l (Persistence Mechanisms)](#crontab--l-persistence-mechanisms)
  - [ps aux (Suspicious Active Processes)](#ps-aux-suspicious-active-processes)
- [Forensic Evidence Preservation Workflow](#forensic-evidence-preservation-workflow)
- [Next Steps in Incident Handling](#next-steps-in-incident-handling)

---

## Pre-requisites & Workspace Setup

Before executing inspection queries, change directory into your target web application root and verify your current path:

```bash
cd <WEB_ROOT>/<APP_NAME>
pwd
ls -la
```

| Argument | Description |
| :--- | :--- |
| `<WEB_ROOT>/<APP_NAME>` | Absolute path to the web project root (e.g., `/var/www/html/mysite`) |

---

## Diagnostic Command Reference

### find -mtime (Recent File Modifications)
Locate all regular files modified within the past 30 days to detect recent unauthorized modifications.
```bash
find . -type f -mtime -30 | sort
```
| Flag | Description |
| :--- | :--- |
| `-type f` | Restrict search strictly to regular files (ignores directories, symlinks, sockets) |
| `-mtime -n` | Matches files modified less than *n* days ago (`-30` means 0 to 30 days ago) |
| `\| sort` | Pipe results through `sort` to organize paths alphabetically for easy review |

**Real-world example:**
```bash
# Find files modified in the last 7 days and output with human-readable timestamps
find . -type f -mtime -7 -exec ls -lh --time-style=long-iso {} + | awk '{print $6, $7, $9}'
```

---

### find with Regex Filter (Suspicious PHP Names)
Detect PHP files whose names match common webshell, dropper, or evasion naming conventions.
```bash
find . -type f -name "*.php" | grep -Ei "(shell|cmd|upload|backdoor|cache|test|admin|file|x|z|1)\.php"
```
| Flag | Description |
| :--- | :--- |
| `-name "*.php"` | Case-sensitive pattern matching all files ending in `.php` |
| `grep -E` | Interpret pattern as an Extended Regular Expression (ERE) |
| `grep -i` | Perform case-insensitive matching |

**Real-world example:**
```bash
# Search for single-letter or purely numeric PHP scripts (e.g. a.php, 1.php)
find . -type f -regextype posix-extended -regex ".*/([a-z]|[0-9])\.php"
```

> [!NOTE]
> Legitimate CMS frameworks may occasionally use names like `admin.php` or `file.php`. Always inspect file contents and modification dates before drawing conclusions.

---

### find -path (Unauthorized PHP in Uploads/Storage)
Audit upload, cache, and public media directories that should contain only static assets (images, PDFs) for unexpected executable PHP scripts.
```bash
find . \( -path "./storage/*" -o -path "./public/uploads/*" -o -path "./public/images/*" -o -path "./tmp/*" \) -type f -name "*.php"
```
| Flag | Description |
| :--- | :--- |
| `-path "<PATTERN>"` | Matches the entire pathname of the file against the specified pattern |
| `\(` and `\)` | Group multiple path conditions together |
| `-o` | Logical OR operator connecting path filters |

**Real-world example:**
```bash
# Scan writable upload directories for executable scripts (.php, .phtml, .php5, .phar)
find ./public/uploads -type f \( -name "*.php*" -o -name "*.phar" -o -name "*.sh" \)
```

> [!IMPORTANT]
> A PHP file inside an upload or temporary directory is almost always an indicator of compromise (IOC), as legitimate web applications store uploads as inert media assets.

---

### grep -RniE (Dangerous PHP Functions)
Recursively scan application code for functions commonly abused by webshells to execute system commands or unpack obfuscated code.
```bash
grep -RniE "eval\s*\(|base64_decode\s*\(|gzinflate\s*\(|shell_exec\s*\(|system\s*\(|exec\s*\(|passthru\s*\(|assert\s*\(" .
```
| Flag | Description |
| :--- | :--- |
| `-R` | Search all files under current directory recursively |
| `-n` | Prefix each line of output with its 1-based line number in the source file |
| `-i` | Ignore case distinctions in patterns and input data |
| `-E` | Extended regular expression syntax |

**Real-world example:**
```bash
# Scan application code while excluding third-party dependency folders to reduce noise
grep -RniE --exclude-dir={vendor,node_modules,.git} "eval\s*\(|base64_decode\s*\(|assert\s*\(" .
```

> [!TIP]
> Focus your investigation on results combining `eval()` with `base64_decode()`, `gzinflate()`, or `str_rot13()`. This chain is the standard packing signature for commodity PHP webshells.

---

### find . -name ".*" (Hidden Files)
Locate hidden dotfiles within the web application tree to detect disguised scripts, dotfile backdoors, or rogue configurations.
```bash
find . -name ".*" -type f
```
| Flag | Description |
| :--- | :--- |
| `-name ".*"` | Matches files whose name begins with a period (hidden in standard `ls`) |
| `-type f` | Excludes hidden directory nodes like `.git/` or `.` and `..` |

**Real-world example:**
```bash
# Find hidden files while filtering out expected project dotfiles (.gitignore, .env)
find . -type f -name ".*" ! -name ".gitignore" ! -name ".env" ! -name ".editorconfig"
```

---

### find -ctime (Recently Changed Inodes)
Search for files whose status (permissions, ownership, renaming, or link count) changed within the last 30 days.
```bash
find . -type f -ctime -30
```
| Flag | Description |
| :--- | :--- |
| `-ctime -n` | Matches files whose file status/inode metadata was changed less than *n* days ago |

**Real-world example:**
```bash
# Identify files with recent status changes in /var/www
find /var/www -type f -ctime -7 -ls
```

> [!NOTE]
> Unlike `-mtime` (which attackers can tamper with using `touch -t` / timestomping), `-ctime` is updated directly by the Linux kernel whenever file attributes change and is significantly harder for unprivileged web attackers to forge.

---

### find -perm (World-Writable Permissions)
Identify directories and files configured with world-writable (`777`) permissions that permit unauthorized write or overwrite access by arbitrary system users.
```bash
find . -type d -perm -777
find . -type f -perm -777
```
| Flag | Description |
| :--- | :--- |
| `-perm -777` | Matches files or directories where read, write, and execute bits are enabled for all users |

**Real-world example:**
```bash
# Output permission strings alongside path names
find . -perm -0002 -type f -exec ls -ld {} +
```

> [!WARNING]
> World-writable files (`chmod 777`) allow any local user, web service user (`www-data`), or compromised process on the system to overwrite your code. See the [Webroot Permissions Guide](../Linux/var-www-html.md) for remediation standards.

---

### find .htaccess (Web Server Config Auditing)
Locate and list all Apache `.htaccess` override configuration files across the project tree.
```bash
find . -name ".htaccess" -exec ls -l {} \;
```
| Flag | Description |
| :--- | :--- |
| `-exec <CMD> {} \;` | Execute `<CMD>` for each matched file (`{}` is replaced by the file path) |

**Real-world example:**
```bash
# Search for suspicious redirect directives in all .htaccess files
find . -name ".htaccess" -exec grep -HniE "RewriteRule|Redirect|auto_prepend_file|SetHandler" {} +
```

---

### crontab -l (Persistence Mechanisms)
Inspect scheduled tasks for the current user to detect persistence scripts or reverse shell callbacks.
```bash
crontab -l
```
| Flag | Description |
| :--- | :--- |
| `-l` | Display current crontab entries to stdout |
| `-u <USER>` | Display crontab of a specific user (requires root/sudo privileges) |

**Real-world example:**
```bash
# Audit crontabs across web service accounts and system-wide cron directories
sudo crontab -u www-data -l
sudo ls -la /etc/cron.* /etc/crontab
```

> [!CAUTION]
> Never type `crontab -r`. The `-r` flag **removes** the entire crontab without confirmation. To edit, always use `crontab -e`.

---

### ps aux (Suspicious Active Processes)
Inspect running processes for unusual PHP, Python, or shell processes executing from webroots or temporary directories.
```bash
ps aux | grep -i php
```
| Flag | Description |
| :--- | :--- |
| `a` | Display processes for all users |
| `u` | Display process owner and detailed resource usage columns |
| `x` | Include processes not attached to a terminal (background daemons, web workers) |

**Real-world example:**
```bash
# Filter processes running from /tmp, /dev/shm, or webroot directories
ps aux | grep -E "(/tmp|/dev/shm|/var/www)" | grep -v grep
```

---

## Forensic Evidence Preservation Workflow

Before modifying, moving, or removing suspected malware files, preserve forensic evidence in an isolated directory:

```bash
# 1. Create a timestamped evidence directory outside the webroot
mkdir -p ~/security_audit_$(date +%Y%m%d_%H%M%S)
AUDIT_DIR=~/security_audit_$(date +%Y%m%d_%H%M%S)

# 2. Export list of recently modified files
find . -type f -mtime -30 > "$AUDIT_DIR/recent_files.txt"

# 3. Export occurrences of suspicious execution functions
grep -RniE --exclude-dir={vendor,node_modules} "eval\s*\(|base64_decode\s*\(|shell_exec\s*\(|system\s*\(|assert\s*\(" . > "$AUDIT_DIR/suspicious_functions.txt" 2>/dev/null

# 4. Generate SHA-256 cryptographic hashes of all PHP files
find . -type f -name "*.php" -exec sha256sum {} + > "$AUDIT_DIR/php_hashes.sha256"

# 5. Archive suspected files securely into an encrypted or restricted archive
tar -czvf "$AUDIT_DIR/quarantined_samples.tar.gz" --exclude="*.log" $(find . -type f -name "*.php" -mtime -7) 2>/dev/null
chmod 600 "$AUDIT_DIR"/*
```

---

## Next Steps in Incident Handling

1. For targeted investigation of conditional SEO casino redirects, `.user.ini` hijacking, and entrypoint tampering, proceed to [**`find-1.md`**](find-1.md).
2. For complete end-to-end incident handling methodology, consult the [**Incident Response Framework**](README.md).
