# Rclone 

Rclone is a free, open-source command-line program that lets you manage, sync, and back up files across local storage and over 70 cloud storage providers—such as Google Drive, Amazon S3, and Dropbox. Often called "rsync for cloud storage," it handles data transfers, encryption, and mounting remote drives.

## Overview

I have setup rclone to sync my music and other personal folder to google cloud for backup purpose. It is fully cli based system and only runs when called.  
I have created a backup-script.sh (using claude) to sync my folders to google cloud as a backup.
see the backup-script 

## backup-script.sh workflow in simple  

First checks if Navidrome or Jellyfin in docker are running --> If yes Stop them and backup their data --> start the container if they were running before backup --> Continue to backup other folder in the list (musics,picture,documnets etc.)

Note: Stopping the Navidrome and jellyfin container before backup is essential, as when they are working both apps have a database file that's actively being written to while running. If you copy it mid-write, you can grab a half-saved, corrupted copy. thats why it is necessary to stop before backup.

## Crontab

The crontab (cron table) command in Linux is a built-in utility used to schedule and automate tasks (known as cron jobs) to run periodically in the background. It relies on the cron daemon (crond), which runs continuously and checks the system's crontab files every minute to execute matching time-based commands.

#Rclone script run at at 7:10 pm  
10 19 * * * /home/aryan/Desktop/Scripts/gdrive_backup.sh >> /home/aryan/rclone_sync.log 2>&1  

The above script is the rclone - google drive script that runs automatically everyday at 7:10 pm. It also sends the logs to rclone_sync.log

## Rclone + Google Drive (Personal OAuth Client) (optional but best)  

When using rclone at start it gives user a default client id sharing a single application API with all other default rclone users.

why this may be bad sometime
1. it is used by millions of users which can possible hit quota exhaustion . which inturn i have to wait another day for backup . (it is very rare but can happen)
2. Many user are uploading can lead to slow transfer speed/bottleneck while uploading.

That is why i have set a custom client id (google cloud console)
I have setup personal OAuth client ID using google cloud console to prevent shared API limit.

Setup:
https://rclone.org/drive/#making-your-own-client-id (can refer to this for setup)

Now there is also one problem, the project is in testing phase so the client secret expires every 7 days or so . To Avoid this i have published this project 


