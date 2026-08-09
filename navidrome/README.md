Navidrome

Self-hosted music server, running in Docker, serving a library from /mnt/hdd/Music. Navidrome speaks the Subsonic API, so it works with a wide range of client apps rather than locking you into one interface.

Overview

Navidrome runs as a Docker container on aryan-linux, reachable on the LAN at a fixed address thanks to the DHCP reservation set on the main router.

Stack

Image: deluan/navidrome:latest (Docker Hub)
Access: http://192.168.0.50:4533
Runs as: UID:GID 1000:1000 (non-root)
Restart policy: unless-stopped
docker-compose.yml

See docker-compose.yml in this folder. It's extracted from a shared compose file that also defines Jellyfin — see jellyfin/README.md for that service.

Volume Mapping

| Host path                  | Container path | Purpose         | Mode       |
|----------------------------|----------------|-----------------|------------|
| /opt/docker/navidrome/data | /data          | Database        | Read-write |
| /mnt/hdd/Music             | /music         | Music library   | Read-only  |

Permissions (UID/GID)

Same pattern as Jellyfin: the container runs as 1000:1000, which must match the ownership of /opt/docker/navidrome/data (needs write access) and be able to read /mnt/hdd/Music.

bash
sudo mkdir -p /opt/docker/navidrome/data
sudo chown -R 1000:1000 /opt/docker/navidrome

Setup

Create the host data directory and fix ownership (see above).
Bring the container up:

bash
   docker compose up -d navidrome

Open http://192.168.0.50:4533 and create the initial admin account.

Client Apps
Web UI — built in, no setup needed, good for admin tasks and library management.

Symfonium (Android) — the recommended day-to-day client. Supports offline downloads, Android Auto, and has its own advanced tag parser on top of whatever the server sends. Because it does its own client-side parsing, it's possible for Symfonium to display artists slightly differently than the Navidrome web UI in edge cases — worth spot-checking both if something looks off, so you know whether the mismatch is server-side (Navidrome's scan) or client-side (Symfonium's parser).

Library Structure


