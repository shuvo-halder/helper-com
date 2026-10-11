```bash
# 1. Disable existing swap and remove its entry from fstab
swapoff /dev/vda5
sed -i.bak '/vda5/d' /etc/fstab

# 2. Delete logical swap (vda5) and extended (vda2) partitions non-interactively
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
```
# 6. Add the new swap file to fstab to persist across reboots
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# 7. Update GRUB and initramfs to register the new filesystem layout
update-grub
echo "RESUME=none" > /etc/initramfs-tools/conf.d/resume
update-initramfs -u
