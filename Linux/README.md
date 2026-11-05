# Linux System Administration Helpers

This folder contains practical command guides and hardened workflow recipes for core Linux system administration tasks.

---

## Documents in This Folder

- [**`partition.md`**](partition.md): End-to-end disk partitioning, filesystem formatting (`mkfs.ext4` / `mkfs.xfs`), mount hierarchy, and persistent `/etc/fstab` configuration.
- [**`python3-server.md`**](python3-server.md): Local development HTTP server via Python 3 with strict localhost binding (`--bind 127.0.0.1`), custom directories, and shutdown steps.
- [**`ubuntu-firmware.md`**](ubuntu-firmware.md): System and device firmware updates using `fwupdmgr` and `apt`, plus kernel boot parameter customization in `/etc/default/grub`.
- [**`var-www-html.md`**](var-www-html.md): Production web directory ownership (`chown -R www-data:www-data`), least-privilege permission models (755/644/775), and why `chmod 777` is dangerous.

---

## How to Use These Guides

1. **Verify Before Running**: Commands requiring elevated privileges should be run using `sudo`. Check existing permissions (`ls -la`) and disk layouts (`lsblk -f`) first.
2. **Copy-Paste Safety**: Command snippets use standard POSIX / Bash syntax. Always replace placeholder variables (e.g., `<WEB_ROOT>`, `<APP_NAME>`, `<PORT>`, `<DEVICE>`) with your environment's actual values.
3. **Distribution Support**: Tested on modern Debian/Ubuntu systems with distribution-specific equivalents provided for RHEL / Rocky Linux.
