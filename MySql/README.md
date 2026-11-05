# MySQL & MariaDB Administration Helpers

This folder contains command references and best practices for managing relational databases using MySQL and MariaDB.

---

## Documents in This Folder

- [**`create-user-and-permission.md`**](create-user-and-permission.md): Secure user provisioning, authentication plugins, granting scoped permissions to specific databases, and privilege table reloading (`FLUSH PRIVILEGES`).

---

## How to Use These Guides

1. **Root Access**: Connect to your database server as the administrative user using `sudo mysql` (socket authentication on Debian/Ubuntu) or `mysql -u root -p`.
2. **Principle of Least Privilege**: Avoid granting global `ALL PRIVILEGES ON *.*` in production environments. Always scope permissions to the specific database required by the application.
3. **Password Security**: Replace all `<DB_USER>` and `<SECURE_PASSWORD>` placeholders with strong, randomly generated credentials.
