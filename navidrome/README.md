Navidrome

Self-hosted music server, running in Docker.

Overview

Navidrome runs as a Docker container on aryan-linux, reachable on the LAN, not outside the network.
To access Navidrome server on android system i am using Symphonium app.

Stack

Image: deluan/navidrome:latest (Docker Hub)
Access: http://192.168.0.50:4533
Runs as: UID:GID 1000:1000 (non-root)
Restart policy: unless-stopped
docker-compose.yml

Check Navidrome official docker installation for docker compose format
See docker-compose.yml in this folder. 

Docker compose file config explanation:

user: "1000:1000" 
my user UID/GID on my linux machine (as same as jellyfin setup)

volumes:
      - /opt/docker/navidrome/data:/data
   The path for navidrome files to be stored at
      - /mnt/hdd/Music:/music:ro
   the pathe where the music files are at (read only)

Library

Now navidrome has a particular way of showing music in library. 
It groups songs in album based on the songs metadata (album artist name and its album name).

This works fine for albums that has only one album artist in the whole album.
The main problem happens when one album has to many album artist such as indian songs.
(Note : Haven't found a good alternative solution for this problem but the below solution works fine)

The only Solution to this problem is edit the Metadata of the songs which have multiple album artist.
We can do this using Music tag editing software such as puddletag for linux, mp3tag for windows.

The only fields to change of the song are 
Album artist of song -> Various Artists
Compilation of song -> 1
Also make if there are many artist (not album artist) in song use ; to separate each artist.


Backups

songs and navidrome.db from config path are backed up using rclone to google drive.
Cause navidrome.db file is an SQLite database that stores all application data, user states, and indexed metadata for music collection, separate from actual audio files.



