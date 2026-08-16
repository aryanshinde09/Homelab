Homelab Overview

This file containes the Config that applies to all my.

Network Configuration

Static IP via DHCP Reservation
Host: aryan-linux (Linux Mint)
Reserved IP: 192.168.0.50
Services on this IP: Jellyfin, Navidrome

Why
The main problem is to access navidrome and jellyfin we need an ip address. The DHCP of router leases ip to the machine but it keep changing after reboot . this make accessing services bu checking the ip address assigned to machine. 

To not have this problem I have set a DHCP Address reservation to my linux machine using my laptops mac address

Network Topology

My home network topology: 
Main router (192.168.0.1) ->  Wired Access point (192.168.0.2) -> machine/Laptop

Now the DHCP id Disabled on my wired AP as it can lead to ip lease mismatch as both my main router and ap can lease ip at same time.

So In DHCP setting of my main router i have set 192.168.0.50 for my machine using the machines mac address. 

Result
| Service   | Access URL               |
|-----------|--------------------------|
| Jellyfin  | http://192.168.0.50:8096 |
| Navidrome | http://192.168.0.50:4533 |
