# Linux Web Server Incident Response & Forensic Triage

This directory contains forensic investigation guides and command sequences designed to detect webshells, backdoor injections, unauthorized code modifications, and spam redirects on compromised web servers (e.g., PHP / Laravel / WordPress).

---

## Documents in This Folder

- [**`find.md`**](find.md): Read-only forensic search commands to audit modified files, suspicious file names, world-writable directories, unauthorized PHP files in upload/storage locations, and dangerous PHP execution functions.
  - [বাংলা সংস্করণ / Original Bengali Version](find.bn.md)
- [**`find-1.md`**](find-1.md): Investigating subtle code injections, malicious `auto_prepend_file` directives in `.user.ini`, bootstrap tampering (`public/index.php`), and conditional search-engine cloaking (SEO casino redirects).
  - [বাংলা সংস্করণ / Original Bengali Version](find-1.bn.md)

---

## Legal & Authorized-Use Policy

> ⚠️ **NOTICE**: All techniques and commands in this folder are **strictly defensive**. They are intended for legitimate system administrators, security engineers, and site owners conducting authorized forensic investigations and incident response on systems they own or manage with explicit consent.
>
> **Do not extend, add, or test offensive payloads, unauthorized access mechanisms, or anti-forensic persistence tools in this repository.**

---

## Incident Response Workflow (Standard SANS / NIST Model)

1. **Identification**: Run non-destructive search queries (`find`, `grep`) to map all modified or suspicious files.
2. **Containment**: Isolate the affected web application (e.g., revoke public write access, put application into maintenance mode, block malicious IP ranges).
3. **Forensic Evidence Collection**: Export evidence into a dedicated audit directory before modifying or deleting any suspicious files:
   ```bash
   mkdir -p ~/security_audit
   ```
4. **Eradication**: Safely remove confirmed webshells, clean injected code, and restore verified backups or clean source control tags.
5. **Recovery & Hardening**: Fix root causes (outdated plugins, weak credentials, file permissions, disabled dangerous PHP functions), rotate all database and system credentials, and redeploy.
