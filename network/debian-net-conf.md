# Debian Network Configuration Guide

> **Note**: An original Bengali version of this guide is available at [debian-net-conf.bn.md](debian-net-conf.bn.md).

This guide describes how to configure dynamic (DHCP) and static IPv4 addresses on Debian systems using `/etc/network/interfaces` (`ifupdown`), manage DNS resolvers, and verify connectivity using modern Linux networking tools.

---

> [!WARNING]
> ### ⚠️ Remote Access Warning (SSH Lockout Prevention)
> Changing an IP address, netmask, or default gateway on a remote server over SSH carries a high risk of **immediate lockout**. If the new configuration fails to initialize or contains an unreachable gateway, the SSH session will freeze and drop.
>
> 1. **Ensure Out-of-Band Access**: Always verify you have access to a provider web console, IPMI, iDRAC, or VNC before modifying interface files.
> 2. **Create a Real Safety Net (Automated Rollback)**:
>    - First, backup the current working configuration:
>      ```bash
>      sudo cp /etc/network/interfaces /etc/network/interfaces.bak
>      ```
>    - Schedule an automatic restore before applying changes using `at`:
>      ```bash
>      # Schedule automatic rollback in 5 minutes via 'at'
>      echo "cp /etc/network/interfaces.bak /etc/network/interfaces && systemctl restart networking" | sudo at now + 5 minutes
>      ```
>      *(If `at` is unavailable, use a detached background timer: `nohup sh -c 'sleep 300 && cp /etc/network/interfaces.bak /etc/network/interfaces && systemctl restart networking' >/dev/null 2>&1 &`)*
>    - Test your connectivity. Once access and settings are confirmed, cancel the scheduled restore:
>      ```bash
>      # List jobs with atq, then remove the pending rollback job
>      atq
>      sudo atrm <JOB_ID>
>      ```
>      *(If you also scheduled a reboot via `sudo shutdown -r +5` as an emergency fallback, cancel it with `sudo shutdown -c`)*
> 3. **Run Interface Cycling in a Persistent Session**:
>    Never execute `ifdown` as a bare command over SSH. Even when chained (`ifdown && ifup`), the SSH connection can terminate between the two commands if network routing is interrupted. Always run interface cycling inside `tmux`, `screen`, `nohup`, or directly from the out-of-band console.

---

## Pre-Flight Verification Commands

Before modifying any configuration files, inspect your active interface names, existing IP allocations, and routing tables.

### ip a (legacy equivalent: ifconfig)
Display all active network interfaces, assigned IP addresses, and link status.
```bash
ip a show <INTERFACE>
```

#### Flags
| Flag / Argument | Description |
|---|---|
| `show <INTERFACE>` | Limit output to a specific network interface |
| `-brief` | Display summary output in single-line table format |
| `-c`, `-color` | Colorize terminal output for readability |

#### Real-World Example
```bash
# Query active interface eth0
ip -brief a show eth0
# Output: eth0 UP 192.0.2.10/24 fe80::1/64
```

---

### ip route (legacy equivalent: route -n)
Inspect the active kernel routing table to identify the default gateway.
```bash
ip route
```

#### Real-World Example
```bash
ip route
# Output: default via 192.0.2.1 dev eth0 onlink
```

---

## 1. Dynamic (DHCP) Interface Configuration

On Debian systems using `ifupdown`, a standard dynamic configuration in `/etc/network/interfaces` reads as follows:

```ini
# Primary dynamic interface configuration
allow-hotplug <INTERFACE>
iface <INTERFACE> inet dhcp
```

#### Real-World Example (`/etc/network/interfaces`)
```ini
allow-hotplug eth0
iface eth0 inet dhcp
```

---

## 2. Static IPv4 Configuration

To assign a permanent static IP address, edit `/etc/network/interfaces`:

```bash
sudo nano /etc/network/interfaces
```

Configure the loopback and primary network interfaces using CIDR prefix notation or netmask:

```ini
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug <INTERFACE>
iface <INTERFACE> inet static
    address <STATIC_IP>/<PREFIX>
    gateway <GATEWAY>
    dns-nameservers <DNS_SERVER_1> <DNS_SERVER_2>

# Optional IPv6 auto-configuration
iface <INTERFACE> inet6 auto
```

#### Real-World Example (`/etc/network/interfaces` using RFC 5737 addresses)
```ini
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug eth0
iface eth0 inet static
    address 192.0.2.50/24
    gateway 192.0.2.1
    dns-nameservers 192.0.2.2 198.51.100.2

iface eth0 inet6 auto
```

---

## 3. Applying Network Changes

Apply the modified network configuration using one of the following methods:

### systemctl restart networking
Restart the Debian ifupdown networking service to reload `/etc/network/interfaces`.
```bash
sudo systemctl restart networking
```

#### Real-World Example
```bash
sudo systemctl restart networking
```

> [!WARNING]
> Restarting the networking daemon terminates and restarts all configured interfaces. If your new settings are malformed, active SSH sessions will disconnect.

---

### ifdown and ifup
Cycle a specific network interface down and back up. Run inside tmux, screen, nohup, or directly from the console.
```bash
sudo ifdown <INTERFACE> && sudo ifup <INTERFACE>
```

#### Real-World Example
```bash
# Run inside tmux or nohup to prevent disconnect between commands
sudo ifdown eth0 && sudo ifup eth0
```

> [!WARNING]
> Do not execute `ifdown && ifup` directly in an unprotected remote SSH session. An SSH connection can drop between `ifdown` and `ifup` if network routing drops before `ifup` begins. Always execute interface cycling inside a terminal multiplexer (`tmux` or `screen`), via `nohup`, or directly from an out-of-band management console.

---

## 4. DNS Configuration: `/etc/resolv.conf` vs `systemd-resolved`

### Traditional Debian (`/etc/resolv.conf`)
If `systemd-resolved` is not running, Debian writes DNS resolvers directly to `/etc/resolv.conf` or manages them via the `resolvconf` package:
```text
nameserver 192.0.2.2
nameserver 198.51.100.2
```

### Modern Systems (`systemd-resolved`)
If `systemd-resolved` is enabled, `/etc/resolv.conf` is a symlink to `/run/systemd/resolve/stub-resolv.conf`. Manage and inspect DNS resolution using `resolvectl`:

### resolvectl (legacy equivalent: inspecting /etc/resolv.conf)
Display per-link DNS servers, domain search paths, and DNSSEC status.
```bash
resolvectl status <INTERFACE>
```

#### Real-World Example
```bash
resolvectl status eth0
```

---

## 5. Post-Configuration Verification

Verify link status, routing, and end-to-end connectivity after applying changes:

### ping
Test ICMP reachability to the default gateway and external nameservers.
```bash
ping -c 4 <GATEWAY>
```

#### Real-World Example
```bash
# 1. Test gateway reachability
ping -c 4 192.0.2.1

# 2. Test outbound public IP reachability
ping -c 4 198.51.100.1

# 3. Test DNS hostname resolution
ping -c 4 debian.org
```

---

### ss (legacy equivalent: netstat)
Inspect listening network sockets to confirm local services are bound to the new IP.
```bash
sudo ss -tulpn
```

#### Flags
| Flag | Description |
|---|---|
| `-t` | Display TCP sockets |
| `-u` | Display UDP sockets |
| `-l` | Display listening sockets only |
| `-p` | Show process using socket (requires root) |
| `-n` | Do not resolve service names (show numeric ports) |

#### Real-World Example
```bash
sudo ss -tulpn | grep -E ':(22|80|443)'
```

---

## Distribution Network Management Comparison

| Distribution | Configuration Framework | Primary Configuration File / Path | Apply Command |
|---|---|---|---|
| **Debian** | `ifupdown` | `/etc/network/interfaces` | Run inside tmux/nohup: `sudo ifdown <INTERFACE> && sudo ifup <INTERFACE>` or `sudo systemctl restart networking` |
| **Ubuntu** | Netplan <!-- VERIFY: version differences --> | `/etc/netplan/*.yaml` | `sudo netplan try` (with timeout rollback) before `sudo netplan apply` |
| **RHEL / Rocky / AlmaLinux** | NetworkManager (`nmcli`) <!-- VERIFY: version differences --> | `/etc/NetworkManager/system-connections/` | `sudo nmcli connection reload && sudo nmcli connection up <INTERFACE>` |

#### Ubuntu Netplan Example (`/etc/netplan/01-netcfg.yaml`) <!-- VERIFY: version differences -->
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.0.2.50/24
      routes:
        - to: default
          via: 192.0.2.1
      nameservers:
        addresses: [192.0.2.2, 198.51.100.2]
```
To safely test Netplan without risking lockout:
```bash
# Automatically rolls back in 120 seconds if user does not confirm
sudo netplan try
```

#### RHEL / Rocky `nmcli` Static IP Example <!-- VERIFY: version differences -->
```bash
# Configure static IP, gateway, and DNS on connection eth0
sudo nmcli connection modify eth0 ipv4.addresses 192.0.2.50/24
sudo nmcli connection modify eth0 ipv4.gateway 192.0.2.1
sudo nmcli connection modify eth0 ipv4.dns "192.0.2.2 198.51.100.2"
sudo nmcli connection modify eth0 ipv4.method manual

# Activate the updated profile
sudo nmcli connection up eth0
```
