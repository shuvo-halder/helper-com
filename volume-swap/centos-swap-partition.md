Sure! Here's the same instruction translated into English:

---

## **1️⃣ Create a Swap Partition**

If you want to use a separate partition for swap (let's say 8GB):

---

### **Step 1: Create the Partition**

```bash
sudo fdisk /dev/vda
```

Inside `fdisk`:

* `n` → create a new partition
* `p` → primary partition
* Partition number → 3 (if `/dev/vda3` is free)
* First sector → press Enter to accept default
* Last sector → `+8G` (for an 8GB swap)
* Change partition type to swap: `t` → `82` (Linux swap)
* Write changes: `w`

---

### **Step 2: Format the Swap Partition**

```bash
sudo mkswap /dev/vda3
```

---

### **Step 3: Enable Swap**

```bash
sudo swapon /dev/vda3
```

Verify:

```bash
swapon --show
free -h
```

---

### **Step 4: Make Swap Permanent**

To enable swap automatically after reboot, add it to `/etc/fstab`:

```
/dev/vda3 none swap sw 0 0
```

---

This will create an 8GB swap partition that is active immediately and will persist across reboots.
