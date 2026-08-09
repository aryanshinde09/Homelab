Homelab Overview

Cross-service notes that don't belong to a single service's README — network layout, shared infrastructure decisions, and architecture.

Network Configuration
Static IP via DHCP Reservation
Host: aryan-linux (Linux Mint)
Reserved IP: 192.168.0.50
Services on this IP: Jellyfin, Navidrome

Why
By default, DHCP leases are temporary — the router can hand the host a different IP address after a lease renewal or reboot. Since both Jellyfin and Navidrome are accessed by IP (bookmarks, other devices on the LAN, and any future reverse proxy config), a changing host IP silently breaks access to both services until the new IP is tracked down.

A DHCP reservation (also called a static lease or address reservation depending on router vendor) fixes this at the router level: the router always hands out the same IP to the same device, identified by its MAC address — while still technically using DHCP rather than manually configuring a static IP on the host itself.

Network Topology

This network runs two routers:

Access point (AP) router — handles Wi-Fi, DHCP disabled (machine running jellyfin and navidrome connected to)
Main router — the DHCP server for the LAN, and where the reservation lives

Having two active DHCP servers on the same subnet causes address conflicts (both routers handing out overlapping leases). Disabling DHCP on the AP and leaving the main router as the sole DHCP server avoids this, and means the reservation only needs to be configured in one place.

Steps
Find the host's MAC address
bash
```
   ip link show
```

Look for the MAC (link/ether) under your active network interface (e.g.wlo1 (Your Wi-Fi) or eno1 (Your Wired Ethernet))

Disable DHCP on the access point router In the AP's admin GUI, turn off its DHCP server so it only handles Wi-Fi and doesn't hand out conflicting leases.
Access the main router Find its default gateway address (usually 192.168.0.1 or 192.168.1.1):
bash
```
   ip route | grep default
```

Enter that IP in a browser and log in with the main router's admin username and password.

Find the DHCP reservation section Typically under LAN Setup, DHCP Server, or Address Reservation — naming varies by router brand.
Add the reservation Bind the host's MAC address to 192.168.0.50.
Apply and renew the lease on the host
bash
```
   sudo dhclient -r
   sudo dhclient
```
Or simply reboot the host — it will request the same IP on next DHCP handshake.

Verify
bash
   ip a

Confirm the host now shows 192.168.0.50 under the active interface.

Result
| Service   | Access URL               |
|-----------|--------------------------|
| Jellyfin  | http://192.168.0.50:8096 |
| Navidrome | http://192.168.0.50:4533 |

These URLs stay stable across reboots and lease renewals, so they're safe to bookmark, hardcode in client apps (Streamio, Symfonium, etc.), or reference in future reverse proxy configuration.