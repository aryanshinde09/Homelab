# Jellyfin

Jellyfin is a free, open-source media server that lets you host your own personal streaming service. It organizes your movies, TV shows, music, and photos on a computer or dedicated server so you can stream them to any device, like a phone, tablet, or smart TV, without any ads or subscription fees.

## Overview

Jellyfin works on my linux mint on docker. It runs on lAN network, meaning it cannot be accessed out my home network.  

Stack
Image: jellyfin/jellyfin (Docker Hub)  
Access: http://192.168.0.50:8096  
Runs as: UID:GID 1000:1000 (non-root)  
Restart policy: unless-stopped  

The docker file format can be found in jellyfin official installation website
See docker-compose.yml in this folder.

## Explanation for docker file configs:

user : 1000 : 1000 
My linux user UID and GID

Jellyfin require two folder to store its files
/opt/docker/jellyfin/config:/config
This path stores jellyfin config files

/opt/docker/jellyfin/cache:/cache
This path stores jellyfin cache

(make sure the two folders for jellyfin has read,write and execute permission for user)

type: bind
      source: /mnt/hdd/Anime
      target: /Anime
      read_only: true

This are just a path to show jellyfin where the specific media are. 

## Backups

I have Backed up the config directory of jellyfin /opt/docker/jellyfin/config as it contains all the necessary files. 
The only file i have excluded is the metadata file inside the config file as it can be build up automatically by jellyfin.

## Plugins i use  

Intro Skipper — Analyzes episode audio to detect intro/credit sequences and adds a skip button (or auto-skips).
Editor's Choice — Adds a full-width featured-content slider to the home screen, Netflix-style.
MyAnimeList — Metadata provider for anime, sourced from MyAnimeList.
File Transformation — Lets other plugins inject UI changes into the web client without patching Jellyfin's files directly.

