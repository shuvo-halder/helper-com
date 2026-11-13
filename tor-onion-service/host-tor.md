# Tor Onion Service Hosting & Configuration Guide

> [!IMPORTANT]
> **Legal & Authorized Administration Notice**:
> This guide is intended strictly for authorized system administrators and operators deploying privacy-preserving infrastructure, censorship-resistant services, or secure out-of-band remote administration channels. Operators are responsible for complying with all applicable local, national, and international laws.

---

## Table of Contents

- [Overview & Architecture](#overview--architecture)
- [Step-by-Step Deployment Workflow](#step-by-step-deployment-workflow)
  - [Step 1: Install the Tor Daemon](#step-1-install-the-tor-daemon)
  - [Step 2: Start a Local Loopback Backend](#step-2-start-a-local-loopback-backend)
  - [Step 3: Configure /etc/tor/torrc](#step-3-configure-etctortorrc)
  - [Step 4: Reload the Tor Service](#step-4-reload-the-tor-service)
  - [Step 5: Retrieve Your .onion Hostname](#step-5-retrieve-your-onion-hostname)
- [Command Reference](#command-reference)
  - [apt install tor](#apt-install-tor)
  - [python3 -m http.server (Loopback Only)](#python3--m-httpserver-loopback-only)
  - [systemctl restart tor](#systemctl-restart-tor)
  - [journalctl -u tor](#journalctl--u-tor)
  - [cat hostname](#cat-hostname)
- [Hardening & Operational Security (OpSec)](#hardening--operational-security-opsec)
- [Troubleshooting Common Issues](#troubleshooting-common-issues)
- [⚠️ Legacy Scratch Notes](#️-legacy-scratch-notes)

---

## Overview & Architecture

A Tor Onion Service (formerly referred to as a "Hidden Service") exposes a TCP service running on your server through the Tor overlay network using end-to-end encrypted `.onion` addresses.

```
Client (Tor Browser) ---> Tor Network Circuits ---> Tor Daemon (Your Server) ---> 127.0.0.1:<LOCAL_PORT> (Your App)
```

**Key Security Principles**:
1. **Zero Open Inbound Ports**: Tor makes only *outbound* connections to the Tor network. You do not need to open inbound firewall ports or configure NAT port-forwarding on your router.
2. **Localhost Binding Only**: The backend application must listen strictly on `127.0.0.1` or a UNIX domain socket. If your backend listens on `0.0.0.0`, an attacker can reach it over your public IP address and bypass Tor anonymity completely.
3. **Version 3 (v3) Addresses**: Modern Tor uses 56-character ed25519 public key addresses (v3). Legacy 16-character v2 services were fully deprecated and disabled in Tor 0.4.6+.

---

## Step-by-Step Deployment Workflow

### Step 1: Install the Tor Daemon

On Debian / Ubuntu systems:
```bash
sudo apt update && sudo apt install -y tor
```

On RHEL / Rocky Linux / Fedora systems:
```bash
sudo dnf install -y tor
```

---

### Step 2: Start a Local Loopback Backend

Ensure the application you want to expose is running and bound strictly to the local loopback interface (`127.0.0.1`). For demonstration or testing, run Python's built-in HTTP server:

```bash
python3 -m http.server 8080 --bind 127.0.0.1
```

> [!WARNING]
> Never omit `--bind 127.0.0.1`. The default without `--bind` binds to `0.0.0.0`, exposing your backend to the public internet.

---

### Step 3: Configure /etc/tor/torrc

Open the Tor configuration file with root privileges:
```bash
sudo nano /etc/tor/torrc
```

Scroll to the **Section 3: Hidden Services** portion of the file, or append your service definition at the bottom:

```torrc
############### This section is for Onion Services ##################

# Location where Tor stores private keys and hostname for this service
HiddenServiceDir /var/lib/tor/hidden_service/

# Virtual port exposed to clients -> Local destination address and port
HiddenServicePort 80 127.0.0.1:8080
```

| Directive | Purpose | Example |
| :--- | :--- | :--- |
| `HiddenServiceDir` | Directory where Tor generates and stores the cryptographic keys and the `hostname` file. | `/var/lib/tor/hidden_service/` |
| `HiddenServicePort` | Maps the public virtual port (first argument) to the internal address and port (second argument). | `80 127.0.0.1:8080` |

---

### Step 4: Reload the Tor Service

Apply the configuration change by reloading or restarting the Tor daemon:
```bash
sudo systemctl restart tor
```

Check that the daemon has successfully bootstrapped to 100%:
```bash
sudo journalctl -u tor -b --no-pager | grep -i "bootstrapped 100%"
```

---

### Step 5: Retrieve Your .onion Hostname

When Tor starts, it creates the directory specified in `HiddenServiceDir`, generates the ed25519 key pair, and writes the public address into `hostname`:

```bash
sudo cat /var/lib/tor/hidden_service/hostname
```

Output will resemble:
```text
v3exampleonionaddressxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.onion
```

Test access by opening this address in the official Tor Browser or querying through a local SOCKS5 proxy (`socks5h://127.0.0.1:9050`).

---

## Command Reference

### apt install tor
Install the Tor anonymity network daemon from the package manager.
```bash
sudo apt update && sudo apt install -y tor
```
| Flag | Description |
| :--- | :--- |
| `-y` | Automatically confirm package installation prompts |
| `update` | Synchronize package index files before installation |

**Real-world example:**
```bash
# Verify Tor package version after installation
tor --version
```

---

### python3 -m http.server (Loopback Only)
Run an ephemeral HTTP server bound exclusively to localhost for testing Onion routing.
```bash
python3 -m http.server 8080 --bind 127.0.0.1
```
| Flag | Description |
| :--- | :--- |
| `--bind <IP>` | Specify IP address to listen on (MUST be `127.0.0.1` for onion backends) |
| `--directory <DIR>` | Serve files from a designated directory rather than current working directory |
| `<PORT>` | TCP port number to listen on (e.g. 8080) |

**Real-world example:**
```bash
python3 -m http.server 8080 --bind 127.0.0.1 --directory /var/www/html
```

> [!WARNING]
> Do NOT use `python3 -m http.server` as a production web server. It lacks access controls, concurrency tuning, and security hardening. Use Nginx, Apache, or Caddy for production.

---

### systemctl restart tor
Restart or reload the Tor system service after updating configuration directives.
```bash
sudo systemctl restart tor
```
| Command | Description |
| :--- | :--- |
| `restart` | Restarts the Tor service daemon completely |
| `reload` | Signals Tor (`HUP`) to re-read `/etc/tor/torrc` without dropping active circuits |
| `status` | Checks current service state, PID, uptime, and memory usage |

**Real-world example:**
```bash
# Verify syntax before restarting (Tor validates config with --verify-config)
sudo -u debian-tor tor --verify-config -f /etc/tor/torrc
sudo systemctl reload tor
```

---

### journalctl -u tor
Inspect Tor systemd service logs to monitor bootstrapping progress and diagnose configuration errors.
```bash
sudo journalctl -u tor -b --no-pager
```
| Flag | Description |
| :--- | :--- |
| `-u <UNIT>` | Show logs strictly for the specified systemd unit (`tor` or `tor@default`) |
| `-b` | Limit logs to the current system boot |
| `--no-pager` | Print full log text directly to stdout without piping to `less` |
| `-f` | Follow log output in real time (press `Ctrl+C` to exit) |

**Real-world example:**
```bash
# Follow live Tor connection logs
sudo journalctl -u tor -f
```

---

### cat hostname
Display the generated `.onion` domain address for the service.
```bash
sudo cat /var/lib/tor/hidden_service/hostname
```
| Argument | Description |
| :--- | :--- |
| `/var/lib/tor/<DIR>/hostname` | Text file containing the 56-character v3 `.onion` domain address |
| `/var/lib/tor/<DIR>/hs_ed25519_secret_key` | Binary file containing the private key for the Onion service (**NEVER EXPOSE**) |

> [!CAUTION]
> The directory `/var/lib/tor/<DIR>/` contains `hs_ed25519_secret_key`. Whoever holds this private key controls your `.onion` address. Back it up to an encrypted offline location. Never commit it to git or share it over unencrypted channels.

---

## Hardening & Operational Security (OpSec)

1. **Restrict Directory Permissions**:
   Tor will refuse to start if permissions on `HiddenServiceDir` are too permissive.
   ```bash
   # Debian / Ubuntu (service user is debian-tor)
   sudo chown -R debian-tor:debian-tor /var/lib/tor/hidden_service/
   sudo chmod 700 /var/lib/tor/hidden_service/

   # RHEL / Rocky / Fedora (service user is tor)
   sudo chown -R tor:tor /var/lib/tor/hidden_service/
   sudo chmod 700 /var/lib/tor/hidden_service/
   ```

2. **Strip Web Server Headers & Fingerprints**:
   If using Nginx as the reverse proxy for your Onion service, disable software banners:
   ```nginx
   server_tokens off;
   more_clear_headers Server; # Requires headers-more module
   ```

3. **Avoid Mixed Content & External CDN Calls**:
   Do not load JavaScript, CSS, fonts, or images from public CDNs (e.g. Google Fonts, Cloudflare). If a client visits your Onion service and their browser makes a clearweb DNS lookup or HTTP request to a third-party CDN, their identity and location can be compromised.

4. **Synchronize Server Clock with NTP**:
   Tor requires an accurate system clock for circuit building and onion descriptor publication. Ensure `systemd-timesyncd` or `chrony` is active:
   ```bash
   timedatectl status
   ```

5. **Unix Domain Sockets (Zero-Port Exposure)**:
   For maximum security, avoid TCP loopback altogether and connect Tor directly to Nginx via a UNIX domain socket:
   ```torrc
   # Inside /etc/tor/torrc
   HiddenServiceDir /var/lib/tor/unix_service/
   HiddenServicePort 80 unix:/var/run/tor-service.sock
   ```

---

## Troubleshooting Common Issues

| Symptom | Probable Cause | Corrective Action |
| :--- | :--- | :--- |
| **Directory permissions error in logs** | `HiddenServiceDir` is group/world readable | Run `sudo chmod 700 /var/lib/tor/<DIR>` and set proper ownership (`debian-tor:debian-tor`). |
| **`hostname` file does not exist** | Tor has not finished bootstrapping | Check `sudo journalctl -u tor -b`. Verify network connectivity and NTP clock sync. |
| **Connection refused in Tor Browser** | Backend service is not listening on configured port | Run `ss -tulpn '( sport = :8080 )'` and verify your backend is active. |
| **Service unreachable over Tor** | Firewall blocking Tor outbound connections | Tor requires outbound TCP access to directory authorities and relays (ports 80, 443, 9001). Check `sudo ufw status`. |

---

## ⚠️ Legacy Scratch Notes

*The following raw scratch notes from the original document are preserved below for historical context:*

```bash
python3 -m http.server --bind 127.0.0.1 8080

whereis tor
cd /etc/tor
ls
sudo nano torrc
uncomment tor hidden service
then change port 8080
bootstraping tor
cd /var/lib/tor/hidden_service
ls
cat hostname
```
