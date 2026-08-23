# Homelab Overview

This file contains the Config that applies to all my services .

## Network Configuration

Static IP via DHCP Reservation,
Host: aryan-linux (Linux Mint),
Reserved IP: 192.168.0.50,
Services on this IP: Jellyfin, Navidrome.

Why
To access navidrome and jellyfin we need and ip address assigned to the machine running on It. When the router DHCP leases the IP to the machine we use that IP to access jellyfin and navidrome services. But i can be a little hassle as router can assign different IPs at different time, meaning have to check which IP the machine is assigned and then use that ip to access it.

To not have this problem I have set a DHCP Address reservation (192.168.0.50) to my linux machine using my machine mac address.

## Network Topology

My home network topology: 
Main router (192.168.0.1) ->  Wired Access point (192.168.0.2) -> machine/Laptop

Now the DHCP is Disabled on my wired AP as it can lead to IP lease mismatch as both my main router and AP can lease IP at same time.

So In DHCP setting of my main router i have set 192.168.0.50 for my machine using the machines mac address. 

Result

| Service   | Access URL               |
|-----------|--------------------------|
| Jellyfin  | http://192.168.0.50:8096 |
| Navidrome | http://192.168.0.50:4533 |
