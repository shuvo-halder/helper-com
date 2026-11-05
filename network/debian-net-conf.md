# Debian Static Network Configuration

> **Note**: An original Bengali version of this guide is available at [debian-net-conf.bn.md](debian-net-conf.bn.md).

This guide describes how to configure a static IPv4 address on Debian using `/etc/network/interfaces` (`ifupdown`).

---

## 1. Verify Current Network Configuration

Before modifying any configuration files, check your active interface name, IP address, and default gateway to avoid getting locked out over SSH:

```bash
# Identify your active interface and current IP
ip addr show enp0s3

# Identify your current default gateway
ip route
```

---

## 2. Default Dynamic (DHCP) Configuration

In Debian, a default dynamic interface configuration typically looks like this:

```ini
allow-hotplug enp0s3
iface enp0s3 inet dhcp
```

---

## 3. Static IP Configuration Example

To convert the interface to a static IP address, edit `/etc/network/interfaces`:

```ini
source /etc/network/interfaces.d/*

# Loopback network interface
auto lo
iface lo inet loopback

# Primary network interface
allow-hotplug enp0s3
iface enp0s3 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 1.1.1.1 8.8.8.8

# IPv6 auto configuration (optional)
iface enp0s3 inet6 auto
```

> **Warning**: Ensure the `address`, `netmask`, and `gateway` match your actual network subnet before applying. Incorrect values will terminate active SSH sessions.

---

## 4. Apply Network Configuration

Apply the new settings using systemd:

```bash
sudo systemctl restart networking
```

Alternatively, cycle the individual interface:

```bash
sudo ifdown enp0s3 && sudo ifup enp0s3
```
