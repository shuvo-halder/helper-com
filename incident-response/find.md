# Linux Web Server Malware and Webshell Triage

> **Legal / Authorized-Use Notice**: This guide is strictly intended for incident response, malware analysis, and authorized forensic auditing on systems you own or have explicit authorization to inspect.  
> **Note**: An original Bengali version of this guide is available at [find.bn.md](find.bn.md).

These read-only diagnostic commands help system administrators identify suspicious files, webshells, unauthorized uploads, and modified code in web application directories (such as Laravel/PHP) without deleting or altering files.

---

## Pre-requisite

Navigate to your web application or project root before executing the search commands:

```bash
cd /path/to/your/web/project
pwd
ls -la
```

---

## 1. Files Modified in the Last 30 Days

List all files modified within the past 30 days:

```bash
find . -type f -mtime -30 | sort
```

---

## 2. Suspicious PHP File Names

Search for PHP files containing common backdoor keywords:

```bash
find . -type f -name "*.php" | grep -Ei "(shell|cmd|upload|backdoor|cache|test|admin|file|x|z|1)\.php"
```

---

## 3. Unauthorized PHP Files in Storage / Uploads

Check directories that should only contain static assets or uploads for unexpected PHP files:

```bash
find . \( -path "./storage/*" -o -path "./public/uploads/*" -o -path "./public/images/*" -o -path "./tmp/*" \) -type f -name "*.php"
```

---

## 4. Dangerous PHP Execution Functions

Search application files for functions frequently abused by webshells:

```bash
grep -RniE "eval\s*\(|base64_decode\s*\(|gzinflate\s*\(|shell_exec\s*\(|system\s*\(|exec\s*\(|passthru\s*\(|assert\s*\(" .
```

---

## 5. Hidden Files

Locate hidden files within the project tree:

```bash
find . -name ".*" -type f
```

---

## 6. Recently Created Files

Find files created or status-changed within the last 30 days:

```bash
find . -type f -ctime -30
```

---

## 7. Insecure File and Directory Permissions

Identify files and directories with world-writable (`777`) permissions:

```bash
# World-writable directories
find . -type d -perm -777

# World-writable files
find . -type f -perm -777
```

---

## 8. Audit `.htaccess` Configurations

Review all `.htaccess` files for unauthorized rewrite or redirect rules:

```bash
find . -name ".htaccess" -exec ls -l {} \;
```

---

## 9. Review Scheduled Cron Jobs

Inspect crontabs for unauthorized persistent jobs:

```bash
crontab -l
```

---

## 10. Inspect Running PHP Processes

Check active PHP processes for unexpected scripts:

```bash
ps aux | grep php
```

---

## 11. Collect Forensic Evidence

Before removing or modifying suspected malware, export reports for documentation:

```bash
mkdir -p ~/security_audit

# Export list of recently modified files
find . -type f -mtime -30 > ~/security_audit/recent_files.txt

# Export occurrences of suspicious functions
grep -RniE "eval\s*\(|base64_decode\s*\(|gzinflate\s*\(|shell_exec\s*\(|system\s*\(|exec\s*\(|passthru\s*\(|assert\s*\(" . > ~/security_audit/suspicious_code.txt 2>/dev/null

# Export full inventory of PHP files
find . -type f -name "*.php" > ~/security_audit/all_php_files.txt
```
