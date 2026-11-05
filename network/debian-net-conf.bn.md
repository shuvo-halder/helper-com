আপনার screenshot অনুযায়ী Debian 12 এখন `/etc/network/interfaces` ব্যবহার করছে এবং interface হলো `enp0s3`।

বর্তমান config:

```ini
allow-hotplug enp0s3
iface enp0s3 inet dhcp
```

এটাকে static IP করতে হবে।

ধরি:

* IP: `192.168.1.100`
* Netmask: `255.255.255.0`
* Gateway: `192.168.1.1`
* DNS: `1.1.1.1`, `8.8.8.8`

তাহলে file হবে:

```ini
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug enp0s3
iface enp0s3 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 1.1.1.1 8.8.8.8

iface enp0s3 inet6 auto
```

Save করে apply করুন:

```bash
sudo systemctl restart networking
```

অথবা:

```bash
sudo ifdown enp0s3 && sudo ifup enp0s3
```

**কিন্তু IP, Gateway, Netmask না জেনে edit করবেন না**, না হলে SSH connection কেটে যেতে পারে।

আগে এই command দুটার output দিন:

```bash
ip addr show enp0s3
ip route
```

বিশেষ করে `ip route` এর output থেকে আমি আপনার বর্তমান gateway দেখে exact config লিখে দিতে পারব।
