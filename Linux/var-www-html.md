# Web Directory Ownership and Permissions Guide

This guide describes how to configure secure, production-grade file permissions and user ownership for web application files under `/var/www/html` or custom virtual host document roots.

---

> [!WARNING]
> ### Why `chmod 777` is Dangerous
> Setting `chmod 777` (`rwxrwxrwx`) grants full read, write, and execute permissions to **every user and process on the system**. If an application has an unrestricted file upload vulnerability or local file inclusion bug, an attacker can write or overwrite files directly, upload webshells, and execute arbitrary code with no permission checks preventing it.
>
> In production, web files should be owned by the web server user, directories should be `755` (`rwxr-xr-x`), files should be `644` (`rw-r--r--`), and only designated storage/upload directories should receive group-writable `775` (`rwxrwxr-x`) access.

---

### chown
Change file and directory ownership recursively to the web server service account.
```bash
sudo chown -R <WEB_USER>:<WEB_GROUP> <WEB_ROOT>/<APP_NAME>
```

#### Flags
| Flag | Description |
|---|---|
| `-R`, `--recursive` | Operate on files and directories recursively |
| `-v`, `--verbose` | Output a diagnostic for every file processed |

#### Real-World Example
```bash
# Debian / Ubuntu (Nginx / Apache default user is www-data)
sudo chown -R www-data:www-data /var/www/html/my-app

# RHEL / Rocky Linux (Nginx user is nginx, Apache user is apache)
sudo chown -R nginx:nginx /var/www/html/my-app
```

---

### find (directories with 755)
Search for all directories under the web root and assign standard directory permissions (755).
```bash
sudo find <WEB_ROOT>/<APP_NAME> -type d -exec chmod 755 {} +
```

#### Flags
| Flag / Argument | Description |
|---|---|
| `-type d` | Match directories only |
| `-exec ... {} +` | Run command on matched directories in batches |

#### Real-World Example
```bash
sudo find /var/www/html/my-app -type d -exec chmod 755 {} +
```

---

### find (files with 644)
Search for all regular files under the web root and assign standard read/write permissions (644).
```bash
sudo find <WEB_ROOT>/<APP_NAME> -type f -exec chmod 644 {} +
```

#### Flags
| Flag / Argument | Description |
|---|---|
| `-type f` | Match regular files only |
| `-exec ... {} +` | Run command on matched files in batches |

#### Real-World Example
```bash
sudo find /var/www/html/my-app -type f -exec chmod 644 {} +
```

---

### chmod (writable upload and cache folders)
Grant group write permissions (775) strictly to designated upload, cache, and session storage directories.
```bash
sudo chmod -R 775 <WEB_ROOT>/<APP_NAME>/<WRITABLE_DIR>
```

#### Flags
| Flag | Description |
|---|---|
| `-R`, `--recursive` | Change files and directories recursively |

#### Real-World Example
```bash
# Allow web daemon to write uploads and cache without exposing files globally
sudo chmod -R 775 /var/www/html/my-app/storage /var/www/html/my-app/public/uploads
```

---

## ⚠️ Legacy / Do Not Use

The following commands are retained from the original repository for historical reference only:

```bash
# ⚠️ DANGEROUS: Grants full world-writable access to private and public folders
chmod -R 777 /var/www/html/freechat/private
chmod -R 777 /var/www/html/freechat/public
```

> [!CAUTION]
> **Do not run `chmod 777` in any environment.** If your web application cannot write to an upload directory, adjust the group ownership (`chown -R www-data:www-data`) and use `chmod 775`, never `777`.
