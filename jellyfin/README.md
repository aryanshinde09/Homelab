Jellyfin

Jellyfin is a free, open-source media server that lets you host your own personal streaming service. It organizes your movies, TV shows, music, and photos on a computer or dedicated server so you can stream them to any device, like a phone, tablet, or smart TV, without any ads or subscription fees.

Overview

jellyfin runs as a Docker container on aryan-linux, reachable on the LAN at a fixed address thanks to the DHCP reservation set on the main router.

Stack
Image: jellyfin/jellyfin (Docker Hub)
Access: http://192.168.0.50:8096
Runs as: UID:GID 1000:1000 (non-root)
Transcoding: software (CPU) — no GPU device passthrough configured
Restart policy: unless-stopped
docker-compose.yml

See docker-compose.yml in this folder. It's extracted from a shared compose file that also defines Navidrome — see navidrome/README.md for that service.

| Host path                   | Container path | Purpose                                     | Mode       |
|-----------------------------|----------------|---------------------------------------------|------------|
| /opt/docker/jellyfin/config | /config        | Library DB, metadata, users, watched status | Read-write |
| /opt/docker/jellyfin/cache  | /cache         | Transcode cache, image cache (regenerable)  | Read-write |
| /mnt/hdd/Anime              | /Anime         | Anime library                               | Read-only  |
| /mnt/hdd/Cartoons           | /Cartoons      | Cartoons library                            | Read-only  |
| /mnt/hdd/Movies             | /Movies        | Movies library                              | Read-only  |
| /mnt/hdd/tv_show            | /Tv_shows      | TV shows library                            | Read-only  |

Media mounts are read_only: true — Jellyfin only ever reads media files, so there's no reason to give the container write access to /mnt/hdd.

Permissions (UID/GID)

The container runs as user: 1000:1000 instead of root. This has to match:

The ownership of /opt/docker/jellyfin/config and /cache on the host (Jellyfin needs write access here)
The UID/GID that can read the files under /mnt/hdd (read access is enough since media is mounted read-only)

Check your own UID/GID with:

bash
```
id
```
If it's not 1000:1000, either update the user: line to match, or chown the config/cache folders:

bash
```
sudo mkdir -p /opt/docker/jellyfin/config
sudo mkdir -p /opt/docker/jellyfin/cache
sudo chown -R 1000:1000 /opt/docker/jellyfin
```

Setup
Create host directories and fix ownership (see above).
Bring the container up:
bash
```
docker compose up -d jellyfin
```
Open http://192.168.0.50:8096 and complete the first-run setup wizard (admin account, preferred metadata language).
Add libraries pointing at the container paths — /Anime, /Cartoons, /Movies, /Tv_shows — not the host paths.
Let the initial library scan finish, then spot-check that posters/metadata pulled in correctly.

Backup

Config isn't backed up via rclone — the Jellyfin setup itself is quick enough to redo from scratch (admin account, add four library paths, done). What's actually worth tracking is which plugins are installed, since re-adding and reconfiguring each one by hand after a fresh install is the tedious part. See Plugins below.

Plugins
Intro Skipper — Analyzes episode audio to detect intro/credit sequences and adds a skip button (or auto-skips).
Editor's Choice — Adds a full-width featured-content slider to the home screen, Netflix-style.
MyAnimeList — Metadata provider for anime, sourced from MyAnimeList.
File Transformation — Lets other plugins inject UI changes into the web client without patching Jellyfin's files directly.

Useful Commands

View Logs
```
docker logs -f jellyfin
```
Restart the container
```
docker compose restart jellyfin
```
update to latest image
```
docker compose pull jellyfin
docker compose up -d jellyfin
```
shell into the running container
```
docker exec -it jellyfin bash
```
