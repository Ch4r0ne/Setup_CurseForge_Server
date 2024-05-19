#!/bin/bash

# Update and installation of the required packages
sudo apt update -y
sudo apt upgrade -y
sudo apt install openjdk-17-jdk wget unzip screen ufw -y

# Firewall configuration
sudo ufw allow 25565/tcp
sudo ufw allow 25565/udp
sudo ufw enable
sudo ufw reload

# Create user for Minecraft without password
sudo adduser --gecos "" --disabled-password minecraft

# Create Minecraft directory and set permissions
sudo mkdir /home/minecraft
sudo chown -R minecraft:minecraft /home/minecraft

# Set up Minecraft service
if [ ! -f "/etc/systemd/system/minecraft.service" ]; then
    sudo bash -c 'cat << EOF > /etc/systemd/system/minecraft.service
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
EOF'
fi

sudo systemctl enable minecraft

# Create backup script
sudo -i -u minecraft bash << EOF
cat << 'EOL' > /home/minecraft/backup.sh
#!/bin/bash

BACKUP_DIR="/home/minecraft/backups"
SOURCE_DIR="/home/minecraft/Server-Files-0.1.13"
TIMESTAMP=\$(date +"%F")
BACKUP_FILE="\$BACKUP_DIR/minecraft_backup_\$TIMESTAMP.tar.gz"

mkdir -p \$BACKUP_DIR
tar -czvf \$BACKUP_FILE \$SOURCE_DIR
find \$BACKUP_DIR -type f -mtime +10 -name "*.tar.gz" -exec rm {} \;
EOL

chmod +x /home/minecraft/backup.sh
EOF

# Set up cron job for backup
(crontab -l 2>/dev/null; echo "0 2 * * * /home/minecraft/backup.sh") | crontab -

echo "The setup of the Minecraft server is complete, the server will now be installed as the next step."

# Download and install Minecraft server
sudo -i -u minecraft bash << EOF
cd /home/minecraft
wget https://edge.forgecdn.net/files/5225/986/Server-Files-0.1.13.zip
unzip -o Server-Files-0.1.13.zip
rm -f Server-Files-0.1.13.zip
cd Server-Files-0.1.13
echo "eula=true" > eula.txt
chmod +x startserver.sh
EOF

# Start Minecraft Server
sudo systemctl start minecraft
sudo -u minecraft screen -r minecraft
