# Extending LVM Root and Swap Volumes on CentOS / RHEL 9

On CentOS Stream 9, RHEL 9, and Rocky Linux 9, default installations typically allocate disk storage into an LVM (Logical Volume Manager) Volume Group containing a root logical volume (`root` or `cs-root`) and a swap logical volume (`swap` or `cs-swap`).

This guide details how to expand the underlying physical disk partition, grow the Physical Volume (PV), extend the root Logical Volume (LV), and safely resize the swap Logical Volume.

---

> [!WARNING]
> ### Pre-Flight Safety Warnings
> 1. **Hypervisor Snapshot**: Always capture a VM snapshot or cloud volume backup before resizing partitions.
> 2. **Memory Headroom Before `swapoff`**: Disabling swap to resize it requires available physical RAM to absorb all active swapped pages. Check available RAM with `free -h` first; if memory is saturated, running `swapoff` can trigger the kernel Out-Of-Memory (OOM) killer.
> 3. **XFS Filesystem Growth Only**: The default root filesystem on RHEL/CentOS 9 is XFS, which **cannot be reduced in size**.

---

## Baseline Layout Inspection

Verify your current disk partitioning, volume groups, and filesystem types:

```bash
lsblk
sudo pvs
sudo vgs
sudo lvs
```

*Typical default CentOS 9 layout on a 100 GiB virtual disk*:
```text
vda 100G
├─vda1    1G  /boot (XFS)
└─vda2   29G  LVM2_member
   ├─cs-root 27G / (XFS)
   └─cs-swap  2G [SWAP]
```
In this scenario, after expanding the hypervisor disk from 30 GiB to 100 GiB, approximately 70 GiB of unallocated disk space follows `/dev/vda2`.

---

## Part 1: Expand Partition and Physical Volume (PV)

### 1. growpart (expand partition)
Extend partition 2 live to consume all remaining unallocated disk space on `/dev/vda`.
```bash
sudo growpart /dev/vda 2
```

#### Distro Package Requirement
If `growpart` is not found, install the RHEL package:
```bash
sudo dnf install -y cloud-utils-growpart
```

---

### 2. pvresize (update LVM physical volume)
Update LVM metadata to recognize the enlarged capacity of the underlying physical partition.
```bash
sudo pvresize /dev/vda2
```

#### Real-World Example
```bash
sudo pvresize /dev/vda2
# Verify unallocated space in Volume Group:
sudo vgs
```

---

## Part 2: Extend the Root Logical Volume (`cs-root`)

### lvextend (root volume)
Allocate free Volume Group extents to the root logical volume.
```bash
sudo lvextend -L +<SIZE>G /dev/<VG_NAME>/<ROOT_LV>
```

#### Flags
| Flag | Description |
|---|---|
| `-L +<SIZE>G` | Add specified gigabytes to the logical volume |
| `-l +100%FREE` | Allocate all remaining free extents in the Volume Group |
| `-r`, `--resizefs` | Automatically resize the underlying filesystem |

#### Real-World Example: Adding 64 GiB (Leaving 6 GiB for Swap)
```bash
# Check available free space in Volume Group
sudo vgdisplay cs | grep "Free  PE / Size"

# Extend root LV by 64 GiB, keeping remaining capacity for swap
sudo lvextend -L +64G /dev/cs/root
```

---

## Part 3: Resize the Root Filesystem

### xfs_growfs (grow XFS root filesystem)
Enlarge the XFS filesystem online using the root mount point (`/`).
```bash
sudo xfs_growfs /
```

#### Alternative: ext4 Filesystems
If the root filesystem was formatted with `ext4` rather than XFS:
```bash
sudo resize2fs /dev/cs/root
```

---

## Part 4: Safely Expand the Swap Logical Volume (`cs-swap`)

Unlike standard filesystems, swap logical volumes must be temporarily deactivated, resized, reformatted with `mkswap`, and re-enabled.

### Step 1: Deactivate Swap Space
Check that available physical RAM exceeds active swap consumption (`free -h`), then disable the swap logical volume:

```bash
sudo swapoff /dev/cs/swap
```

> [!WARNING]
> If available physical RAM is less than active swap usage, `swapoff` will freeze or trigger OOM process termination. Free up memory or stop non-essential services before disabling swap.

---

### Step 2: Extend the Swap Logical Volume
Allocate the remaining free space in the Volume Group (e.g. 6 GiB) to the swap LV:

```bash
sudo lvextend -L +6G /dev/cs/swap
# Or allocate all remaining space:
# sudo lvextend -l +100%FREE /dev/cs/swap
```

---

### Step 3: Reformat the Swap Volume

### mkswap
Re-initialize the swap signature and UUID on the enlarged logical volume.
```bash
sudo mkswap /dev/cs/swap
```

#### Real-World Example
```bash
sudo mkswap /dev/cs/swap
```

---

### Step 4: Re-Enable and Verify Swap

### swapon
Re-activate the enlarged swap volume live.
```bash
sudo swapon /dev/cs/swap
```

#### Verification
```bash
swapon --show
free -h
```
*Note*: Existing `/etc/fstab` entries remain unchanged because the device path `/dev/cs/swap` persists across resizing.
