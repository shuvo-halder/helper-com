# Linux Static IP & Network Failure Troubleshooting Guide

When a static IP address fails to apply, drops after a reboot, or loses external connectivity, follow this structured, multi-layer troubleshooting checklist—ordered from physical/link verification up to daemon routing and cloud automation.

---

## Quick Diagnostic Matrix

| Symptom | Likely Cause | Command to Check | Fix / Remediation |
|---|---|---|---|
| Interface state is `DOWN` or `NO-CARRIER` | Virtual NIC disconnected or administratively down | `ip link show <INTERFACE>` | `sudo ip link set <INTERFACE> up` |
| Static IP vanishes after server reboot | `cloud-init` overwrites network configs on boot | `grep -ri "network" /etc/cloud/` | `sudo touch /etc/cloud/cloud-init.disabled` |
| Gateway unreachable (`Network is unreachable`) | Missing default gateway in routing table | `ip route` | Add gateway: `sudo ip route add default via <GATEWAY> dev <INTERFACE>` |
| IP works, but domain names fail to resolve | Misconfigured nameservers or `systemd-resolved` stopped | `resolvectl status` or `cat /etc/resolv.conf` | Configure working `nameserver <DNS_SERVER>` |
| High packet loss or intermittent connectivity | IP address collision on the local subnet | `sudo arping -I <INTERFACE> <STATIC_IP>` | Assign an unused IP address outside DHCP pools |
| Interface ignores `/etc/network/interfaces` | Conflicting service (`NetworkManager` or `systemd-networkd`) | `systemctl is-active NetworkManager networking` | Disable conflicting manager: `sudo systemctl disable --now NetworkManager` |

---

## Step-by-Step Troubleshooting Checklist

### 1. Verify Interface Link State

Ensure the kernel recognizes the network adapter and the physical/virtual link carrier is active.

### ip link (legacy equivalent: ifconfig)
Display interface link operational state, MAC address, and carrier status.
```bash
ip link show <INTERFACE>
```

#### Flags
| Flag | Description |
|---|---|
| `show <INTERFACE>` | Show status for designated interface only |
| `-s`, `-stats` | Output packet drop and error statistics |

#### Real-World Example
```bash
ip link show eth0
# Look for state: UP or DOWN, and flag: NO-CARRIER or LOWER_UP
```
If the interface is down administratively, bring it up:
```bash
sudo ip link set eth0 up
```

---

### 2. Verify Predictable Interface Naming

Modern Linux kernels assign persistent interface names (e.g. `enp0s3`, `ens3`, `eth0`) based on firmware or PCI bus topology. If a VM hypervisor configuration changed or hardware was upgraded, the interface identifier may have shifted.

```bash
# List all recognized network interfaces
ip -brief link
```
Ensure the interface identifier in `/etc/network/interfaces` or Netplan matches the actual kernel device name shown above.

---

### 3. Validate Configuration Syntax

Check configuration files for common typos, invalid subnet masks, or missing configuration directives.

```bash
# For Debian (/etc/network/interfaces):
cat /etc/network/interfaces

# For Ubuntu Netplan (detects YAML indentation or parsing errors):
sudo netplan generate
```

---

### 4. Detect Conflicting Network Daemons

Running multiple network configuration services simultaneously can cause race conditions where one daemon strips the IP assigned by another.

```bash
# Check status of competing network management daemons
systemctl is-active networking NetworkManager systemd-networkd
```

If `ifupdown` (`networking`) is your primary manager on Debian, disable `NetworkManager`:
```bash
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
```

---

### 5. Check Gateway Reachability and Routing

Verify that the default route points to the correct gateway on your local subnet.

### ip route (legacy equivalent: route -n)
Inspect the active routing table.
```bash
ip route
```

#### Real-World Example
```bash
ip route
# Expected output format:
# default via 192.0.2.1 dev eth0 onlink
# 192.0.2.0/24 dev eth0 proto kernel scope link src 192.0.2.50
```

Test direct ICMP ping to the gateway:
```bash
ping -c 3 192.0.2.1
```

If the default route is missing:
```bash
sudo ip route add default via 192.0.2.1 dev eth0
```

---

### 6. Detect IP Address Conflicts (Collisions)

If another device on the same local network is already assigned the IP address you are trying to use, packets will be dropped or routed to the other host.

### arping
Send ARP requests to probe whether another host responds to the target IP address.
```bash
sudo arping -c 3 -I <INTERFACE> <STATIC_IP>
```

#### Real-World Example
```bash
sudo arping -c 3 -I eth0 192.0.2.50
# If MAC addresses other than your own respond, the IP is in use by another machine
```

---

### 7. Test DNS Resolution

Verify whether failure is related to network transport or DNS name resolution:

```bash
# Test raw IP connectivity (bypasses DNS)
ping -c 3 198.51.100.1

# Query DNS resolver using dig
dig +short debian.org @192.0.2.2
```

If `ping <IP>` succeeds but domain names fail, check `/etc/resolv.conf` or run `resolvectl status <INTERFACE>`.

---

### 8. Inspect Firewall Rules

Check whether local firewall tables (UFW, Firewalld, or nftables) are dropping outbound traffic or ICMP responses.

```bash
# Check UFW status (Debian / Ubuntu)
sudo ufw status verbose

# Check Firewalld status (RHEL / Rocky)
sudo firewall-cmd --list-all

# Inspect raw nftables ruleset
sudo nft list ruleset
```

---

### 9. Prevent Cloud-Init Overwriting Configuration on Reboot

On cloud hosting environments (AWS, Hetzner, DigitalOcean, Linode), `cloud-init` runs during early boot, queries instance metadata, and overwrites `/etc/network/interfaces` or Netplan configurations with default provider DHCP settings.

#### Option A: Completely Disable Cloud-Init
```bash
# Prevent cloud-init from running entirely on subsequent boots
sudo touch /etc/cloud/cloud-init.disabled
```

#### Option B: Disable Cloud-Init Network Generation Only (Recommended)
Preserve cloud-init SSH key handling and volume setup while preventing network file modification by adding a configuration override:

```bash
sudo mkdir -p /etc/cloud/cloud.cfg.d
echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
```

---

### 10. Review Systemd Service Logs

Inspect low-level initialization errors from the networking daemons:

```bash
# Debian ifupdown networking logs
sudo journalctl -u networking.service -n 50 --no-pager

# Systemd-networkd logs (if used)
sudo journalctl -u systemd-networkd.service -n 50 --no-pager

# NetworkManager logs (if used)
sudo journalctl -u NetworkManager.service -n 50 --no-pager
```
