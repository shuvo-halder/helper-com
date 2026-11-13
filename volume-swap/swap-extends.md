# Adding and Extending Swap Files Guide

This guide details how to create, activate, and persistently register additional swap files on a running Linux server without unmounting disks or disrupting active workloads.

---

> [!NOTE]
> Creating an auxiliary swapfile (e.g. `/swapfile2`) allows you to expand virtual memory capacity live while the system continues using the primary swap space.

---

## 1. Creating and Activating an Additional Swap File

### Step 1: Allocate File Space

### fallocate (preferred method)
Preallocate a dedicated non-sparse block for the swap file instantly.
```bash
sudo fallocate -l <SIZE>G /swapfile2
```

#### Real-World Example
```bash
# Allocate a 2 GiB swap file
sudo fallocate -l 2G /swapfile2
```

#### Fallback: Using `dd`
On certain filesystems (such as Btrfs or specific XFS configurations), `fallocate` may create sparse files that `swapon` rejects with `swapon failed: Invalid argument`. In those environments, use `dd`:
```bash
sudo dd if=/dev/zero of=/swapfile2 bs=1M count=2048 status=progress
```

---

### Step 2: Restrict File Permissions

### chmod 600
Set strict file permissions so only the `root` user can read or write the swap file.
```bash
sudo chmod 600 /swapfile2
```

> [!WARNING]
> Swap files contain raw physical memory pages, which can include unencrypted user passwords, SSL private keys, and application tokens. Leaving a swap file readable by others (`chmod 644` or `777`) creates an immediate critical security vulnerability. Always set `chmod 600`.

---

### Step 3: Format the Swap File

### mkswap
Format the allocated file as a Linux swap area.
```bash
sudo mkswap /swapfile2
```

#### Real-World Example
```bash
sudo mkswap /swapfile2
```

---

### Step 4: Activate the New Swap File

### swapon
Activate the new swap file live.
```bash
sudo swapon /swapfile2
```

#### Verify Active Swap Capacity
```bash
swapon --show
free -h
```

---

## 2. Registering in `/etc/fstab` for Boot Persistence

To ensure the swap file mounts automatically on subsequent system reboots, add an entry to `/etc/fstab`:

```text
# Single primary swapfile:
/swapfile   none   swap   sw   0 0

# Dual / auxiliary swapfile configuration:
/swapfile   none   swap   sw   0 0
/swapfile2  none   swap   sw   0 0
```

Validate `/etc/fstab` syntax:
```bash
sudo mount -a
```

---

## 3. Safely Removing a Swap File

If you later need to reclaim disk space or decommission an auxiliary swap file:

1. Check that available physical RAM is sufficient to absorb active swap pages:
   ```bash
   free -h
   ```
2. Deactivate the specific swap file:
   ```bash
   sudo swapoff /swapfile2
   ```
3. Remove its entry from `/etc/fstab`:
   ```bash
   sudo sed -i '/swapfile2/d' /etc/fstab
   ```
4. Delete the file from the filesystem:
   ```bash
   sudo rm -f /swapfile2
   ```
