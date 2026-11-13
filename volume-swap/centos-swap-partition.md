# Dedicated Swap Partition Creation Guide

This guide details how to allocate, format, enable, and persistently configure a dedicated Linux swap partition on CentOS, RHEL, Rocky Linux, or Debian systems.

---

> [!WARNING]
> ### Pre-Flight Warnings
> 1. **Partition Table Modification**: Running `fdisk` or partition editors directly modifies disk sector maps. Always back up data or take a VM snapshot before editing partition tables.
> 2. **Double-Check Partition Number**: Ensure the chosen partition number and sector ranges do not overlap with existing root or boot partitions.
> 3. **Persistent Mount Identification**: Prefer using `UUID` rather than direct device paths (e.g. `/dev/vda3`) in `/etc/fstab` to avoid mounting errors if disk enumeration shifts.

---

## Step-by-Step Swap Partition Provisioning

### 1. Allocate Partition with fdisk

Create a new partition designated as Linux swap space on the target disk device.

### fdisk
Open interactive partition editor to create and tag a swap partition.
```bash
sudo fdisk <DISK_DEVICE>
```

#### Real-World Example
```bash
sudo fdisk /dev/vda

# Inside the interactive fdisk session:
# 1. 'p'   -> Print current partitions to identify next available partition number
# 2. 'n'   -> Add a new partition
# 3. 'p'   -> Primary partition (or accept default for GPT)
# 4. '3'   -> Set partition number (e.g. 3 if /dev/vda3 is available)
# 5. Enter -> Accept default first sector for optimal alignment
# 6. '+8G' -> Allocate desired capacity (+8G for an 8 GiB swap)
# 7. 't'   -> Change partition type:
#             - For MBR tables: enter hex code '82' (Linux swap)
#             - For GPT tables: enter type code '19' (Linux swap)
# 8. 'w'   -> Write changes to disk and exit
```

---

### 2. Format the Swap Partition

### mkswap
Initialize and format the partition with a Linux swap area signature and UUID.
```bash
sudo mkswap <PARTITION_DEVICE>
```

#### Flags
| Flag | Description |
|---|---|
| `-L <LABEL>` | Assign a human-readable volume label |
| `-U <UUID>` | Specify a custom UUID (optional) |

#### Real-World Example
```bash
sudo mkswap -L "swap_partition" /dev/vda3
```

> [!WARNING]
> Running `mkswap` permanently wipes all existing data and filesystem headers on `/dev/vda3`. Verify the device name with `lsblk` before executing.

---

### 3. Activate the Swap Space

### swapon
Enable the formatted swap partition live without rebooting.
```bash
sudo swapon <PARTITION_DEVICE>
```

#### Real-World Example
```bash
sudo swapon /dev/vda3
```

#### Verify Activation
```bash
swapon --show
free -h
```

---

### 4. Configure Persistent Mounting (`/etc/fstab`)

To ensure the swap space activates automatically across system reboots, register it in `/etc/fstab`.

1. Query the partition's UUID:
   ```bash
   sudo blkid /dev/vda3
   # Example output: /dev/vda3: UUID="1a2b3c4d-5e6f-7a8b-9c0d-e1f2a3b4c5d6" TYPE="swap"
   ```

2. Append the persistent entry to `/etc/fstab`:
   ```text
   # <file system UUID>                           <mount point>  <type>  <options>  <dump>  <pass>
   UUID=1a2b3c4d-5e6f-7a8b-9c0d-e1f2a3b4c5d6 none           swap    sw         0       0
   ```

---

### 5. Swappiness Tuning (Optional)

Adjust the kernel parameter `vm.swappiness` (from 0 to 100) to control how aggressively pages are swapped from RAM into the swap area.

```bash
# Check current swappiness (default is typically 60)
cat /proc/sys/vm/swappiness

# Set temporary swappiness to 10 (recommended for database and web workloads)
sudo sysctl vm.swappiness=10

# Persist across reboots in /etc/sysctl.d/99-swappiness.conf
echo "vm.swappiness = 10" | sudo tee /etc/sysctl.d/99-swappiness.conf
```
