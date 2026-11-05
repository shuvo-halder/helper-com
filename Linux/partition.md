# Linux Partitioning and Filesystem Setup Workflow

This document provides a complete, production-grade guide to partitioning disks, creating filesystems, mounting storage volumes, and configuring persistent mounts in `/etc/fstab`.

---

> [!WARNING]
> ### Pre-Flight Safety Warnings
> 1. **Back Up First**: Modifying partition tables or formatting devices permanently destroys data.
> 2. **Double-Check Block Device Names**: Drive identifiers (e.g., `/dev/sda`, `/dev/sdb`, `/dev/nvme0n1`, `/dev/vda`) can change based on bus discovery, hypervisor assignments, or reboot order. Always confirm the drive using `lsblk -f`.
> 3. **Never Format Active Filesystems**: Verify that the partition is unmounted (`umount`) and not in use before running formatting or partitioning utilities.

---

## Standard Partition Hierarchy Roles

When planning a disk layout, different partitions serve distinct roles:
- **Root Partition (`/`)**: Contains the operating system, core binaries, libraries, and system configurations. It must be accessible at boot time.
- **Swap Partition (`swap`)**: Dedicated swap space acting as virtual memory when RAM capacity is constrained.
- **Home Partition (`/home`)**: Houses user data and personal files. Separating `/home` prevents runaway user files or logs from filling the root partition and crashing system daemons.
- **Data / Application Partitions (`/data` or `/var`)**: Dedicated high-capacity volumes for databases, containers, or web applications.

---

## Complete Partition & Mount Workflow

### 1. lsblk (verify disk devices)
Display block devices, existing partition structures, capacities, and mount points before making changes.
```bash
lsblk -p -f
```

#### Flags
| Flag | Description |
|---|---|
| `-p`, `--paths` | Print complete device paths (e.g. `/dev/sdb`) |
| `-f`, `--fs` | Display filesystem types, labels, and UUIDs |

#### Real-World Example
```bash
lsblk -p -f
# Verify /dev/sdb is the newly attached, unpartitioned 100G disk
```

---

### 2. fdisk (create partition)
Create a new partition table and allocate partitions on the target block device.
```bash
sudo fdisk <DEVICE>
```

#### Flags
| Flag / Argument | Description |
|---|---|
| `<DEVICE>` | Target raw block device (e.g. `/dev/sdb`, `/dev/vdb`) |
| `-l` | List partition tables on specified devices without editing |

#### Interactive Real-World Example
```bash
sudo fdisk /dev/sdb

# Inside fdisk:
# 1. 'p'  -> Print current partition table to confirm the drive
# 2. 'g'  -> Create a modern GPT partition table (or 'o' for legacy MBR)
# 3. 'n'  -> Add a new partition (accept default partition number & first sector)
# 4. '+50G' -> Allocate 50 GiB to the partition
# 5. 't'  -> Set partition type (default is Linux filesystem)
# 6. 'w'  -> Write changes to disk and exit
```

> [!WARNING]
> Writing changes with `w` in `fdisk` immediately modifies the partition table on disk. Ensure you selected the correct drive before pressing `w`.

---

### 3. mkfs (format filesystem)
Format the newly created partition with a reliable filesystem (`ext4` on Debian/Ubuntu or `xfs` on RHEL/Rocky).
```bash
sudo mkfs.<FSTYPE> <PARTITION_DEVICE>
```

#### Flags
| Flag | Description |
|---|---|
| `-L <LABEL>` | Set a human-readable filesystem volume label |
| `-F` | Force formatting (use with caution) |

#### Real-World Example
```bash
# Format with ext4 (standard default for Debian / Ubuntu)
sudo mkfs.ext4 -L "data_vol" /dev/sdb1

# Format with XFS (standard default for RHEL / Rocky Linux)
sudo mkfs.xfs -L "data_vol" /dev/sdb1
```

> [!WARNING]
> Formatting writes new filesystem metadata, permanently wiping any existing data on `/dev/sdb1`.

---

### 4. mount (mount filesystem)
Create a mount directory and mount the formatted partition.
```bash
sudo mkdir -p <MOUNT_POINT>
sudo mount <PARTITION_DEVICE> <MOUNT_POINT>
```

#### Real-World Example
```bash
sudo mkdir -p /mnt/data
sudo mount /dev/sdb1 /mnt/data

# Verify mount was successful
df -h /mnt/data
```

---

### 5. blkid (obtain UUID for persistent mount)
Query the block device's permanent UUID to define reliable mounts that survive drive letter reordering.
```bash
sudo blkid <PARTITION_DEVICE>
```

#### Real-World Example
```bash
sudo blkid /dev/sdb1
# Output: /dev/sdb1: UUID="4f8a12bc-3d4e-5a6b-7c8d-9e0f1a2b3c4d" BLOCK_SIZE="4096" TYPE="ext4"
```

Edit `/etc/fstab` and append a persistent entry:
```text
# <file system UUID>                           <mount point>  <type>  <options>       <dump>  <pass>
UUID=4f8a12bc-3d4e-5a6b-7c8d-9e0f1a2b3c4d /mnt/data      ext4    defaults,noatime 0       2
```

---

### 6. mount -a (validate /etc/fstab)
Test and validate all entries in `/etc/fstab` without rebooting the system.
```bash
sudo mount -a
```

#### Flags
| Flag | Description |
|---|---|
| `-a`, `--all` | Mount all filesystems declared in /etc/fstab |
| `-v`, `--verbose` | Print detailed status of each evaluated mount |

> [!WARNING]
> **Always run `sudo mount -a` after editing `/etc/fstab`.** If there is a typo in UUID or options, `mount -a` will report it immediately. If left untested, a corrupted `/etc/fstab` can cause the operating system to fail to boot and drop into emergency maintenance mode.

---

## Distribution Differences

| Feature | Debian / Ubuntu | RHEL / Rocky / AlmaLinux |
|---|---|---|
| **Default Filesystem** | `ext4` (`mkfs.ext4`) | `XFS` (`mkfs.xfs`) |
| **Shrinking Filesystem** | Supported offline on `ext4` (`resize2fs`) | **Not supported** on XFS (XFS can only be grown) |
| **Volume Expansion Tool**| `cloud-guest-utils` (`growpart`) | `cloud-utils-growpart` (`growpart`) |
| **Filesystem Grow Tool** | `resize2fs` (ext4) | `xfs_growfs` (XFS) |
