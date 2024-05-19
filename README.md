# Setup CurseForge Server

This is a skirpt to install and set up a Corsforge server on an Ubuntu distro with the desired downlaode URL of the respective modpacks

## Install

```sh
sudo apt install git -y
git clone https://TOKEN@github.com/Ch4r0ne/Setup_CurseForge_Server.git
cd Setup_CurseForge_Server
chmod +x Setup_CurseForge_Server.sh
sh setup-curseforge-server.sh
```

## Accessing the Screen Session

```sh
sudo -u minecraft screen -r minecraft
```

Exit Screen: Ctrl+a and d

## Remote Permission

```sh
sudo ufw allow ssh
```

Quick SSH Root Access Activation/Deactivation

```sh
# Enable SSH root access
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Disable SSH root access
sudo sed -i 's/^PermitRootLogin yes/#PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

## Check Status

1. Check the status of the Minecraft service:

```sh
sudo systemctl status minecraft
```

2. Stop the Minecraft service:

```sh
sudo systemctl stop minecraft
```

3. Start the Minecraft service:

```sh
sudo systemctl start minecraft
```

## Minecraft Service

Edit and configure the Minecraft service:

```sh
nano /etc/systemd/system/minecraft.service
```

```sh
[Unit]
Description=Minecraft Server
After=network.target
   
[Service]
User=minecraft
WorkingDirectory=/home/minecraft/Server-Files-0.1.13
ExecStart=/usr/bin/screen -DmS minecraft /home/minecraft/Server-Files-0.1.13/startserver.sh
Restart=on-failure
ExecStop=/usr/bin/screen -S minecraft -X quit
   
[Install]
WantedBy=multi-user.target
```
```sh
sudo systemctl daemon-reload
```

## Backup Script and Cron Job

Backup Script:

```sh
nano /home/minecraft/backup.sh
```
   
```sh
#!/bin/bash
   
BACKUP_DIR="/home/minecraft/backups"
SOURCE_DIR="/home/minecraft/Server-Files-0.1.13"
TIMESTAMP=$(date +"%F")
BACKUP_FILE="$BACKUP_DIR/minecraft_backup_$TIMESTAMP.tar.gz"
   
mkdir -p $BACKUP_DIR
tar -czvf $BACKUP_FILE $SOURCE_DIR
find $BACKUP_DIR -type f -mtime +10 -name "*.tar.gz" -exec rm {} \;
```

Schedule Backup with Cron Job:

```sh
crontab -e
```

Add the following line:

```sh
0 2 * * * /home/minecraft/backup.sh
```
