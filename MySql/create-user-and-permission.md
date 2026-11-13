# MySQL & MariaDB User and Privilege Management Guide

This guide details secure user provisioning, database creation, scoped privilege grants, authentication plugin management, and backup/restore workflows for MySQL and MariaDB on Linux.

---

> [!WARNING]
> ### Principle of Least Privilege
> Never grant global `ALL PRIVILEGES ON *.* WITH GRANT OPTION` to an application service account in production. A compromised application user with global privileges can drop other databases, read sensitive system tables, and create additional superusers.
>
> Always restrict privileges to the specific database schema required by the application (`<DB_NAME>.*`), and restrict the host identifier to `'localhost'` (or the specific application server IP address, never `'%'` unless external access is strictly required).

---

## 1. Connecting to the Database Server

### sudo mysql (socket authentication)
Connect directly to the database daemon as administrative root using the local UNIX socket (standard default on Debian/Ubuntu).
```bash
sudo mysql
```

#### Real-World Example
```bash
# Connect using socket authentication (no password required for root via sudo)
sudo mysql
```

---

### mysql -u (password authentication)
Connect to the database server using username and password credentials (standard on RHEL/Rocky or remote clients).
```bash
mysql -u <DB_USER> -p -h <HOST>
```

#### Useful Flags
| Flag | Description |
|---|---|
| `-u <USER>` | Specify the database username |
| `-p` | Prompt securely for database password in terminal |
| `-h <HOST>` | Hostname or IP of database server (default: `localhost`) |
| `-P <PORT>` | Custom TCP port (default: `3306`) |

#### Real-World Example
```bash
# Connect locally as root and prompt for password
mysql -u root -p
```

---

## 2. Database Creation & UTF-8 Encoding

### CREATE DATABASE
Create a new dedicated database with modern multi-byte UTF-8 encoding support for international characters, symbols, and emoji.
```sql
CREATE DATABASE <DB_NAME> CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### Clause Breakdown
| Clause | Description |
|---|---|
| `CHARACTER SET utf8mb4` | Modern 4-byte UTF-8 encoding (supports full Unicode range and emojis) |
| `COLLATE utf8mb4_unicode_ci` | Case-insensitive Unicode collation rules for accurate sorting |

#### Real-World Example
```sql
CREATE DATABASE <DB_NAME> CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

## 3. Creating Database Users

### CREATE USER
Create a new user account bound to a specific host address and assign a strong password.
```sql
CREATE USER '<DB_USER>'@'<HOST>' IDENTIFIED BY '<DB_PASSWORD>';
```

#### Host Scoping
| Host Value | Description |
|---|---|
| `'localhost'` | Allows connections only via local UNIX domain socket or loopback (`127.0.0.1`) |
| `'192.0.2.50'` | Allows connections only from a specific remote application server IP |
| `'%'` | Wildcard: allows connections from any remote host (⚠️ Avoid in production unless firewalled) |

#### Real-World Example
```sql
-- Create local application user
CREATE USER '<DB_USER>'@'localhost' IDENTIFIED BY '<DB_PASSWORD>';
```

### Authentication Plugins (MySQL 8+ vs MariaDB)
Modern database engines support pluggable authentication:
```sql
-- MySQL 8+ standard default (SHA-256 password hashing)
CREATE USER '<DB_USER>'@'localhost' IDENTIFIED WITH caching_sha2_password BY '<DB_PASSWORD>';

-- MySQL legacy compatibility (for older application drivers)
CREATE USER '<DB_USER>'@'localhost' IDENTIFIED WITH mysql_native_password BY '<DB_PASSWORD>';
```

---

## 4. Granting Scoped Privileges

### GRANT (database-level scoped access)
Grant full permissions strictly to a specific database rather than the entire database server.
```sql
GRANT ALL PRIVILEGES ON <DB_NAME>.* TO '<DB_USER>'@'<HOST>';
```

#### Real-World Example: Scoped Application User
```sql
-- Grant full access only to the application database
GRANT ALL PRIVILEGES ON <DB_NAME>.* TO '<DB_USER>'@'localhost';
```

---

### GRANT (least-privilege DML access)
Grant only necessary data manipulation privileges (read/write without schema alteration rights) for hardened production environments.
```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON <DB_NAME>.* TO '<DB_USER>'@'localhost';
```

#### Real-World Example
```sql
-- Restrict user to data queries without DROP or ALTER permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON <DB_NAME>.* TO '<DB_USER>'@'localhost';
```

---

### FLUSH PRIVILEGES
Reload the grant tables from the database disk to activate permission changes.
```sql
FLUSH PRIVILEGES;
```

> [!NOTE]
> `FLUSH PRIVILEGES` is strictly necessary when modifying user tables directly using `INSERT` or `UPDATE` on the `mysql.user` table. When using modern DDL statements (`CREATE USER`, `GRANT`, `REVOKE`), the database engine updates memory grant tables automatically, but executing `FLUSH PRIVILEGES` remains common practice.

---

## 5. Auditing, Revoking & Deleting Users

### SHOW GRANTS
Display the active permission privileges assigned to a database user.
```sql
SHOW GRANTS FOR '<DB_USER>'@'<HOST>';
```

#### Real-World Example
```sql
SHOW GRANTS FOR '<DB_USER>'@'localhost';
```

---

### REVOKE
Remove specific privileges from an existing user account.
```sql
REVOKE ALL PRIVILEGES, GRANT OPTION FROM '<DB_USER>'@'<HOST>';
```

#### Real-World Example
```sql
REVOKE ALL PRIVILEGES ON <DB_NAME>.* FROM '<DB_USER>'@'localhost';
```

---

### DROP USER
Completely remove a database user account.
```sql
DROP USER '<DB_USER>'@'<HOST>';
```

#### Real-World Example
```sql
DROP USER '<DB_USER>'@'localhost';
```

---

## 6. Backup & Restore (mysqldump / mariadb-dump)

### mysqldump (database backup)
Export a complete database schema and dataset to a compressed SQL dump file.
```bash
mysqldump -u <DB_USER> -p <DB_NAME> > backup_<DB_NAME>.sql
```

#### Useful Flags
| Flag | Description |
|---|---|
| `--single-transaction` | Create consistent backup without locking InnoDB tables |
| `--quick` | Stream rows directly from server without caching large tables in RAM |
| `--routines --triggers` | Include stored procedures, functions, and triggers in dump |

#### Real-World Example
```bash
# Perform a consistent, compressed backup of application database
mysqldump -u root -p --single-transaction --quick <DB_NAME> | gzip > backup_<DB_NAME>.sql.gz
```

---

### mysql (restore from dump)
Restore a database from an uncompressed or compressed SQL dump file.
```bash
mysql -u <DB_USER> -p <DB_NAME> < backup_<DB_NAME>.sql
```

#### Real-World Example
```bash
# Decompress and restore database
gunzip < backup_<DB_NAME>.sql.gz | mysql -u root -p <DB_NAME>
```

---

## 7. Distribution Differences & Initial Hardening

| Feature | Debian / Ubuntu | RHEL / Rocky / AlmaLinux |
|---|---|---|
| **Default Package** | `mysql-server` or `mariadb-server` | `mariadb-server` |
| **Systemd Service Name** | `mysql.service` or `mariadb.service` | `mariadb.service` |
| **Root Authentication** | `auth_socket` (login via `sudo mysql`) | Password-based |
| **Hardening Script** | `sudo mysql_secure_installation` | `sudo mariadb-secure-installation` |

### Initial Security Lockdown
Run the interactive security script immediately after installation to remove anonymous users, disallow remote root login, and remove test databases:
```bash
sudo mysql_secure_installation
```

---

## ⚠️ Legacy / Do Not Use (Historical Reference)

The original commands from previous revisions are preserved below for reference:

```sql
-- ⚠️ INSECURE: Uses weak hardcoded password 'password'
CREATE USER 'sammy'@'localhost' IDENTIFIED BY 'password';

-- ⚠️ SYNTAX ERROR: Malformed comment and query syntax
using specific database//GRANT PRIVILEGE ON database.table TO 'username'@'host';

-- ⚠️ DANGEROUS: Grants unconstrained global superuser access across all databases
GRANT ALL PRIVILEGES ON *.* TO 'sammy'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

> [!CAUTION]
> **Do not use the legacy snippet above.** Always use `<DB_USER>`, `<DB_PASSWORD>`, and `<DB_NAME>` placeholders, and scope permissions to `<DB_NAME>.*` rather than `*.*`.
