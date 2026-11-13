# 🐧 Linux Command Reference & Sysadmin Helper Collection

[![Linux](https://img.shields.io/badge/Linux-System%20Administration-2ea44f?style=for-the-badge&logo=linux&logoColor=white)](https://www.kernel.org/)
[![Bash](https://img.shields.io/badge/Bash-Shell%20Reference-121011?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)
[![Status: Production Ready](https://img.shields.io/badge/Status-Maintained-brightgreen?style=for-the-badge)](#)

A modern, copy-paste-safe, production-aware Linux administration handbook and DevOps reference. This repository organizes essential command recipes, security best practices, storage management routines, networking setups, and system triage procedures for system engineers, site reliability engineers (SREs), and Linux administrators.

---

## ⚠️ Safety Notice & Pre-Flight Checks

> [!WARNING]
> Many commands documented here—including partition modifications, filesystem resizing, firewall updates, permission changes, and process termination—can alter system availability or result in **irreversible data loss** if applied carelessly.
>
> 1. **Test in a Staging Environment**: Always test storage, network, and permission commands in a local virtual machine or non-production staging instance first.
> 2. **Take Snapshots**: Take VM-level hypervisor snapshots or cloud block-storage backups before altering disk partitions, LVM volumes, or mount points.
> 3. **Verify Block Devices & IPs**: Always run non-destructive verification commands (`lsblk -f`, `ip addr`, `ip route`, `df -h`) to verify disk and interface names before executing destructive modifications.
> 4. **Authorized Use Only**: Diagnostic, auditing, and administrative tools in this repository must only be executed on infrastructure you own or have explicit authorization to administer.

---

## 🌐 Language Notice

Primary documentation throughout this repository is written in concise, technical English. Historical and original Bengali versions of select forensic and networking guides are preserved with full commit history as side-by-side files (suffixed with `.bn.md`) and linked directly from the corresponding English documents:
- [`incident-response/find.md`](incident-response/find.md) $\leftrightarrow$ [বাংলা সংস্করণ (`find.bn.md`)](incident-response/find.bn.md)
- [`incident-response/find-1.md`](incident-response/find-1.md) $\leftrightarrow$ [বাংলা সংস্করণ (`find-1.bn.md`)](incident-response/find-1.bn.md)
- [`network/debian-net-conf.md`](network/debian-net-conf.md) $\leftrightarrow$ [বাংলা সংস্করণ (`debian-net-conf.bn.md`)](network/debian-net-conf.bn.md)

---

## 📁 Repository Topic Index

Each subdirectory contains its own scoped documentation, practical recipes, and configuration templates:

| Directory | Scope & Highlights | Folder Guide |
|---|---|---|
| [**`Linux/`**](Linux/) | Partition hierarchy, local Python testing server security, GRUB boot parameters, safe `/var/www/html` permissions. | [`Linux/README.md`](Linux/README.md) |
| [**`gitHelp/`**](gitHelp/) | Global and per-repository Git identity setup, initial repository onboarding, remote branch publishing. | [`gitHelp/README.md`](gitHelp/README.md) |
| [**`MySql/`**](MySql/) | Scoped database user creation, least-privilege permissions, authentication plugins, privilege reloading. | [`MySql/README.md`](MySql/README.md) |
| [**`PHP/`**](PHP/) | Password hashing script via native `password_hash()` (bcrypt / Argon2id), PHP-FPM and server security notes. | [`PHP/README.md`](PHP/README.md) |
| [**`network/`**](network/) | Debian static IP interface configuration (`/etc/network/interfaces`), cloud-init network overwrite fixes. | [`network/README.md`](network/README.md) |
| [**`volume-swap/`**](volume-swap/) | Live volume growth (`growpart`, `resize2fs`, `xfs_growfs`), LVM expansion (`pvresize`, `lvextend`), dedicated swap files and partitions. | [`volume-swap/README.md`](volume-swap/README.md) |
| [**`vps-default/nginx/`**](vps-default/nginx/) | Production default catch-all Nginx virtual host, ACME webroot passthrough, Matrix-style terminal diagnostic page. | [`vps-default/nginx/README.md`](vps-default/nginx/README.md) |
| [**`tor-onion-service/`**](tor-onion-service/) | Private Tor Onion Service setup via `/etc/tor/torrc`, localhost service binding, identity leak prevention. | [`tor-onion-service/README.md`](tor-onion-service/README.md) |
| [**`incident-response/`**](incident-response/) | Defensive web server incident response: hunting webshells, auditing modified files, detecting SEO cloaking/redirects. | [`incident-response/README.md`](incident-response/README.md) |

---

## 📑 Table of Contents

- [Core Administration Commands](#core-administration-commands)
  - [File and Directory Operations](#file-and-directory-operations)
  - [File Viewing and Text Processing](#file-viewing-and-text-processing)
  - [Permissions and Ownership](#permissions-and-ownership)
  - [User and Group Management](#user-and-group-management)
  - [Privilege Escalation and Sudo](#privilege-escalation-and-sudo)
  - [Process Management](#process-management)
  - [Systemd Services and Timers](#systemd-services-and-timers)
  - [Package Management](#package-management)
  - [Storage and Filesystem Management](#storage-and-filesystem-management)
  - [Logical Volume Management (LVM)](#logical-volume-management-lvm)
  - [Mounting and Filesystems](#mounting-and-filesystems)
  - [Networking and DNS](#networking-and-dns)
  - [Transfer and Remote Access (SSH and HTTP)](#transfer-and-remote-access-ssh-and-http)
  - [Firewalls (UFW and Firewalld)](#firewalls-ufw-and-firewalld)
  - [System Logs (Journalctl and Syslog)](#system-logs-journalctl-and-syslog)
  - [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)
  - [Archives and Compression](#archives-and-compression)
  - [Search and File Finding](#search-and-file-finding)
  - [Environment Variables](#environment-variables)
  - [Date, Time, and Scheduling (Cron)](#date-time-and-scheduling-cron)
  - [System Information and Hardware](#system-information-and-hardware)
  - [Useful Shell One-Liners](#useful-shell-one-liners)
  - [Shell History and Aliases](#shell-history-and-aliases)
- [Reference Tables](#reference-tables)
  - [Distribution Comparison](#distribution-comparison)
  - [Standard Linux Directories](#standard-linux-directories)
  - [Common Exit Codes](#common-exit-codes)
  - [Useful Keyboard Shortcuts](#useful-keyboard-shortcuts)
- [Production Engineering Best Practices](#production-engineering-best-practices)
- [Quick-Start](#quick-start)
- [Contributing](#contributing)
- [License](#license)

---

# Core Administration Commands

## File and Directory Operations

Standard commands for inspecting, moving, and managing directories and files.

```bash
# Print current working directory
pwd

# List contents (standard, and detailed with human-readable sizes including hidden files)
ls
ls -lah

# Display directory structure as an ASCII tree (install via package manager if missing)
tree -L 2

# Change working directory
cd /path/to/directory

# Create directories (single, or recursive with parent directories)
mkdir myfolder
mkdir -p /data/app/logs

# Create an empty file or update its access/modification timestamp
touch filename.txt

# Copy files and directories (-r copies recursively)
cp source.txt destination.txt
cp -r /source/dir /destination/dir

# Move or rename files and directories
mv old_name.txt new_name.txt

# Remove a single file
rm filename.txt

# Locate executable binary paths
which nginx
whereis nginx

# Resolve and print the canonical absolute path of a file or link
realpath ../relative/file.txt
```

> [!WARNING]
> **Dangerous Command: `rm -rf <directory>`**  
> Recursive forced removal (`rm -rf`) bypasses confirmation and deletes files permanently. If executed with unexpanded variables (e.g. `rm -rf $DIR/`) or targeting root (`/`), it can wipe the operating system.  
> **Safer Alternative**: Use `rm -rI <directory>` (prompts before deleting more than 3 files or descending recursively) or move files to a temporary directory first: `mv <target> /tmp/trash/`.

---

## File Viewing and Text Processing

Viewing, parsing, and transforming text and log files.

```bash
# Output full file content to terminal
cat /etc/os-release

# Paginated interactive file viewing (press 'q' to exit, '/' to search)
less /var/log/syslog

# View top lines of a file (default 10 lines, or custom number)
head -n 20 /var/log/nginx/access.log

# View the last lines of a file, or follow incoming lines live in real time
tail -n 50 /var/log/syslog
tail -f /var/log/nginx/error.log

# Count lines, words, and characters in a file
wc -l /etc/passwd

# Sort lines in text files (alphabetical or numerical)
sort names.txt
sort -n numbers.txt

# Filter out repeated adjacent lines (often combined with sort)
sort access.log | uniq -c | sort -nr

# Extract specific delimited fields (e.g., usernames from /etc/passwd)
cut -d ':' -f1 /etc/passwd

# Merge lines of files side-by-side
paste file1.txt file2.txt

# Split a large file into smaller chunks of 1000 lines each
split -l 1000 largefile.csv chunk_

# Compare files line by line
diff -u file1.conf file2.conf

# Byte-by-byte file comparison
cmp file1.bin file2.bin

# Extract readable printable strings from a binary or compiled object
strings /usr/bin/nginx | grep -i "version"
```

---

## Permissions and Ownership

Managing POSIX file permissions, ownership, and default umask masks.

```bash
# View detailed permissions and ownership
ls -l /var/www

# Display detailed inode, permission, and timestamp metadata for a file
stat /etc/shadow

# Set permissions using symbolic or octal notation
chmod 755 script.sh
chmod 644 config.yaml
chmod +x deploy.sh

# Change user and group ownership
sudo chown www-data:www-data /var/www/html

# Change group ownership only
sudo chgrp developers /opt/shared

# Display or set file mode creation mask
umask
```

### Permission Octal Reference Table

| Octal | Binary | Permission Mask | Common Use Case |
|---|---|---|---|
| `755` | `rwxr-xr-x` | User: read/write/execute; Group & Others: read/execute | Executable binaries, scripts, and traversable directories. |
| `644` | `rw-r--r--` | User: read/write; Group & Others: read-only | Standard configuration files, web assets, and documents. |
| `600` | `rw-------` | User: read/write; Group & Others: no access | Sensitive files: SSH private keys (`id_ed25519`), certificates, credentials. |
| `700` | `rwx------` | User: read/write/execute; Group & Others: no access | Private directories: `~/.ssh`, GPG keyrings, Tor hidden service directories. |

> [!WARNING]
> **Dangerous Command: `chmod 777` or `chmod -R 777`**  
> Giving world-writable (`777`) access allows any local user or compromised daemon to overwrite files and inject webshells or malicious binaries.  
> **Safer Alternative**: Keep files owned by the application service user and set directory permissions to `755` and file permissions to `644`:  
> `find /var/www/html -type d -exec chmod 755 {} +`  
> `find /var/www/html -type f -exec chmod 644 {} +`  
> See [`Linux/var-www-html.md`](Linux/var-www-html.md) for full webroot security guidelines.

---

## User and Group Management

Managing local system user accounts, passwords, and group memberships.

```bash
# Print current active user identity
whoami
id

# Display currently logged-in users and current terminal activity
who
w

# Show recent user login history
last -n 10

# Create a new user with home directory and bash shell
sudo useradd -m -s /bin/bash deployer

# Set or update a user's password
sudo passwd deployer

# Append user to supplementary administrative group (sudo on Debian/Ubuntu, wheel on RHEL)
sudo usermod -aG sudo deployer      # Debian / Ubuntu
sudo usermod -aG wheel deployer     # RHEL / Rocky

# List all groups the current user belongs to
groups

# Create and remove local groups
sudo groupadd developers
sudo groupdel developers

# Remove a user account and its home directory
sudo userdel -r olduser
```

---

## Privilege Escalation and Sudo

Safe elevation of privileges for system administrative tasks.

```bash
# Safely edit /etc/sudoers with syntax validation to prevent lockouts
sudo visudo

# Open an interactive login shell as the root user
sudo -i

# Run an individual command with root privileges
sudo systemctl restart nginx
```

> [!NOTE]
> Avoid using raw `su -` or maintaining perpetual root shells; use `sudo <command>` to maintain a clear audit trail in `/var/log/auth.log` or `/var/log/secure`.

---

## Process Management

Listing, prioritizing, and terminating system processes.

```bash
# Snapshot active running processes
ps aux
ps -ef

# Display processes in a hierarchical tree view
pstree -p

# Search for process ID by process name
pgrep -l nginx
pidof nginx

# Send a polite termination request (SIGTERM - Signal 15) allowing clean shutdown
kill <PID>
pkill -TERM nginx

# Adjust process scheduling priority (-20 most urgent, 19 least urgent)
nice -n 10 ./backup.sh
renice 5 -p <PID>
```

> [!WARNING]
> **Dangerous Command: `kill -9 <PID>` (SIGKILL)**  
> SIGKILL forcefully terminates a process without allowing it to flush memory buffers, close open database connections, or remove temporary lock files, risking application data corruption.  
> **Safer Alternative**: Always send `kill <PID>` (SIGTERM) first and allow 10–15 seconds for graceful shutdown. Only resort to `kill -9` if the process is completely hung and non-responsive.

---

## Systemd Services and Timers

Controlling background daemons, boot behavior, and scheduled timers.

```bash
# Check service status, start, stop, restart, or reload configuration
sudo systemctl status nginx
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx

# Enable or disable a service at system boot
sudo systemctl enable nginx
sudo systemctl disable nginx

# Reload systemd manager configuration after adding or editing unit files
sudo systemctl daemon-reload

# View active systemd scheduled timers (modern alternative to cron)
systemctl list-timers
```

---

## Package Management

Managing software repositories, packages, and updates across distributions.

### Debian / Ubuntu (`apt`)
```bash
# Refresh package index from repositories
sudo apt update

# Upgrade all installed packages to latest versions
sudo apt upgrade -y

# Search for and install a package
apt search nginx
sudo apt install -y nginx

# Remove a package (keep configuration, or remove configuration with purge)
sudo apt remove nginx
sudo apt purge nginx

# Remove orphaned dependencies no longer needed
sudo apt autoremove -y
```

### RHEL / Rocky / AlmaLinux (`dnf` / `yum`)
```bash
# Refresh metadata and upgrade all packages
sudo dnf check-update
sudo dnf upgrade -y

# Search for and install a package
dnf search nginx
sudo dnf install -y nginx

# Remove a package and unneeded dependencies
sudo dnf remove nginx
```

---

## Storage and Filesystem Management

Inspecting disk usage, partition tables, and filesystem capacity.

```bash
# Human-readable summary of mounted filesystem disk usage
df -h

# Summarize directory space consumption
du -sh /var/log/* | sort -hr | head -n 10

# List block devices with size, mount point, and filesystem type
lsblk -f

# Print block device UUIDs and filesystem labels
sudo blkid

# List partition tables using fdisk or parted
sudo fdisk -l
sudo parted -l
```

> [!WARNING]
> **Dangerous Commands: Partitioning and Formatting (`fdisk`, `parted`, `mkfs.ext4`, `mkfs.xfs`)**  
> Running formatting commands like `mkfs.ext4 /dev/sdX` permanently destroys all existing filesystem headers and data on the target device.  
> **Safer Alternative**: Verify the disk name twice with `lsblk` and check that the partition is unmounted before formatting. For expanding existing live disks safely, see [`volume-swap/volume-resize-guide.md`](volume-swap/volume-resize-guide.md).

---

## Logical Volume Management (LVM)

High-level commands for managing LVM Physical Volumes (PV), Volume Groups (VG), and Logical Volumes (LV).

```bash
# 1. Physical Volumes: inspect and initialize raw partitions for LVM
sudo pvs
sudo pvdisplay
sudo pvcreate /dev/sdb1

# 2. Volume Groups: create, inspect, and extend volume groups
sudo vgs
sudo vgdisplay
sudo vgcreate vg_data /dev/sdb1
sudo vgextend vg_data /dev/sdc1

# 3. Logical Volumes: create, inspect, and extend logical volumes
sudo lvs
sudo lvdisplay
sudo lvcreate -L 20G -n lv_app vg_data

# Extend logical volume live and resize filesystem
sudo lvextend -L +10G /dev/vg_data/lv_app
sudo resize2fs /dev/vg_data/lv_app      # For ext4
sudo xfs_growfs /mount/point            # For XFS
```

> [!NOTE]
> XFS filesystems **cannot be shrunk**; they can only be expanded. ext4 filesystems can be grown online, but shrinking requires unmounting and offline filesystem checking. For detailed LVM expansion recipes, see [`volume-swap/centos9-volume-swap-partition-extend.md`](volume-swap/centos9-volume-swap-partition-extend.md).

---

## Mounting and Filesystems

Mounting block storage, unmounting safely, and defining persistent mounts in `/etc/fstab`.

```bash
# Mount a partition to a directory
sudo mount /dev/sdb1 /mnt

# Safely unmount a target directory or device
sudo umount /mnt

# Mount all filesystems declared in /etc/fstab without rebooting
sudo mount -a

# Display active mount points in an organized hierarchy
findmnt
```

### Persistent Mount Entry in `/etc/fstab`
```text
# <file system>                           <mount point>  <type>  <options>       <dump>  <pass>
UUID=3a2b1c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d /data          ext4    defaults,noatime 0       2
```

---

## Networking and DNS

Inspecting interfaces, routes, active listening sockets, and name resolution.

```bash
# Show IP addresses and network link status (modern replacement for ifconfig)
ip addr
ip -brief addr
ip link

# Display IP routing table (modern replacement for route -n)
ip route

# Show system hostname and system chassis details
hostnamectl

# Test ICMP echo network connectivity
ping -c 4 1.1.1.1

# Trace network route hops to destination
traceroute 1.1.1.1
tracepath google.com
mtr google.com

# Inspect listening TCP and UDP sockets with process names (modern replacement for netstat)
sudo ss -tulpn

# Inspect neighbor ARP cache table
ip neigh

# Query DNS records using dig, host, and nslookup
dig google.com +short
dig -x 1.1.1.1
host google.com
nslookup google.com

# Inspect systemd-resolved DNS configuration and active DNS servers
resolvectl status

# Display static resolver file
cat /etc/resolv.conf
```

---

## Transfer and Remote Access (SSH and HTTP)

Transferring files, testing endpoints, and managing SSH keys.

```bash
# Remote shell connection
ssh deployer@192.168.1.50

# Securely copy files over SSH
scp archive.tar.gz deployer@192.168.1.50:/tmp/
scp -r ./config_dir deployer@192.168.1.50:/etc/myapp/

# Fast, resumable file synchronization with rsync (archive mode, verbose, compressed)
rsync -avz --progress /local/source/ deployer@192.168.1.50:/remote/destination/

# Generate modern Ed25519 SSH keypair
ssh-keygen -t ed25519 -C "admin@company.com"

# Install public SSH key onto a remote server for passwordless login
ssh-copy-id -i ~/.ssh/id_ed25519.pub deployer@192.168.1.50

# Inspect public IP address via HTTP service
curl ifconfig.me

# Fetch HTTP headers only
curl -I https://example.com

# Download files with resume support
wget -c https://example.com/software.tar.gz
```

---

## Firewalls (UFW and Firewalld)

Configuring stateful firewall rules across distributions.

### UFW (Debian / Ubuntu)
```bash
# Inspect active firewall rules
sudo ufw status verbose

# Allow standard web and SSH ports
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable or reload firewall rules
sudo ufw enable
sudo ufw reload
```

### Firewalld (RHEL / Rocky / AlmaLinux)
```bash
# List all active zones and allowed services
sudo firewall-cmd --list-all

# Allow services permanently and reload rules
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

---

## System Logs (Journalctl and Syslog)

Filtering, following, and querying system and kernel logs.

```bash
# Follow live system logs (journald)
sudo journalctl -f

# Query logs for a specific systemd unit
sudo journalctl -u nginx.service -n 100 --no-pager

# Filter logs since a specific time boundary or priority level
sudo journalctl --since "1 hour ago"
sudo journalctl -p err..emerg

# Inspect kernel ring buffer messages
sudo dmesg -T | grep -i error

# Follow traditional syslog files (if rsyslog is installed)
tail -f /var/log/syslog       # Debian / Ubuntu
tail -f /var/log/messages     # RHEL / Rocky
```

---

## Monitoring and Troubleshooting

Consolidated real-time monitoring and diagnostic tools for CPU, memory, disk I/O, and networking.

### System & CPU Diagnostics
```bash
# View system uptime and load averages (1, 5, 15 minutes)
uptime

# Display detailed CPU architecture and core details
lscpu

# Interactive process viewers (CPU, RAM, threads)
top
htop

# Report CPU utilization per core (install sysstat if missing)
mpstat -P ALL 2 5
```

### Memory & Swap Diagnostics
```bash
# Human-readable summary of physical RAM and swap usage
free -h

# Virtual memory statistics (run every 2 seconds, 5 times)
vmstat 2 5

# Inspect active swap devices and utilization
swapon --show
```

> [!WARNING]
> **Dangerous Command: `swapoff -a`**  
> Disabling all swap spaces (`swapoff -a`) forces the kernel to move all pages back into physical RAM. If available RAM is insufficient, the system will trigger an immediate Out-Of-Memory (OOM) condition and freeze or terminate critical processes.  
> **Safer Alternative**: Verify free memory first (`free -h`). Turn off swap on an individual swap partition or swap file instead: `sudo swapoff /swapfile`.

### Disk I/O & Network Diagnostics
```bash
# Report I/O utilization per disk device (await, %util)
iostat -xz 2 5

# Interactive per-process I/O monitor
sudo iotop -o

# Real-time network interface bandwidth monitor
sudo iftop -i eth0
nload

# Capture and inspect live network packets
sudo tcpdump -i eth0 -n -c 20 port 80
```

---

## Archives and Compression

Creating, listing, and extracting archive formats.

```bash
# 1. Tarball (.tar): create and extract
tar -cvf archive.tar /path/to/folder
tar -xvf archive.tar -C /target/dir

# 2. Gzip-compressed tarball (.tar.gz): create, list, and extract
tar -czvf archive.tar.gz /path/to/folder
tar -tzvf archive.tar.gz
tar -xzvf archive.tar.gz -C /target/dir

# 3. Compress / decompress individual files with gzip
gzip large_file.log            # Creates large_file.log.gz
gunzip large_file.log.gz       # Restores large_file.log

# 4. Standard zip compression and extraction
zip -r archive.zip /path/to/folder
unzip archive.zip -d /target/dir

# 5. High-ratio 7z compression (install p7zip if missing)
7z a archive.7z /path/to/folder
7z x archive.7z
```

---

## Search and File Finding

Locating files, directories, and text patterns across the filesystem.

```bash
# Search for files by name (case-insensitive)
find /etc -iname "*.conf"

# Find files modified within the last 7 days
find /var/www -type f -mtime -7

# Find files larger than 100 megabytes
find /var/log -type f -size +100M

# Search for text recursively within files, showing line numbers
grep -Rni "document_root" /etc/nginx/

# Fast indexed filename lookup (update index first with updatedb)
locate nginx.conf
```

---

## Environment Variables

Inspecting, defining, and sourcing environment variables.

```bash
# Print all exported environment variables
env
printenv

# View specific variable value
echo "$PATH"
echo "$SHELL"

# Export a persistent variable in the current shell session
export APP_ENV="production"

# Reload shell configuration file
source ~/.bashrc
```

---

## Date, Time, and Scheduling (Cron)

System clock synchronization and automated task scheduling.

```bash
# Display or set current system date and time
date
timedatectl status

# Display hardware RTC clock
sudo hwclock --show

# View and edit the current user's crontab
crontab -l
crontab -e

# Inspect cron daemon status
sudo systemctl status cron     # Debian / Ubuntu
sudo systemctl status crond    # RHEL / Rocky
```

### Crontab Syntax Example
```cron
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
# │ │ │ │ │
# * * * * * <command to execute>
  0 2 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
```

---

## System Information and Hardware

Gathering operating system, kernel, and hardware specifications.

```bash
# Linux kernel version and system architecture
uname -a

# Distribution release and version metadata
cat /etc/os-release

# System motherboard, vendor, and BIOS details (requires root)
sudo dmidecode -s system-product-name

# Physical memory hardware modules and slots
sudo dmidecode --type memory
```

---

## Useful Shell One-Liners

Practical diagnostic commands for day-to-day sysadmin workflows:

```bash
# 1. Top 15 largest files on the filesystem
find / -xdev -type f -exec du -Sh {} + 2>/dev/null | sort -rh | head -n 15

# 2. Top 10 largest directories
du -Sh /var 2>/dev/null | sort -rh | head -n 10

# 3. List all listening TCP ports and associated processes
sudo ss -tulpn | grep LISTEN

# 4. View active established connections per remote IP
ss -ant '( state established )' | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr

# 5. Top 10 processes consuming the most RAM
ps aux --sort=-%mem | awk 'NR<=11{print $2,$4,$11}'

# 6. Top 10 processes consuming the most CPU
ps aux --sort=-%cpu | awk 'NR<=11{print $2,$3,$11}'

# 7. Check open files by network connections
sudo lsof -i -P -n
```

---

## Shell History and Aliases

Managing command history and useful shortcuts.

```bash
# Display command history
history

# Search command history for a keyword
history | grep "docker"

# Re-execute the immediate previous command with sudo
sudo !!

# Re-execute command by history number
!42
```

> [!WARNING]
> **Dangerous Command: `history -c`**  
> Clears the in-memory shell history. Doing so removes administrative audit trails and makes post-incident troubleshooting impossible.  
> **Safer Alternative**: Prevent sensitive commands from being recorded by configuring `HISTCONTROL=ignorespace` in `~/.bashrc` and prefixing commands containing passwords with a single leading space.

### Recommended Common Aliases (`~/.bashrc`)
```bash
alias ll='ls -lah --color=auto'
alias dfh='df -h -x tmpfs -x devtmpfs'
alias ports='sudo ss -tulpn'
alias myip='curl -s ifconfig.me && echo'
```

---

# Reference Tables

## Distribution Comparison

| Capability / Task | Debian / Ubuntu | RHEL / Rocky / AlmaLinux |
|---|---|---|
| **Package Manager** | `apt`, `dpkg` | `dnf`, `yum`, `rpm` |
| **Default Web Server Path** | `/var/www/html` | `/var/www/html` or `/usr/share/nginx/html` |
| **Web Server User** | `www-data` | `nginx` or `apache` |
| **Default Firewall** | UFW (`ufw`) or `nftables` | Firewalld (`firewall-cmd`) or `nftables` |
| **Network Configuration** | Netplan (`/etc/netplan/`) or `ifupdown` | NetworkManager (`nmcli`, `/etc/NetworkManager/`) |
| **Sudo Group** | `sudo` | `wheel` |
| **System Log Service** | `systemd-journald`, `rsyslog` | `systemd-journald`, `rsyslog` |

---

## Standard Linux Directories

| Directory | Filesystem Hierarchy Standard (FHS) Role |
|---|---|
| `/etc` | Host-specific system-wide configuration files. |
| `/var/log` | System, service, and application log files. |
| `/home` | User home directories for personal files and configurations. |
| `/root` | Home directory for the administrative superuser (`root`). |
| `/opt` | Add-on application software packages. |
| `/srv` | Site-specific data served by this system (web, FTP). |
| `/tmp` | Temporary files (often cleared automatically at reboot). |
| `/usr/bin` | Primary user command binaries. |
| `/boot` | Static bootloader files, Linux kernel images (`vmlinuz`), and initramfs. |
| `/dev` | Device nodes representing physical and virtual hardware devices. |
| `/proc` | Virtual filesystem providing kernel and process runtime information. |
| `/sys` | Virtual filesystem exporting kernel subsystem parameters and hardware attributes. |

---

## Common Exit Codes

| Exit Code | Meaning | Typical Context |
|---|---|---|
| `0` | Success | Command completed without error. |
| `1` | General Error | Catch-all for unspecified errors or user runtime issues. |
| `2` | Misuse of Shell Builtins | Syntax error or invalid parameter passed to shell builtin. |
| `126` | Command Invoked Cannot Execute | Permission problem or command is not an executable binary. |
| `127` | Command Not Found | Executable not found in `$PATH` or file does not exist. |
| `128+N` | Fatal Signal `N` | Process terminated by signal `N` (e.g., `130` for `SIGINT` / `Ctrl+C`, `137` for `SIGKILL`). |
| `255` | Exit Status Out of Range | SSH connection error or invalid exit code argument. |

---

## Useful Keyboard Shortcuts

| Shortcut | Function | Description |
|---|---|---|
| <kbd>Ctrl</kbd> + <kbd>C</kbd> | SIGINT | Interrupt and stop the currently running foreground command. |
| <kbd>Ctrl</kbd> + <kbd>Z</kbd> | SIGTSTP | Suspend the foreground process and push it to background jobs. |
| <kbd>Ctrl</kbd> + <kbd>D</kbd> | EOF | Close current shell session or end standard input stream. |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> | Home | Move cursor to the beginning of the command line. |
| <kbd>Ctrl</kbd> + <kbd>E</kbd> | End | Move cursor to the end of the command line. |
| <kbd>Ctrl</kbd> + <kbd>U</kbd> | Cut Line | Delete line from cursor position to the start of the line. |
| <kbd>Ctrl</kbd> + <kbd>K</kbd> | Cut Forward | Delete line from cursor position to the end of the line. |
| <kbd>Ctrl</kbd> + <kbd>R</kbd> | Reverse Search | Interactively search through command history. |
| <kbd>Ctrl</kbd> + <kbd>L</kbd> | Clear | Clear terminal viewport (equivalent to `clear`). |

---

# Production Engineering Best Practices

1. **Enforce SSH Key Authentication**: Disable password authentication and root SSH access (`PermitRootLogin no`, `PasswordAuthentication no`) in `/etc/ssh/sshd_config`.
2. **Implement Automated Backups**: Maintain off-site encrypted backups of configuration files (`/etc`) and databases. Test restoration routines regularly.
3. **Configure Log Rotation**: Ensure `/etc/logrotate.d/` prevents disk exhaustion from uncontrolled log files.
4. **Active Time Synchronization**: Run `chrony` or `systemd-timesyncd` to prevent SSL/TLS verification and distributed database replication failures.
5. **Least-Privilege Database Access**: Create dedicated database users restricted to their application database instead of using root accounts.
6. **Session Persistence**: Use `tmux` or `screen` for remote management tasks to prevent dropped sessions during network disruptions.
7. **Monitor Resource Headroom**: Configure alerts for disk capacity exceeding 80% to avoid sudden service disruption.

---

## Quick-Start

To quickly search for a command in this reference:
- Use your browser or editor search (<kbd>Ctrl</kbd> + <kbd>F</kbd> / <kbd>Cmd</kbd> + <kbd>F</kbd>).
- Jump directly to specialized folders using the [Repository Topic Index](#-repository-topic-index).
- Review safety warnings before executing any storage, firewall, or permission modifications.

---

## Contributing

Contributions, fixes, and improvements are welcome! Please read our [**Contributing Guide**](CONTRIBUTING.md) for full details on safety rules, command formatting requirements, placeholder conventions, and the pull request process.

See [**`CHANGELOG.md`**](CHANGELOG.md) for recent release notes and migration history.

---

## License

This project is licensed under the [MIT License](LICENSE).
