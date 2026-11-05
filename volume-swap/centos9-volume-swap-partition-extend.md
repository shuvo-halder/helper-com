Alright brother, you want to **extend the root LV (`cs-root`) but keep 6 GB free** for swap or other use.
According to your current `lsblk` output:

```
vda 100G
├─vda1 1G /boot
└─vda2 29G
   ├─cs-root 27G /
   └─cs-swap 2G
```

You have **about 71 GB of free space after the `/dev/vda2` partition** (100 G – 1 G – 29 G ≈ 70 G).

---

### **Step 1: Grow the physical partition (`/dev/vda2`)**

First, you need to expand the partition so that the LVM Physical Volume can use the additional space.
On CentOS 9, you can use `growpart`.
If it’s not installed, install it with:

```bash
sudo dnf install cloud-utils-growpart -y
```

Then run:

```bash
sudo growpart /dev/vda 2
```

> If the partition doesn’t grow successfully, you might need to free or remove another partition (like swap).
> In your case, there’s nothing after `/dev/vda2`, so it should grow easily.

---

### **Step 2: Resize the PV (Physical Volume)**

```bash
sudo pvresize /dev/vda2
```

Now the LVM Physical Volume will recognize the newly added free space.

---

### **Step 3: Extend the LV but leave 6 GB free**

1. Check how much free space is available in the volume group:

```bash
sudo vgdisplay cs | grep "Free  PE / Size"
```

Suppose it shows about 70 GB free.
To leave 6 GB unused, extend your root LV by 64 GB:

```bash
sudo lvextend -L +64G /dev/cs/root
```

* `+64G` = total free space − 6 GB

---

### **Step 4: Resize the filesystem**

If your root filesystem is **XFS** (default on CentOS 9):

```bash
sudo xfs_growfs /
```

If it’s **ext4**, use:

```bash
sudo resize2fs /dev/cs/root
```

---

### ✅ **Summary**

* After extending the root LV, 6 GB of free space will remain in the Volume Group.
* You can later use that free 6 GB to **expand the swap LV** or **create a new LV**.

---

If you want, I can write an **exact ready-to-copy command sequence** that safely extends your root while keeping exactly 6 GB free.
Would you like me to do that?



Yes brother, you **can add 6 GB of free space to `/dev/cs/swap`**, but you need to be a little careful. Since swap is a **logical volume**, you must use LVM commands to increase its size.

Your current setup looks like this:

```
/dev/cs/root 27G  /
/dev/cs/swap 2G
Free in VG: 6G
```

---

### **Step 1: Turn off swap**

First, disable the swap space:

```bash
sudo swapoff /dev/cs/swap
```

---

### **Step 2: Resize the logical volume**

To add 6 GB:

```bash
sudo lvextend -L +6G /dev/cs/swap
```

* Now the swap LV will become 8 GB (2G + 6G)

---

### **Step 3: Format the swap**

After enlarging the swap LV, you must reformat it:

```bash
sudo mkswap /dev/cs/swap
```

---

### **Step 4: Enable swap**

```bash
sudo swapon /dev/cs/swap
```

* Verify it:

```bash
swapon --show
free -h
```

* `/dev/cs/swap` should now show as 8 GB.

---

### ✅ **Important Notes**

* **You must turn off the swap before resizing the LV.**
* Unlike a normal filesystem, you always need to run `mkswap` after resizing a swap LV.
* `/etc/fstab` stays the same — the new swap will automatically activate on boot.

---

If you want, I can write a **ready-to-copy command sequence** that safely expands `/dev/cs/swap` to 8 GB.
Would you like me to do that?
