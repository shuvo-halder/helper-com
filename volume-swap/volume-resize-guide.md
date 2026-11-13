# Linux Live Volume and Filesystem Resize Guide

When virtual disk capacity is increased in a hypervisor (e.g. Proxmox, VMware, KVM) or cloud provider (AWS EBS, GCP Persistent Disk, DigitalOcean Volumes), the underlying operating system partition and filesystem must be expanded to consume the new storage space.

---

> [!WARNING]
> ### Safety Pre-requisites
> 1. **Take a Volume Snapshot**: Always take a hypervisor-level snapshot or cloud disk snapshot before performing partition resizing.
> 2. **XFS Filesystems Cannot Be Shrunk**: While both `ext4` and `XFS` support online growth, **XFS cannot be reduced in size**. Only expand XFS to the exact capacity you intend to use permanently.
> 3. **Verify Device Names**: Confirm disk names (`/dev/vda` vs `/dev/sda` vs `/dev/nvme0n1`) with `lsblk` before executing resize commands.

---

## Pre-Flight Inspection

Identify your disk partitioning layout, filesystem type, and whether LVM is in use:

### lsblk & df -hT
Check block device hierarchy, partition numbers, mount points, and filesystem types.
```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
df -hT
```

#### Real-World Example
```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
# Check if the partition is mounted directly (e.g. vda2 -> /)
# or if it hosts an LVM Physical Volume (e.g. vda2 -> vg0-root -> /)
```

---

## Scenario A: Standard Partition with ext4 (Non-LVM)

Use this scenario if your root or data partition is formatted with `ext4` directly on a partition without LVM.

### growpart
Extend a partition table entry live to fill the remaining unallocated disk space on the drive.
```bash
sudo growpart <DISK_DEVICE> <PARTITION_NUMBER>
```

#### Flags
| Flag / Argument | Description |
|---|---|
| `<DISK_DEVICE>` | Raw block device path (e.g. `/dev/vda`, `/dev/sda`, without partition digit) |
| `<PARTITION_NUMBER>` | Partition number to expand (e.g. `1` or `2`) |
| `-N`, `--dry-run` | Print what would be done without making changes |

#### Real-World Example
```bash
# Expand partition 2 on /dev/vda
sudo growpart /dev/vda 2
```

> [!NOTE]
> If `growpart` is not installed:
> - **Debian / Ubuntu**: `sudo apt install -y cloud-guest-utils`
> - **RHEL / Rocky Linux**: `sudo dnf install -y cloud-utils-growpart`

---

### resize2fs
Enlarge the `ext4` filesystem online while mounted.
```bash
sudo resize2fs <PARTITION_DEVICE>
```

#### Real-World Example
```bash
# Enlarge ext4 filesystem inside /dev/vda2 live
sudo resize2fs /dev/vda2
```

---

## Scenario B: Standard Partition with XFS (Non-LVM)

Default installations of RHEL, Rocky, AlmaLinux, and CentOS use the `XFS` filesystem. `resize2fs` will fail on XFS.

### xfs_growfs
Expand an XFS filesystem online using its active mount point.
```bash
sudo xfs_growfs <MOUNT_POINT>
```

#### Flags
| Flag | Description |
|---|---|
| `<MOUNT_POINT>` | Active mount directory of the filesystem (e.g. `/` or `/data`) |
| `-d` | Expand data section to maximum available space |

#### Real-World Example
```bash
# 1. Expand the underlying partition
sudo growpart /dev/vda 2

# 2. Expand XFS filesystem targeting the mount point
sudo xfs_growfs /
```

---

## Scenario C: LVM Volumes with ext4 or XFS

If `lsblk` displays an LVM logical volume (e.g. `vda2` $\to$ `vg0-root`), expanding storage requires a 4-step workflow:

### Step 1: Grow the Underlying Physical Partition
```bash
sudo growpart /dev/vda 2
```

### Step 2: Resize the LVM Physical Volume (PV)
Update LVM's awareness of the newly enlarged physical partition:
```bash
sudo pvresize /dev/vda2
```

### Step 3: Extend the Logical Volume (LV)
Allocate the newly available free space in the Volume Group to the Logical Volume:

### lvextend
Extend an LVM logical volume using percentage or absolute capacity increments.
```bash
sudo lvextend -l +100%FREE /dev/mapper/<VG_NAME>-<LV_NAME>
```

#### Flags
| Flag | Description |
|---|---|
| `-l +100%FREE` | Allocate all remaining unallocated extents in the Volume Group |
| `-L +<SIZE>` | Allocate a specific size increment (e.g. `-L +10G`) |
| `-r`, `--resizefs` | Resize the underlying filesystem automatically in the same command |

#### Real-World Example
```bash
sudo lvextend -l +100%FREE /dev/mapper/vg0-root
```

### Step 4: Grow the Filesystem
Depending on the filesystem type on the logical volume:

```bash
# For ext4:
sudo resize2fs /dev/mapper/vg0-root

# For XFS:
sudo xfs_growfs /
```

---

## Verification

After completing the resize operation, verify that the filesystem reflects the expanded storage capacity:

```bash
# Confirm block device sizing
lsblk

# Confirm usable filesystem space
df -h
```
