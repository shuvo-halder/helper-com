# MySQL & MariaDB Administration Helpers

This folder contains command references, security best practices, and operational recipes for managing relational databases using MySQL and MariaDB on Linux servers.

---

## Documents in This Folder

- [**`create-user-and-permission.md`**](create-user-and-permission.md): Secure user provisioning, scoped database permissions, authentication plugins, privilege auditing (`SHOW GRANTS`), `mysqldump` backup/restore recipes, and initial security hardening (`mysql_secure_installation`).

---

## How to Use These Guides

1. **Root Access**: Connect to your database server as the administrative user using `sudo mysql` (UNIX domain socket authentication on Debian/Ubuntu) or `mysql -u root -p` (password authentication on RHEL/Rocky).
2. **Principle of Least Privilege**: Avoid granting global `ALL PRIVILEGES ON *.*` in production environments. Always scope permissions to the specific database schema (`<DB_NAME>.*`) required by the application.
3. **Password Security**: Use only `<DB_USER>`, `<DB_PASSWORD>`, and `<DB_NAME>` placeholders. Never write, store, or commit real-looking passwords to version control.
