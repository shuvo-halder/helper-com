# Repository Structure & Architecture (`STRUCTURE.md`)

**Date**: November 5, 2026  
**Repository**: `helper-com`  
**Branch**: `docs/upgrade`  
**Phase**: Phase 1 (Structure & Layout)

---

## 1. Overview & Naming Conventions

This repository is structured as a modular, copy-paste-safe Linux administration and DevOps handbook.

### Naming Standards
- **File Extensions**: All documentation files use Markdown (`.md`). Configuration templates retain standard extensions (`.conf`, `.html`, `.php`). No raw unformatted `.txt` files.
- **Naming Pattern**: Consistent `lowercase-kebab-case` without spaces, special characters, or misspelled words.
- **Multilingual Support**: Primary documentation is maintained in clear, concise English (`<name>.md`). Original Bengali versions are preserved with full git history as side-by-side files (`<name>.bn.md`) and linked in both language documents.
- **Folder Modularization**: Each directory includes an informative `README.md` explaining scope, prerequisites, safety protocols, and a linked index of all files in that section.

---

## 2. Directory Tree Layout

```text
helper-com/
├── AUDIT.md                             # Comprehensive repository security & content audit
├── STRUCTURE.md                         # Architecture, rename mapping, and security plan
├── LICENSE                              # MIT License
├── README.md                            # Central reference, index, and navigation handbook
│
├── Linux/                               # Core Linux OS administration
│   ├── README.md                        # Folder overview & quick index
│   ├── partition.md                     # Partition layout & mount hierarchy notes
│   ├── python3-server.md                # Python HTTP server commands & security binding
│   ├── ubuntu-firmware.md               # GRUB bootloader parameters & update-grub
│   └── var-www-html.md                  # Webroot directory permissions (least privilege)
│
├── gitHelp/                             # Git setup & version control workflows
│   ├── README.md                        # Folder overview & quick index
│   ├── git-global-configure.md          # Global & repository user/email identity configuration
│   └── git-help.md                      # Git init, remote addition, and initial commit recipe
│
├── MySql/                               # MySQL & MariaDB administration
│   ├── README.md                        # Folder overview & quick index
│   └── create-user-and-permission.md    # Scoped user creation & database permissions
│
├── PHP/                                 # PHP administration & CLI tools
│   ├── README.md                        # Folder overview & security guidance
│   └── make_hash.php                    # CLI password hashing script (bcrypt / Argon2id)
│
├── network/                             # Networking, static interfaces, and cloud-init
│   ├── README.md                        # Folder overview & quick index
│   ├── debian-net-conf.md               # Debian static IP configuration (English)
│   ├── debian-net-conf.bn.md            # Debian static IP configuration (Bengali original)
│   └── static-ip-fails.md               # Disabling cloud-init network overwrite on cloud VMs
│
├── volume-swap/                         # Storage management, LVM, and swap
│   ├── README.md                        # Folder overview & quick index
│   ├── centos-swap-partition.md         # Dedicated swap partition creation with fdisk/mkswap
│   ├── centos9-volume-swap-partition-extend.md # LVM root & swap volume expansion on CentOS 9
│   ├── debian.md                        # Debian disk resize notes & fdisk warnings
│   ├── swap-extends.md                  # Dynamic swap file addition and persistence
│   ├── volume-extends.md                # LVM & partition extension reference (growpart, pvresize)
│   └── volume-resize-guide.md           # Production decision tree for ext4, XFS, and LVM
│
├── vps-default/                         # Cloud VPS baseline configurations
│   ├── README.md                        # Purpose & deployment overview
│   └── nginx/                           # Nginx default server block & holding page
│       ├── README.md                    # Server block deployment & testing guide
│       ├── default.conf                 # Default catch-all server block (ACME, 404, rate limits)
│       └── index.html                   # Retro cyberpunk terminal diagnostics holding page
│
├── tor-onion-service/                   # Tor hidden service administration (renamed)
│   ├── README.md                        # Administrative purpose & network security checklist
│   └── host-tor.md                      # Torrc configuration, port forwarding, and service checks
│
└── incident-response/                   # Web application forensic triage (renamed)
    ├── README.md                        # SANS/NIST IR workflow & legal notice
    ├── find.md                          # Suspicious file & webshell triage commands (English)
    ├── find.bn.md                       # Suspicious file & webshell triage commands (Bengali)
    ├── find-1.md                        # Investigating SEO cloaking & index tampering (English)
    └── find-1.bn.md                     # Investigating SEO cloaking & index tampering (Bengali)
```

---

## 3. Path Rename Map

All existing files were moved strictly using `git mv` to preserve commit history.

| Original Path | New Path | Operation | Rationale |
|---|---|---|---|
| `Linux/partation.txt` | `Linux/partition.md` | `git mv` | Corrected spelling ("partation" -> "partition"); standardized extension to `.md`. |
| `Linux/Python3 server.txt` | `Linux/python3-server.md` | `git mv` | Removed space; standardized to lowercase-kebab-case `.md`. |
| `Linux/UbuntuFirmware.txt` | `Linux/ubuntu-firmware.md` | `git mv` | Standardized to lowercase-kebab-case `.md`. |
| `Linux/var-www-html.txt` | `Linux/var-www-html.md` | `git mv` | Standardized extension to `.md`. |
| `gitHelp/gitGlobalConfigure.txt` | `gitHelp/git-global-configure.md` | `git mv` | Standardized to lowercase-kebab-case `.md`. |
| `gitHelp/gitHelp.txt` | `gitHelp/git-help.md` | `git mv` | Standardized to lowercase-kebab-case `.md`. |
| `MySql/createUserAndPermission.txt` | `MySql/create-user-and-permission.md` | `git mv` | Standardized to lowercase-kebab-case `.md`. |
| `network/debian-net-conf.md` | `network/debian-net-conf.bn.md` | `git mv` | Preserved original Bengali file with history; created English main file `debian-net-conf.md`. |
| `network/statis-ip-fails.md` | `network/static-ip-fails.md` | `git mv` | Corrected spelling ("statis" -> "static"). |
| `volume-swap/CentOS-swap partation.md` | `volume-swap/centos-swap-partition.md` | `git mv` | Corrected spelling ("partation" -> "partition"); removed spaces; lowercase-kebab-case. |
| `volume-swap/CentOS9 volume + swap partation extend.md` | `volume-swap/centos9-volume-swap-partition-extend.md` | `git mv` | Corrected spelling; removed spaces; lowercase-kebab-case. |
| `volume-swap/readme.md` | `volume-swap/volume-resize-guide.md` | `git mv` | Renamed specific resize guide to clear title, reserving `README.md` for folder documentation. |
| `volume-swap/swap-extends.txt` | `volume-swap/swap-extends.md` | `git mv` | Standardized extension to `.md`. |
| `volume-swap/volume-extends.txt` | `volume-swap/volume-extends.md` | `git mv` | Standardized extension to `.md`. |
| `vps-default/nginx/default` | `vps-default/nginx/default.conf` | `git mv` | Added standard `.conf` extension for Nginx server block. |
| `hidden_service/` | `tor-onion-service/` | `git mv` | Renamed folder to standard descriptive title; added security policies. |
| `hidden_service/hostTor.txt` | `tor-onion-service/host-tor.md` | `git mv` | Standardized to lowercase-kebab-case `.md`. |
| `backdoor/` | `incident-response/` | `git mv` | Renamed folder from offensive connotation to actual defensive forensic purpose. |
| `backdoor/find.md` | `incident-response/find.bn.md` | `git mv` | Preserved original Bengali file with history; created English main file `find.md`. |
| `backdoor/find-1.md` | `incident-response/find-1.bn.md` | `git mv` | Preserved original Bengali file with history; created English main file `find-1.md`. |

---

## 4. Security Fix List (For Approval Before Phase 3)

The following security issues were identified in `AUDIT.md` and are scheduled for systematic remediation during Phase 3. Please review and confirm the proposed fixes:

### 1. Insecure World-Writable Permissions (`chmod -R 777`)
- **Location**: `Linux/var-www-html.md`
- **Current Content**:
  ```bash
  chmod -R 777 /var/www/html/freechat/private
  chmod -R 777 /var/www/html/freechat/public
  ```
- **Risk**: Grants global read, write, and execute permissions to any local user or webshell, enabling arbitrary script modification.
- **Proposed Phase 3 Fix**:
  - Replace with production least-privilege permission model:
    ```bash
    # Set correct ownership to the web server user
    sudo chown -R www-data:www-data /var/www/html/<PROJECT_DIR>

    # Standard secure permissions: 755 for directories, 644 for files
    sudo find /var/www/html/<PROJECT_DIR> -type d -exec chmod 755 {} +
    sudo find /var/www/html/<PROJECT_DIR> -type f -exec chmod 644 {} +

    # If application write access is required for a specific upload or cache folder:
    sudo chmod -R 775 /var/www/html/<PROJECT_DIR>/storage
    ```
  - Add explicit `⚠️ Warning` block explaining why `777` is never acceptable on web servers.

---

### 2. Default Database Password & Unscoped `ALL PRIVILEGES`
- **Location**: `MySql/create-user-and-permission.md`
- **Current Content**:
  ```sql
  CREATE USER 'sammy'@'localhost' IDENTIFIED BY 'password';
  GRANT ALL PRIVILEGES ON *.* TO 'sammy'@'localhost' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
  ```
- **Risk**: Teaches users to deploy accounts with weak default credentials (`'password'`) and creates superusers capable of dropping all databases on the server.
- **Proposed Phase 3 Fix**:
  - Provide a scoped, production-grade example using strong credential placeholders:
    ```sql
    -- Create user with secure password
    CREATE USER '<DB_USER>'@'localhost' IDENTIFIED BY '<SECURE_PASSWORD>';

    -- Grant scoped permissions only to the application database
    GRANT ALL PRIVILEGES ON <DATABASE_NAME>.* TO '<DB_USER>'@'localhost';

    -- Apply privilege changes
    FLUSH PRIVILEGES;
    ```
  - Include MariaDB vs MySQL 8+ authentication considerations (`caching_sha2_password` vs `mysql_native_password`).
  - Add verification command: `SHOW GRANTS FOR '<DB_USER>'@'localhost';`.

---

### 3. Unbound Local Python HTTP Server
- **Location**: `Linux/python3-server.md`
- **Current Content**:
  ```bash
  python3 -m http.server 7777
  ```
- **Risk**: Binds by default to `0.0.0.0`, exposing all files in the current working directory to the entire local area network and public internet if the port is reachable.
- **Proposed Phase 3 Fix**:
  - Update default command to bind strictly to localhost:
    ```bash
    python3 -m http.server 8000 --bind 127.0.0.1
    ```
  - Document the difference between `127.0.0.1` (local testing only) and `0.0.0.0` (network shared).
  - Add `⚠️ Warning` indicating that Python's built-in HTTP server is single-threaded, lacks authentication, and must never be used in production.

---

### 4. Non-Interactive Piped `fdisk` Deletion Script
- **Location**: `volume-swap/debian.md`
- **Current Content**:
  ```bash
  fdisk /dev/vda <<EOF
  d
  5
  d
  2
  w
  EOF
  ```
- **Risk**: If run on a system with a different partition table layout (e.g. partition 2 is root or swap is on partition 3), this script will permanently delete critical partitions and cause immediate unrecoverable data loss.
- **Proposed Phase 3 Fix**:
  - Add a high-visibility `⚠️ Warning` and danger disclaimer at the top of `volume-swap/debian.md`.
  - Provide safe, interactive verification steps (`lsblk`, `fdisk -l /dev/vda`) before performing partition changes.
  - Recommend modern tools (`growpart` / `parted`) that do not require destructive raw sector piping.

---

### 5. Hardcoded Personal Repository URL & Author Username
- **Location**: `gitHelp/git-help.md`
- **Current Content**:
  ```bash
  git remote add origin https://github.com/cybsam/linuxhelpertext.git
  ```
- **Risk**: Hardcoded external username `cybsam` and legacy repository name `linuxhelpertext`. Copy-pasting this command will cause unauthorized push failures or link to the wrong remote.
- **Proposed Phase 3 Fix**:
  - Replace with standard generic copy-paste placeholders:
    ```bash
    git remote add origin https://github.com/<USERNAME>/<REPOSITORY>.git
    ```
  - Provide an SSH alternative:
    ```bash
    git remote add origin git@github.com:<USERNAME>/<REPOSITORY>.git
    ```

---

### 6. Legal / Authorized-Use Framing for Incident Response & Tor Services
- **Location**: `incident-response/` and `tor-onion-service/`
- **Current Status**: Lacked explicit framing, which could lead to misunderstandings regarding intended use.
- **Proposed Phase 3 Fix**:
  - Emphasize strict defensive and authorized administration scope.
  - Provide complete, verified commands with explanation of flags and security considerations.

---

## 5. Next Steps
- Commit Phase 1 changes as: `"docs: restructure folders and naming (phase 1)"`.
- Proceed to **Phase 2: ROOT README.md** rewrite upon user confirmation (`next`).
