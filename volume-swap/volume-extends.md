# Quick Reference: Volume and LVM Extension Commands

This quick reference provides copy-paste-ready command sequences for expanding disk partitions, LVM Physical Volumes, Logical Volumes, and filesystems after resizing virtual disks.

---

## 1. Install Partition Tools

### Debian / Ubuntu
```bash
sudo apt update && sudo apt install -y cloud-guest-utils
```

### RHEL / Rocky / AlmaLinux
```bash
sudo dnf install -y cloud-utils-growpart
```

---

## 2. Partition & LVM Extension Sequence

### Step 1: growpart (expand partition)
Extend partition table boundaries to claim newly provisioned disk space.
```bash
sudo growpart <DISK_DEVICE> <PARTITION_NUMBER>
```

#### Real-World Example
```bash
# Expand partition 3 on /dev/vda
sudo growpart /dev/vda 3
```

---

### Step 2: pvresize (expand physical volume)
Notify LVM that the underlying block partition capacity has expanded.
```bash
sudo pvresize <PARTITION_DEVICE>
```

#### Real-World Example
```bash
sudo pvresize /dev/vda3
```

---

### Step 3: lvextend (expand logical volume)
Allocate available Volume Group free space to the target logical volume.
```bash
sudo lvextend -l +100%FREE /dev/<VG_NAME>/<LV_NAME>
```

#### Real-World Example
```bash
# Ubuntu default LVM layout
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
```

---

### Step 4: Enlarge the Filesystem

Choose the command matching your filesystem type:

### For ext4 Filesystems (`resize2fs`)
```bash
# For an LVM Logical Volume:
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv

# For a direct non-LVM partition:
sudo resize2fs /dev/vda3
```

### For XFS Filesystems (`xfs_growfs`)
```bash
# Target the active mount point (e.g. /)
sudo xfs_growfs /
```

---

## 3. Post-Expansion Verification

Confirm that both block devices and filesystem capacities reflect the expansion:

```bash
lsblk
df -h
```
