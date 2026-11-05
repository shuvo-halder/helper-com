# Investigating Webshell Injections and Conditional Redirects

> **Legal / Authorized-Use Notice**: This guide is strictly intended for incident response, malware analysis, and authorized forensic auditing on systems you own or have explicit authorization to inspect.  
> **Note**: An original Bengali version of this guide is available at [find-1.bn.md](find-1.bn.md).

When a web application exhibits suspicious behavior (such as spam redirects or search-engine-cloaked redirects) while `.htaccess` rules appear standard, check for code injection, bootstrap tampering, or configuration hijacking.

---

## Triage Verification Commands

### 1. Verify `public/index.php` Entrypoint

Inspect the first 80 lines of the public web entrypoint for unexpected prepended code:

```bash
sed -n '1,80p' public/index.php
```

---

### 2. Check for Unexpected Root `index.php`

Determine whether an unauthorized root `index.php` was added:

```bash
ls -la | grep index.php
```

If present, inspect its header:

```bash
sed -n '1,80p' index.php
```

---

### 3. Check for User-Level INI Configurations

Search for `.user.ini` files that may override PHP settings:

```bash
find . -name ".user.ini" -exec cat {} \;
```

---

### 4. Search for `auto_prepend_file` Injections

Check whether malicious code is automatically included before every script execution:

```bash
grep -R "auto_prepend_file" .
```

---

### 5. Detect Hidden PHP Files

Locate hidden PHP files (dot-prefixed):

```bash
find . -type f -name ".*.php"
```

---

### 6. Scan for Base64 Decoders (Excluding Dependencies)

Search application codebase for base64 decoding patterns outside `vendor` and `node_modules`:

```bash
grep -Rni --exclude-dir=vendor --exclude-dir=node_modules "base64_decode(" .
```

---

### 7. Scan for `eval()` Patterns (Excluding Dependencies)

Search for dynamic evaluation functions in application code:

```bash
grep -Rni --exclude-dir=vendor --exclude-dir=node_modules "eval(" .
```

---

### 8. Inspect Files Modified in the Last 7 Days

List recent file changes to spot freshly injected files:

```bash
find . -type f -mtime -7 | sort
```

---

## Understanding Conditional Redirects (SEO Cloaking)

Malicious redirects often behave conditionally:
- **Search Engine Referrers**: Redirects occur only when referred from Google or Bing search queries.
- **User-Agent Filtering**: The site renders normally for desktop browsers, but triggers spam redirects on mobile devices.
- **One-time Sessions**: Redirects trigger only on the first visit via cookies or session tracking.

If symptoms match conditional redirects, inspect the application database tables, caching layers, and search-engine crawler view outputs alongside the filesystem.
