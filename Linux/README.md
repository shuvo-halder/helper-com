# Linux System Administration Helpers

This folder contains command guides and practical snippets for core Linux administration tasks.

---

## Documents in This Folder

- [**`partition.md`**](partition.md): Linux partition scheme fundamentals, mount point roles (`/`, `/swap`, `/home`), and sector alignment.
- [**`python3-server.md`**](python3-server.md): Quick one-line local HTTP server using Python 3, including localhost binding and network security considerations.
- [**`ubuntu-firmware.md`**](ubuntu-firmware.md): Kernel boot parameters in GRUB (`/etc/default/grub`), log levels, and applying changes with `update-grub`.
- [**`var-www-html.md`**](var-www-html.md): Production web directory ownership (`www-data:www-data`), least-privilege permission models (755/644), and why `chmod 777` should never be used.

---

## How to Use These Guides

1. **Verify Before Running**: Commands requiring elevated privileges should be run using `sudo`. Check existing permissions (`ls -la`) and disk layouts (`lsblk`) first.
2. **Copy-Paste Safety**: Command snippets use standard POSIX / Bash syntax. Always replace placeholder variables (e.g., `<port>`, `<project_name>`) with your environment's actual values.
3. **Distribution Support**: Tested primarily on Debian/Ubuntu and adaptable for RHEL/Rocky Linux.
