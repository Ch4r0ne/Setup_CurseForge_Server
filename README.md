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

# Update Process

This guide outlines the process for updating the Minecraft server while creating a backup of the current world files. Please follow the steps below:

## Pre-Update Steps

1. Check the status of the Minecraft service:
    ```bash
    sudo systemctl status minecraft
    ```

2. Stop the Minecraft service:
    ```bash
    sudo systemctl stop minecraft
    ```

## Update Procedure

1. Navigate to the Minecraft directory:
    ```bash
    cd /home/minecraft
    ```

2. Download the latest server files from the new URL:
    ```bash
    wget NEW_URL
    ```

3. Unzip the downloaded server files:
    ```bash
    unzip ServerFiles.zip
    ```

4. Navigate into the newly extracted server directory:
    ```bash
    cd ServerFiles
    ```

5. Change the permissions of the server startup script:
    ```bash
    chmod +x startserver.sh
    ```

6. **Edit Systemctl Service File:**

    After updating the server files, it's crucial to reflect the changes in the systemctl service file (`minecraft.service`). Follow these steps to edit the service file:

    - Open the `minecraft.service` file for editing:
        ```bash
        sudo nano /etc/systemd/system/minecraft.service
        ```

    - In the `[Service]` section, update the `WorkingDirectory` and `ExecStart` paths to point to the new server directory. For example:
        ```ini
        [Service]
        User=minecraft
        WorkingDirectory=/home/minecraft/ServerFiles  # Update this path
        ExecStart=/usr/bin/screen -DmS minecraft /home/minecraft/ServerFiles/startserver.sh  # Update this path
        Restart=on-failure
        ExecStop=/usr/bin/screen -S minecraft -X quit
        ```

    - Save the changes and exit the editor.

7. **Restart Minecraft Service:**

    After editing the service file, restart the Minecraft service to apply the changes:
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl start minecraft
    ```

## Verification

After restarting the Minecraft service, you can verify if everything is working as expected:

- Check the status of the Minecraft service:
    ```bash
    sudo systemctl status minecraft
    ```

- Connect to the Minecraft server console to ensure proper functionality:
    ```bash
    sudo -u minecraft screen -r minecraft
    ```

Make sure to follow these steps carefully to ensure a successful update and verification process.


