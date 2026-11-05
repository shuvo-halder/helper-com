# PHP Helpers & Server Administration

This folder contains command-line utilities and reference guides for PHP application deployment and security.

---

## Documents & Scripts in This Folder

- [**`make_hash.php`**](make_hash.php): Standalone interactive command-line utility for generating bcrypt / Argon2id password hashes using PHP's native `password_hash()` API.

---

## How to Use These Tools

1. **CLI Execution**: Run the password hashing utility directly from the terminal without exposing credentials in command history:
   ```bash
   php make_hash.php
   ```
2. **Security Practices**: Uses `PASSWORD_DEFAULT` (bcrypt), which automatically handles salt generation and produces standard cryptographically secure hashes compatible with modern web applications and framework authentication systems.
3. **Password Verification**: Always verify generated hashes in application logic using PHP's `password_verify($input_password, $stored_hash)` rather than raw string comparison.
