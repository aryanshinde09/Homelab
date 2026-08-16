🏠 Homelab

Documentation for my self-hosted homelab — media services, backup automation, and infrastructure notes, all running on a Linux Mint host with Docker.

About

This repo documents the services I run at home: what they do, how they're deployed, and the issues I actually hit while setting them up (so future-me doesn't have to debug them twice). Everything here reflects a real, running setup.

Host System

| Component         | Details                                |
|-------------------|----------------------------------------|
| OS                | Linux Mint (Zena)                      |
| Container runtime | Docker                                 |
| Media storage     | /mnt/hdd                               |
| Backup            | rclone → Google Drive (personal OAuth) |

Services

| Service       | Purpose                       | Deployment     | Docs                    |
|---------------|-------------------------------|----------------|-------------------------|
| Jellyfin      | Media server (video)          | Docker         | jellyfin/README.md      |
| Navidrome     | Music streaming               | Docker         | navidrome/README.md     |
| rclone Backup | Automated Google Drive backup | Crontab        | rclone-backup/README.md |


Repo Structure
```
Homelab/
├── docs/
│   └── homelab-overview.md   --> File for configs that applies to all
├── FuturePlans.md            --> Future plans
├── jellyfin/
│   ├── docker-compose.yml
│   └── README.md
├── navidrome/
│   ├── docker-compose.yml
│   └── README.md
├── rclone-backup/
│   ├── backup-script.sh
│   └── README.md
└── README.md                  --> you are here


```


