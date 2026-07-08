# 🐧 Linux Command Reference for System Engineers & System Administrators

![Linux](https://img.shields.io/badge/Linux-System%20Administration-green?style=for-the-badge&logo=linux)
![Bash](https://img.shields.io/badge/Bash-Shell-black?style=for-the-badge&logo=gnubash)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

---

# Table of Contents

- File & Directory
- Permissions
- Users & Groups
- Process Management
- Service Management
- Package Management
- Disk Management
- LVM
- Mount
- Network
- Firewall
- SSH
- Logs
- Memory
- CPU
- Monitoring
- Compression
- Download
- Search
- System Information
- Cron
- Time
- Environment Variables
- Archive
- Useful One-Liners
- Troubleshooting

---

# File & Directory

```bash
pwd
ls
ls -lah
tree
cd /path
mkdir folder
mkdir -p /data/app/logs
touch file.txt
cp file1 file2
cp -r dir1 dir2
mv old new
rm file
rm -rf directory
find / -name "*.log"
locate nginx.conf
which nginx
whereis nginx
realpath file
```

---

# File Operations

```bash
cat file
less file
more file
head file
head -20 file
tail file
tail -f /var/log/syslog
nano file
vim file
wc -l file
sort file
uniq file
cut -d ':' -f1 /etc/passwd
paste file1 file2
split -l 1000 file
diff file1 file2
cmp file1 file2
strings binaryfile
```

---

# Permissions

```bash
ls -l

chmod 755 file
chmod 644 file
chmod +x script.sh

chown user:user file

chgrp group file

umask

stat file
```

Permission Table

| Permission | Meaning |
|------------|----------|
| 777 | Full Access |
| 755 | Executable Program |
| 644 | Normal File |
| 600 | Private File |

---

# Users

```bash
whoami

id

who

w

last

useradd user

passwd user

usermod

userdel user

groupadd

groupdel

groups user

gpasswd
```

---

# Sudo

```bash
sudo -i

visudo

sudo su
```

---

# Process Management

```bash
ps aux

ps -ef

top

htop

pstree

pgrep nginx

pidof nginx

kill PID

kill -9 PID

pkill nginx

nice

renice
```

---

# Services (systemd)

```bash
systemctl status nginx

systemctl start nginx

systemctl stop nginx

systemctl restart nginx

systemctl reload nginx

systemctl enable nginx

systemctl disable nginx

systemctl daemon-reload

journalctl -xe

journalctl -u nginx

journalctl -f
```

---

# Package Management

## Debian / Ubuntu

```bash
apt update

apt upgrade

apt install nginx

apt remove nginx

apt autoremove

apt search nginx
```

## RHEL / Rocky

```bash
dnf install nginx

dnf update

dnf remove nginx

yum install nginx
```

---

# Disk

```bash
df -h

du -sh *

du -sh /var

lsblk

blkid

fdisk -l

parted -l

mount

findmnt
```

---

# LVM

```bash
pvcreate

vgcreate

lvcreate

lvdisplay

lvextend

resize2fs

xfs_growfs
```

---

# Mount

```bash
mount /dev/sdb1 /mnt

umount /mnt

mount -a

cat /etc/fstab
```

---

# Network

```bash
ip a

ip addr

ip route

hostname

hostnamectl

ping google.com

traceroute google.com

tracepath google.com

mtr google.com

ss -tulpn

netstat -tulpn

arp -a

ip neigh
```

---

# DNS

```bash
dig google.com

host google.com

nslookup google.com

resolvectl status

cat /etc/resolv.conf
```

---

# Curl & HTTP

```bash
curl ifconfig.me

curl google.com

curl -I https://example.com

wget URL

wget -c file.iso
```

---

# SSH

```bash
ssh user@host

scp file user@host:/tmp

scp -r folder user@host:/tmp

rsync -avz

ssh-keygen

ssh-copy-id user@host
```

---

# Firewall

## UFW

```bash
ufw status

ufw allow 22

ufw allow 80

ufw allow 443

ufw reload
```

## Firewalld

```bash
firewall-cmd --list-all

firewall-cmd --add-service=http --permanent

firewall-cmd --reload
```

---

# Logs

```bash
tail -f /var/log/syslog

tail -f /var/log/messages

journalctl

dmesg

journalctl -u nginx

journalctl --since today
```

---

# Memory

```bash
free -h

vmstat

swapon --show

swapoff -a

swapon -a
```

---

# CPU

```bash
lscpu

uptime

mpstat

sar

iostat

vmstat
```

---

# Monitoring

```bash
top

htop

iotop

iftop

nload

bmon

glances

dstat
```

---

# Compression

```bash
tar -cvf archive.tar folder

tar -xvf archive.tar

tar -czvf archive.tar.gz folder

tar -xzvf archive.tar.gz

gzip file

gunzip file.gz

zip

unzip
```

---

# Search

```bash
grep word file

grep -R "hello" .

find / -name nginx.conf

find / -type f

find / -size +100M

locate php.ini
```

---

# Environment

```bash
env

printenv

echo $PATH

export VAR=value

source ~/.bashrc
```

---

# Time

```bash
date

timedatectl

hwclock

cal
```

---

# Cron

```bash
crontab -e

crontab -l

systemctl status cron

systemctl status crond
```

Example

```cron
*/5 * * * * /opt/backup.sh
```

---

# Archive

```bash
tar

gzip

gunzip

zip

unzip

7z
```

---

# System Information

```bash
hostnamectl

uname -a

cat /etc/os-release

uptime

whoami

id

lscpu

lsmem

dmidecode

lsblk

df -h

free -h
```

---

# Networking Troubleshooting

```bash
ping

traceroute

tracepath

mtr

ss -tulpn

netstat -rn

tcpdump

iftop

ip route

arp -a
```

---

# Performance Troubleshooting

```bash
top

htop

iotop

iostat

vmstat

sar

pidstat

dstat
```

---

# Useful One-Liners

## Largest Files

```bash
find / -type f -exec du -h {} + | sort -rh | head -20
```

## Largest Directories

```bash
du -sh /* | sort -hr
```

## Open Ports

```bash
ss -tulpn
```

## Listening Ports

```bash
lsof -i
```

## Current Connections

```bash
ss -ant
```

## Disk Usage

```bash
df -h
```

## Memory Usage

```bash
free -h
```

## CPU Usage

```bash
top
```

## Processes by Memory

```bash
ps aux --sort=-%mem | head
```

## Processes by CPU

```bash
ps aux --sort=-%cpu | head
```

---

# Important Directories

| Directory | Purpose |
|------------|---------|
| /etc | Configuration Files |
| /var/log | Log Files |
| /home | User Data |
| /root | Root Home |
| /opt | Optional Software |
| /srv | Services |
| /tmp | Temporary Files |
| /usr | User Programs |
| /boot | Boot Files |
| /dev | Devices |
| /proc | Process Info |
| /sys | Kernel Info |

---

# Exit Codes

| Code | Meaning |
|------|----------|
| 0 | Success |
| 1 | General Error |
| 126 | Permission Denied |
| 127 | Command Not Found |
| 130 | Ctrl+C |
| 255 | Exit Status |

---

# Useful Keyboard Shortcuts

| Shortcut | Description |
|----------|-------------|
| Ctrl + C | Stop Process |
| Ctrl + Z | Suspend |
| Ctrl + D | Logout |
| Ctrl + A | Start of Line |
| Ctrl + E | End of Line |
| Ctrl + R | Search History |
| Ctrl + L | Clear Screen |

---

# History

```bash
history

history | grep docker

!!

!100

history -c
```

---

# Alias

```bash
alias ll='ls -lah'

alias k='kubectl'

alias d='docker'

alias cls='clear'
```

---

# Production Tips

- Always use SSH keys instead of passwords.
- Disable root SSH login.
- Enable UFW or firewalld.
- Keep the system updated regularly.
- Monitor logs with `journalctl`.
- Use `htop`, `iotop`, and `iftop` for troubleshooting.
- Configure automatic backups.
- Use `rsync` for efficient file synchronization.
- Audit sudo access regularly.
- Enable log rotation (`logrotate`).
- Use `tmux` or `screen` for long-running sessions.
- Enable time synchronization with `chrony` or `systemd-timesyncd`.
- Regularly verify disk health using `smartctl`.

---

# License

MIT License

---

**Made with ❤️ for Linux System Engineers, DevOps Engineers, Cloud Engineers, SREs, and System Administrators.**

