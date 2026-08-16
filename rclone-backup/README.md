Rclone 

Rclone is a free, open-source command-line program that lets you manage, sync, and back up files across local storage and over 70 cloud storage providers—such as Google Drive, Amazon S3, and Dropbox. Often called "rsync for cloud storage," it handles data transfers, encryption, and mounting remote drives.

Overview

I have setup rclone to sync my music and other personal folder to google cloud for backup purspose. It is fully cli based system and only runs when called.


I have created a backup-script.sh (using claude) to sync my folders to google cloud as a backup
see the backup-script 

backup-script.sh workflow in simple
Stops Navidrome (via Docker) → backs up its DB to Google Drive → restarts Navidrome → syncs a list of folders (Documents, Pictures, Music, etc.) to Drive with rclone sync → prints a success/fail summary. A trap ensures Navidrome restarts even if the script crashes.


rclone + Google Drive (Personal OAuth Client) (optional but best)

When using rclone at start it gives user a default client id sharing a single application API with all other default rclone users.

why this may be bad sometime
1. it is used by millions of users which can possible hit quota exhaustion . which inturn i have to wait another day for backup . (it is very rare but can happen)
2. Many user are uploading can lead to slow transfer speed/bottleneck while uploading.

Thats why i have set a custom client id (google cloud console)
I have setup personal OAuth client ID using google cloud console to prevent shared API limit.

Setup:
http://rclone.org/drive/#making-your-own-client-id (can refer to this for setup)

Now there is also one problem the project is in testing phase so the client secret expires every 7 days or so . To Avoid this i have published this project 


