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

## Remote Permission
```sh
sudo ufw allow ssh
```

Quick SSH Root Access Activation/Deactivation

To quickly enable SSH root access and deactivate it afterward, consider the following command:
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

