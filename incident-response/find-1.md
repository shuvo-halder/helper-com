# Investigating Webshell Injections and Conditional Redirects

> [!IMPORTANT]
> **Legal & Authorized Incident Response Notice**:
> This guide is strictly intended for defensive incident response, forensic triage, and security auditing on systems you own or manage with explicit written authorization. All commands in this guide are read-only diagnostic utilities designed to identify unauthorized modifications without altering or destroying forensic evidence.
>
> An original Bengali version of this guide is preserved at [**`find-1.bn.md`**](find-1.bn.md).

---

## Table of Contents

- [Overview: Stealth Injections & SEO Cloaking](#overview-stealth-injections--seo-cloaking)
- [Diagnostic Command Reference](#diagnostic-command-reference)
  - [sed -n (Inspect Application Entrypoint)](#sed--n-inspect-application-entrypoint)
  - [ls -la (Detect Rogue Root index.php)](#ls--la-detect-rogue-root-indexphp)
  - [find .user.ini (PHP Runtime Overrides)](#find-userini-php-runtime-overrides)
  - [grep auto_prepend_file (Global Code Prepending)](#grep-auto_prepend_file-global-code-prepending)
  - [find .*.php (Hidden Dot-Prefixed PHP Scripts)](#find-php-hidden-dot-prefixed-php-scripts)
  - [grep base64_decode (Obfuscated Payloads)](#grep-base64_decode-obfuscated-payloads)
  - [grep eval (Dynamic Code Execution)](#grep-eval-dynamic-code-execution)
  - [find -mtime -7 (Recent Changes)](#find--mtime--7-recent-changes)
  - [curl Diagnostic (Simulate Crawler Requests)](#curl-diagnostic-simulate-crawler-requests)
- [Mechanisms of Conditional Redirects](#mechanisms-of-conditional-redirects)
- [Remediation & Hardening Actions](#remediation--hardening-actions)

---

## Overview: Stealth Injections & SEO Cloaking

Modern web application malware often operates stealthily through **conditional redirection** (also known as *SEO cloaking* or *spam injection*):
- Site administrators and direct visitors see the normal homepage.
- Visitors referred from search engines (Google, Bing) or specific mobile devices are conditionally redirected to spam, pharmacy, or malicious casino websites.
- Search engine crawlers receive injected spam text and backlinks that damage domain reputation.

Because `.htaccess` files may appear completely clean, the attack vector often resides in PHP configuration overrides (`.user.ini`), prepended bootstrap code, or hidden files.

---

## Diagnostic Command Reference

### sed -n (Inspect Application Entrypoint)
Inspect the first 80 lines of the public web entrypoint to check for prepended malicious PHP code, obfuscated strings, or suspicious includes.
```bash
sed -n '1,80p' public/index.php
```
| Flag | Description |
| :--- | :--- |
| `-n` | Suppress automatic printing of every line |
| `'1,80p'` | Print strictly lines 1 through 80 of the specified file |

**Real-world example:**
```bash
# Check the first 50 lines of WordPress or Laravel entrypoints
sed -n '1,50p' index.php
```

> [!TIP]
> In modern frameworks (such as Laravel or Symfony), `public/index.php` contains clean, human-readable bootstrapping code. If the file opens with an unformatted, heavily encoded single line containing `eval` or `base64_decode`, it has been tampered with.

---

### ls -la (Detect Rogue Root index.php)
Determine whether an unauthorized `index.php` file exists in the repository root outside the public webroot.
```bash
ls -la | grep -i index.php
```
| Flag | Description |
| :--- | :--- |
| `-l` | Use long listing format displaying permissions, owner, and modification timestamps |
| `-a` | Show all files, including hidden dotfiles |

**Real-world example:**
```bash
# In Laravel, the public entrypoint belongs in public/index.php; a root index.php is often unauthorized
if [ -f index.php ]; then sed -n '1,40p' index.php; fi
```

---

### find .user.ini (PHP Runtime Overrides)
Locate and display user-level `.user.ini` configuration files that can override PHP runtime settings on PHP-FPM servers.
```bash
find . -name ".user.ini" -exec cat {} \;
```
| Flag | Description |
| :--- | :--- |
| `-name ".user.ini"` | Exact match for user INI configuration files |
| `-exec cat {} \;` | Print the contents of each matched file immediately |

**Real-world example:**
```bash
# Inspect all user INI files and check their last modification time
find . -name ".user.ini" -exec ls -la {} \;
```

> [!WARNING]
> `.user.ini` files are read by PHP-FPM on every directory request. Attackers frequently drop `.user.ini` containing `auto_prepend_file` to execute backdoors globally before legitimate application code runs.

---

### grep auto_prepend_file (Global Code Prepending)
Search the entire project directory for directives that force PHP to prepend and execute a file before every request.
```bash
grep -Rni "auto_prepend_file" .
```
| Flag | Description |
| :--- | :--- |
| `-R` | Recursively read all files under the directory |
| `-n` | Print line number with output lines |
| `-i` | Ignore case distinctions |

**Real-world example:**
```bash
# Search both .htaccess, .user.ini, and PHP configuration directories
grep -Rni "auto_prepend_file" . /etc/php/
```

---

### find .*.php (Hidden Dot-Prefixed PHP Scripts)
Locate hidden PHP scripts (files whose names begin with a period followed by any characters ending in `.php`).
```bash
find . -type f -name ".*.php"
```
| Flag | Description |
| :--- | :--- |
| `-type f` | Matches regular files only |
| `-name ".*.php"` | Matches hidden files ending in `.php` (e.g. `.session.php`, `.wp-cache.php`) |

**Real-world example:**
```bash
# Search for hidden files with executable extensions across the entire project
find . -type f \( -name ".*.php" -o -name ".*.phtml" -o -name ".*.ico" \)
```

> [!IMPORTANT]
> Legitimate web applications do not use dot-prefixed PHP files. Any `.something.php` file inside your codebase warrants immediate forensic scrutiny.

---

### grep base64_decode (Obfuscated Payloads)
Search the application codebase for base64 decoding patterns while excluding vendor and dependency directories to reduce false positives.
```bash
grep -Rni --exclude-dir=vendor --exclude-dir=node_modules "base64_decode(" .
```
| Flag | Description |
| :--- | :--- |
| `--exclude-dir=<DIR>` | Skip directory matches matching the pattern to filter out third-party packages |
| `"base64_decode("` | String literal pattern searching for base64 decoder invocation |

**Real-world example:**
```bash
# Search for combined decoder patterns often used in webshell stagers
grep -RniE --exclude-dir={vendor,node_modules,storage} "base64_decode\s*\(\s*['\"]" .
```

---

### grep eval (Dynamic Code Execution)
Search application code for dynamic PHP evaluation functions outside vendor libraries.
```bash
grep -Rni --exclude-dir=vendor --exclude-dir=node_modules "eval(" .
```
| Flag | Description |
| :--- | :--- |
| `--exclude-dir=vendor` | Excludes Composer dependencies |
| `--exclude-dir=node_modules` | Excludes frontend npm dependencies |

**Real-world example:**
```bash
# Find eval calls executing variable expressions (e.g. eval($code) or eval($_POST['...']))
grep -RniE --exclude-dir={vendor,node_modules} "eval\s*\(\s*\\\$" .
```

---

### find -mtime -7 (Recent Changes)
List all files created or modified within the past 7 days to isolate newly dropped webshells or modified core scripts.
```bash
find . -type f -mtime -7 | sort
```
| Flag | Description |
| :--- | :--- |
| `-mtime -7` | Modified in the last 7 days |
| `sort` | Orders output alphabetically |

**Real-world example:**
```bash
# List recent PHP files with modification timestamp and file size
find . -type f -name "*.php" -mtime -7 -exec ls -la {} +
```

---

### curl Diagnostic (Simulate Crawler Requests)
Test whether your server serves different HTTP responses based on User-Agent or Referrer headers (SEO cloaking verification).
```bash
curl -I -A "Googlebot" -e "https://www.google.com" http://127.0.0.1
```
| Flag | Description |
| :--- | :--- |
| `-I, --head` | Fetch HTTP headers only |
| `-A <STRING>` | Set the `User-Agent` string to simulate Googlebot or a mobile browser |
| `-e <URL>` | Set the HTTP `Referer` URL to simulate traffic originating from search engines |

**Real-world example:**
```bash
# Compare normal browser request vs. search-referred request
curl -s -I http://127.0.0.1/
curl -s -I -A "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)" -e "https://www.google.com/" http://127.0.0.1/
```

> [!TIP]
> If the normal request returns `200 OK` while the search-referred request returns a `301 Moved Permanently` or `302 Found` to an external spam URL, conditional redirection is active on the server.

---

## Mechanisms of Conditional Redirects

1. **HTTP Referer Filtering**:
   Injected code inspects `$_SERVER['HTTP_REFERER']`. If the string contains `google`, `yahoo`, or `bing`, it emits a `header("Location: https://spam-domain.example")` exit.
2. **User-Agent Cloaking**:
   If `$_SERVER['HTTP_USER_AGENT']` contains `bot`, `crawler`, or `spider`, the script serves doorway pages filled with keyword spam to boost the attacker's search ranking.
3. **Cookie / IP Rate-Limiting**:
   Malicious scripts frequently set a cookie (`setcookie('visited', '1', ...)`) so each victim is redirected only once. Subsequent visits show the real site, making manual reproduction difficult for administrators.

---

## Remediation & Hardening Actions

1. **Neutralize Malicious Directives**:
   If `.user.ini` contains `auto_prepend_file`, remove the file or comment out the directive, then restart PHP-FPM:
   ```bash
   sudo systemctl restart php-fpm || sudo systemctl restart php8.2-fpm
   ```
2. **Restore Core Files from Git**:
   If tracked repository files were modified:
   ```bash
   git status
   git diff public/index.php
   # Verify before checkout
   git checkout public/index.php
   ```
3. **Disable Dangerous Functions in `php.ini`**:
   Add to `disable_functions` in your production PHP configuration:
   ```ini
   disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_multi_exec,parse_ini_file,show_source
   ```
4. Consult [**`find.md`**](find.md) for broad filesystem auditing and [**`README.md`**](README.md) for the complete containment protocol.
