# Setup_CurseForge_Server

This is a skirpt to install and set up a Corsforge server on an Ubuntu distro with the desired downlaode URL of the respective modpacks

## Install

```sh
sudo apt install git -y
git clone https://TOKEN@github.com/Ch4r0ne/Setup_CurseForge_Server.git
cd Setup_CurseForge_Server
chmod +x Setup_CurseForge_Server.sh
sh setup-curseforge-server.sh
```

## Accessing the screen session

To access the current screen session:

```sh
sudo -u minecraft screen -r minecraft
```

Exit Screen Ctrl+a and d

## Add User and Permission for SSH

```sh
sudo ufw allow ssh
sudo adduser --gecos "" winscp
sudo chown -R winscp:winscp /home/minecraft
```




