# Python 3 Local HTTP Server Guide

Python 3 includes a built-in module, `http.server`, that lets you spin up a quick, zero-configuration HTTP server for testing static web pages, local file transfers, or staging assets.

---

### python3 -m http.server (localhost only)
Start a lightweight HTTP server bound strictly to the local loopback interface (`127.0.0.1`).
```bash
python3 -m http.server <PORT> --bind 127.0.0.1
```

#### Flags
| Flag / Argument | Description | Default |
|---|---|---|
| `<PORT>` | Port number to listen on | `8000` |
| `-b`, `--bind <ADDRESS>` | Specify the IP address to bind to | `0.0.0.0` (all interfaces) |
| `-d`, `--directory <PATH>` | Specify the root directory to serve | Current directory (`.`) |

#### Real-World Example
```bash
# Start server on localhost port 8000
python3 -m http.server 8000 --bind 127.0.0.1

# Test endpoint from another terminal
curl -I http://127.0.0.1:8000
```

---

### python3 -m http.server (custom directory)
Serve files directly from a designated directory without changing your current shell directory.
```bash
python3 -m http.server <PORT> --bind 127.0.0.1 --directory <PATH>
```

#### Real-World Example
```bash
# Serve static build files from /var/www/html/dist on port 8080
python3 -m http.server 8080 --bind 127.0.0.1 --directory /var/www/html/dist
```

---

### Stopping the HTTP Server

- **Foreground session**: Press <kbd>Ctrl</kbd> + <kbd>C</kbd> in the active terminal to send `SIGINT` and shut down the server.
- **Background or detached session**: Identify the process listening on the port and terminate it gracefully:
  ```bash
  # Locate the PID listening on port 8000
  sudo ss -tulpn | grep :8000

  # Terminate the process
  kill <PID>
  ```

---

## ⚠️ Network Exposure & Legacy Usage

The original command in this repository was:

```bash
# ⚠️ CAUTION: Binds to 0.0.0.0 by default, exposing files across the local network
python3 -m http.server 7777
```

> [!WARNING]
> ### Why `0.0.0.0` is Risky
> When no `--bind` address is specified, Python binds to `0.0.0.0` (all IPv4 interfaces). This means **any device on the same local network, Wi-Fi, or the public internet (if port 7777 is not blocked by a firewall) can read and download every file** in that directory.
>
> **Production Notice**: Python's `http.server` is single-threaded, lacks access controls, does not support TLS/HTTPS encryption, and is strictly intended for local debugging. Never use it as a public production web server.
