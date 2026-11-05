# Volume & Swap Storage Management

This folder contains storage engineering guides, partition expansion procedures, LVM recipes, and swap space administration for Linux servers.

---

## Documents in This Folder

- [**`volume-resize-guide.md`**](volume-resize-guide.md): Comprehensive decision tree for online filesystem expansion: non-LVM ext4 (`growpart` + `resize2fs`), LVM volumes (`pvresize` + `lvextend`), and XFS filesystems (`xfs_growfs`).
- [**`centos-swap-partition.md`**](centos-swap-partition.md): Step-by-step walkthrough for provisioning a dedicated swap partition with `fdisk`, formatting with `mkswap`, enabling with `swapon`, and registering in `/etc/fstab`.
- [**`centos9-volume-swap-partition-extend.md`**](centos9-volume-swap-partition-extend.md): Extending LVM root logical volumes (`cs-root`) and expanding swap logical volumes (`cs-swap`) on CentOS / RHEL 9 systems.
- [**`swap-extends.md`**](swap-extends.md): Creating and activating additional swap files live (`fallocate`, `chmod 600`, `mkswap`, `swapon`) without service disruption.
- [**`volume-extends.md`**](volume-extends.md): Quick reference commands for expanding physical volumes and logical volumes using `cloud-guest-utils`, `growpart`, `pvresize`, and `lvextend`.
- [**`debian.md`**](debian.md): Debian storage migration script reference (⚠️ **Caution**: Contains destructive partition reorganization commands requiring manual verification).

---

## How to Use These Guides

1. **Pre-requisite Check**: Always inspect block devices and disk capacity before any resize operation:
   ```bash
   lsblk
   df -h
   ```
2. **Filesystem Awareness**:
   - For **ext4**: Use `resize2fs <device>`.
   - For **XFS**: Use `xfs_growfs <mountpoint>`. Remember that XFS filesystems **cannot be shrunk**.
3. **Safety First**: Take a VM hypervisor snapshot or cloud volume snapshot before performing partition table changes (`fdisk`, `parted`, or `growpart`).
