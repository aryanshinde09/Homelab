Jellyfin — Native Installation (Linux Mint)

Jellyfin media server installed natively (no Docker) on Linux Mint, as part of the homelab stack alongside Navidrome.

1. Network Setup — Static IP Reservation

Before installing anything, I set up a DHCP reservation on my main router for this laptop, pinning it to 192.168.0.50. Nothing fancy — I just got tired of the IP changing every so often and having to dig through the router's client list to find the machine again.

Method: DHCP reservation on the main router
Reserved IP: 192.168.0.50
Why: Now Jellyfin (and everything else running on this box) is always at http://192.168.0.50:8096, no matter how many times the laptop reboots or reconnects to Wi-Fi.

Worth noting — this isn't a static IP configured on the laptop itself. The router is the one doing the work here, always handing out .50 whenever it sees this laptop's MAC address..

2. Install Jellyfin

Downloaded jellyfin from Official jellyfin website. (diffrent steps for Diffrent distros/os)

3. Enable & Start the Service

'''sudo systemctl enable jellyfin (for enable service on startup)
    sudo systemctl start jellfin
sudo systemctl status jellyfin
'''


4. First-Time Setup Wizard

Open in a browser (from the same machine or any device on the LAN):

http://192.168.0.50:8096

Then complete the setup wizard:


Choose display language
Create admin username/password
Add media libraries (point to your media folders, e.g. under /mnt/hdd)
Set preferred metadata language
Finish setup


