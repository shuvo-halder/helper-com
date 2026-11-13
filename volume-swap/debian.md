# Debian Disk Partition Migration and Swapfile Conversion Guide

On older Debian virtual machine images formatted with MBR partition tables, swap was frequently installed inside a logical partition (e.g. `/dev/vda5`) within an extended partition (`/dev/vda2`), positioned immediately after the primary root partition (`/dev/vda1`). Because the extended partition physically blocks the primary root partition from growing into contiguous unallocated space, expanding root requires removing the swap partition, growing root, and replacing swap with a swapfile.

---

> [!CAUTION]
> ### ⚠️ Critical Data Safety Warning
> Modifying partition boundaries and deleting partition table entries carries an extreme risk of **permanent data loss**.
> 1. **Capture a Snapshot**: Always take an offline hypervisor snapshot or cloud storage backup before running partition deletion commands.
> 2. **Inspect Actual Partition Numbers**: Disk layouts vary across Debian releases and virtualization providers. Never run piped partition deletions without verifying that your active swap partition number matches the target command.

---

## Recommended Safe Workflow (Step-by-Step)

### Step 1: Inspect Active Disk Layout
Identify existing partition numbers, mount points, and swap status:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
swapon --show
```

---

### Step 2: Disable Legacy Swap Partition Safely
Verify that available physical RAM is sufficient to absorb active swap pages (`free -h`), then deactivate the swap partition:

```bash
sudo swapoff /dev/vda5
```

---

### Step 3: Backup and Clean `/etc/fstab`
Create a backup of `/etc/fstab` and remove the legacy swap partition reference:

```bash
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i '/vda5/d' /etc/fstab
```

---

### Step 4: Delete Blocking Swap Partition (Interactive)
Open `fdisk` interactively to confirm partition numbers and delete the blocking partitions manually rather than using automated scripting:

```bash
sudo fdisk /dev/vda
# Inside fdisk:
# 1. 'p' -> Verify that partition 5 is swap and partition 2 is extended
# 2. 'd' -> Select partition 5 to delete logical swap
# 3. 'd' -> Select partition 2 to delete extended container
# 4. 'p' -> Confirm that only primary partition 1 (/dev/vda1) remains
# 5. 'w' -> Write changes to disk and exit
```

---

### Step 5: Expand the Root Partition with growpart

### growpart
Enlarge the primary root partition (`/dev/vda1`) into the contiguous unallocated disk space.
```bash
sudo apt update && sudo apt install -y cloud-guest-utils
sudo growpart /dev/vda 1
```

---

### Step 6: Enlarge the ext4 Filesystem Online

### resize2fs
Expand the live mounted ext4 filesystem on `/dev/vda1`.
```bash
sudo resize2fs /dev/vda1
```

---

### Step 7: Create and Enable a Modern Swapfile

Create a dedicated 2 GiB swapfile on the root filesystem:

```bash
# 1. Allocate file space
sudo fallocate -l 2G /swapfile

# 2. Restrict permissions (owner read/write only)
sudo chmod 600 /swapfile

# 3. Format as swap
sudo mkswap /swapfile

# 4. Activate swapfile
sudo swapon /swapfile

# 5. Register in /etc/fstab for boot persistence
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

### Step 8: Update Initramfs and GRUB
Inform the kernel initramfs and bootloader that swap has transitioned from a dedicated partition to a swapfile to prevent hibernation lookup stalls during boot:

```bash
echo "RESUME=none" | sudo tee /etc/initramfs-tools/conf.d/resume
sudo update-initramfs -u
sudo update-grub
```

---

## ⚠️ Legacy / Dangerous Scripted Sequence (Do Not Run Blindly)

The original script below from previous revisions is retained for historical reference only:

```bash
# 1. Disable existing swap and remove its entry from fstab
swapoff /dev/vda5
sed -i.bak '/vda5/d' /etc/fstab

# ⚠️ HIGH RISK: Deletes partitions non-interactively via piped heredoc
# Will destroy data if partition numbers 5 and 2 do not match the expected layout!
fdisk /dev/vda <<EOF
d
5
d
2
w
EOF

# 3. Ensure growpart is installed, then grow the root partition (vda1)
apt update && apt install -y cloud-guest-utils
growpart /dev/vda 1

# 4. Resize the ext4 filesystem to use the new space live
resize2fs /dev/vda1

# 5. Create, secure, and enable a new 1GB swap file
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# 6. Add the new swap file to fstab to persist across reboots
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# 7. Update GRUB and initramfs to register the new filesystem layout
update-grub
echo "RESUME=none" > /etc/initramfs-tools/conf.d/resume
update-initramfs -u
```

> [!CAUTION]
> **Do not copy and paste the heredoc `fdisk` script above.** Use the step-by-step interactive workflow in the first section of this guide.
