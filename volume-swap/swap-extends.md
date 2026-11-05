Create a new swapfile:

bash
sudo fallocate -l 2G /swapfile2
sudo chmod 600 /swapfile2
sudo mkswap /swapfile2
sudo swapon /swapfile2
Verify:

bash
swapon --show
free -h
This way, the system keeps using the old swapfile while you add more capacity.

📘 Register in /etc/fstab
To make swap permanent across reboots, add entries like:

fstab
/swapfile   none   swap   sw   0 0
/swapfile2  none   swap   sw   0 0
Or, if you only have one resized swapfile:

fstab
/swapfile   none   swap   sw   0 0
