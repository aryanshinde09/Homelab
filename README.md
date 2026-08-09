🏠 Homelab

Documentation for my self-hosted homelab — media services, backup automation, and infrastructure notes, all running on a Linux Mint host with Docker.

About

This repo documents the services I run at home: what they do, how they're deployed, and the issues I actually hit while setting them up (so future-me, or anyone else, doesn't have to debug them twice). Everything here reflects a real, running setup.

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

homelab/
├── README.md                  ← You are here
├── jellyfin/
│   ├── README.md
│   └── docker-compose.yml
├── navidrome/
│   ├── README.md
│   └── docker-compose.yml
├── rclone-backup/
│   ├── README.md
│   └── backup-script.sh
└── docs/
    └── homelab-overview.md    ← Cross-service notes (architecture, network layout)

Each service folder is self-contained: its README.md covers setup, configuration, migration notes, and troubleshooting specific to that service. Anything that spans multiple services (shared backup strategy, network diagram, etc.) lives in docs/.