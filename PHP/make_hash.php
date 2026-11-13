<?php
/**
 * Standalone CLI Password Hashing Utility
 *
 * Generates cryptographically secure password hashes using PHP's native password_hash() API.
 * Default algorithm: PASSWORD_DEFAULT (bcrypt with automatic salt generation).
 *
 * Usage (CLI only):
 *   php make_hash.php
 */

// Ensure script is executed strictly from the command line (CLI)
if (php_sapi_name() !== 'cli') {
    fwrite(STDERR, "Error: This utility can only be executed from the command line.\n");
    exit(1);
}

// Prompt user securely for plaintext password
$hashtext = readline("Enter your plain password: ");

// Validate non-empty input
if (empty($hashtext) || trim($hashtext) === '') {
    fwrite(STDERR, "Error: Password cannot be empty.\n");
    exit(1);
}

// Generate hash using PASSWORD_DEFAULT (standard bcrypt with automatic cost and salt)
$hashfile = password_hash($hashtext, PASSWORD_DEFAULT);

// Output generated hash
echo "your hash: " . $hashfile . "\n";

// Clear plain password variable from memory immediately
unset($hashtext);
