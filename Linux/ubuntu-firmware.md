# Ubuntu Firmware Management and GRUB Boot Parameters

This guide details how to inspect and update system firmware on Ubuntu using `fwupdmgr` and package managers, as well as how to configure kernel boot parameters in GRUB.

---

## Part 1: Checking and Updating System Firmware

### fwupdmgr (UEFI & device firmware)
Query hardware devices and install firmware updates via the Linux Vendor Firmware Service (LVFS).
```bash
fwupdmgr get-devices
```

#### Useful Subcommands
| Command | Description |
|---|---|
| `fwupdmgr get-devices` | List all hardware devices supporting firmware updates |
| `fwupdmgr refresh` | Refresh metadata from the LVFS remote repository |
| `fwupdmgr get-updates` | Check if firmware updates are available for attached devices |
| `fwupdmgr update` | Download and apply available device firmware updates |

#### Real-World Example
```bash
# Refresh remote firmware index
fwupdmgr refresh

# Check for pending device updates
fwupdmgr get-updates

# Apply updates (system may prompt for reboot)
fwupdmgr update
```

---

### apt (kernel & processor microcode packages)
Update core Linux kernel firmware packages and proprietary hardware drivers.
```bash
sudo apt update && sudo apt install -y linux-firmware intel-microcode amd64-microcode
```

#### Real-World Example
```bash
# Check recommended proprietary hardware and GPU drivers
sudo ubuntu-drivers list

# Ensure core kernel firmware blobs are up to date
sudo apt install --only-upgrade linux-firmware
```

---

## Part 2: GRUB Kernel Boot Parameters Workflow

Configuring kernel parameters such as log levels, splash screens, or hardware workarounds in `/etc/default/grub`.

### Step 1: Edit GRUB Configuration
Open the GRUB default configuration file with a terminal editor (avoid GUI editors like `gedit` on servers):

```bash
sudo nano /etc/default/grub
```

---

### Step 2: Configure Kernel Command Line
Locate the `GRUB_CMDLINE_LINUX_DEFAULT` variable and configure your desired boot flags:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3"
```

#### Parameter Breakdown
| Parameter | Description |
|---|---|
| `quiet` | Suppresses routine informational boot messages |
| `splash` | Displays vendor/OS graphical splash screen instead of text console |
| `loglevel=3` | Sets kernel log level to `3` (KERN_ERR), displaying only errors and panics |
| `mce=off` | <!-- VERIFY --> Disables Machine Check Exceptions (MCE). Use only as a temporary hardware troubleshooting workaround |

> [!WARNING]
> **Use Caution with `mce=off`**  
> Machine Check Architecture (MCE) notifies the kernel of critical hardware faults (such as memory bus errors or CPU cache failures). Disabling MCE (`mce=off`) silences hardware diagnostics. It should only be applied if troubleshooting a known buggy BIOS/firmware exception storm <!-- VERIFY --> and should not remain enabled on production servers.

---

### Step 3: Update GRUB Configuration

### update-grub
Compile `/etc/default/grub` into the active `/boot/grub/grub.cfg` file.
```bash
sudo update-grub
```

#### Distro Comparison for Updating GRUB
| Distribution | Command |
|---|---|
| **Ubuntu / Debian** | `sudo update-grub` |
| **RHEL / Rocky / AlmaLinux** | `sudo grub2-mkconfig -o /boot/grub2/grub.cfg` <!-- VERIFY --> |

---

### Step 4: Verify Applied Parameters
After rebooting the system, verify active kernel boot parameters:

```bash
cat /proc/cmdline
```
