# Volume & Swap Storage Management

This folder contains storage engineering guides, partition expansion procedures, LVM recipes, and swap space administration for Linux servers.

---

## Documents in This Folder

- [**`volume-resize-guide.md`**](volume-resize-guide.md): Comprehensive decision tree for online filesystem expansion: non-LVM ext4 (`growpart` + `resize2fs`), non-LVM XFS (`xfs_growfs`), and LVM volumes (`pvresize` + `lvextend`).
- [**`centos-swap-partition.md`**](centos-swap-partition.md): Step-by-step walkthrough for provisioning a dedicated swap partition with `fdisk`, formatting with `mkswap`, enabling with `swapon`, persistent `/etc/fstab` UUID configuration, and swappiness tuning.
- [**`centos9-volume-swap-partition-extend.md`**](centos9-volume-swap-partition-extend.md): Complete procedure for extending LVM root logical volumes (`cs-root`) and expanding swap logical volumes (`cs-swap`) on CentOS Stream / RHEL 9 systems.
- [**`swap-extends.md`**](swap-extends.md): Creating and activating auxiliary swap files live (`fallocate` or `dd`, `chmod 600`, `mkswap`, `swapon`) with zero downtime and safe decommissioning steps.
- [**`volume-extends.md`**](volume-extends.md): Quick-reference command sheet for expanding physical partitions, LVM physical volumes, and logical volumes across Debian/Ubuntu and RHEL/Rocky.
- [**`debian.md`**](debian.md): Safe interactive migration workflow for converting legacy MBR extended swap partitions into modern swapfiles, with the legacy scripted heredoc preserved under a marked danger section.

---

## How to Use These Guides

1. **Pre-Flight Inspection**: Always inspect block devices and disk capacity before attempting any resize operation:
   ```bash
   lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
   df -h
   ```
2. **Filesystem Awareness**:
   - For **ext4**: Grow using `resize2fs <device>`.
   - For **XFS**: Grow using `xfs_growfs <mountpoint>`. Remember that XFS filesystems **cannot be shrunk**.
3. **Safety First**: Take a VM hypervisor snapshot or cloud volume snapshot before performing partition table changes (`fdisk`, `parted`, or `growpart`). Check memory headroom with `free -h` before deactivating swap (`swapoff`).
