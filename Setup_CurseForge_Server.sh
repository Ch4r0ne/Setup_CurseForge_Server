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

# Generate a random password for the minecraft user
MC_PASSWORD=$(openssl rand -base64 12)
echo "minecraft:$MC_PASSWORD" | sudo chpasswd
echo "Minecraft user password: $MC_PASSWORD"

# Create users for Minecraft
sudo adduser --gecos "" --disabled-password minecraft

# Create Minecraft directory and set permissions
sudo mkdir /minecraft
sudo chown -R minecraft:minecraft /minecraft

# Download and install Minecraft server - Important Change URL here!
sudo -i -u minecraft bash << EOF
cd /minecraft
wget https://edge.forgecdn.net/files/5225/986/Server-Files-0.1.13.zip
unzip Server-Files-0.1.13.zip
cd BM_Exosphere_1.1.2_server_pack
chmod +x start.sh
./start.sh
EOF

# Set up Minecraft service - Important Change Pfad here!
sudo bash -c 'cat << EOF > /etc/systemd/system/minecraft.service
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
WorkingDirectory=/minecraft/BM_Exosphere_1.1.2_server_pack
ExecStart=/usr/bin/screen -DmS minecraft /minecraft/BM_Exosphere_1.1.2_server_pack/startserver.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl enable minecraft
sudo systemctl start minecraft

# Create backup script
sudo -i -u minecraft bash << EOF
cat << 'EOL' > /minecraft/backup.sh
#!/bin/bash

BACKUP_DIR="/minecraft/backups"
SOURCE_DIR="/minecraft/BM_Exosphere_1.1.2_server_pack"
TIMESTAMP=\$(date +"%F")
BACKUP_FILE="\$BACKUP_DIR/minecraft_backup_\$TIMESTAMP.tar.gz"

mkdir -p \$BACKUP_DIR
tar -czvf \$BACKUP_FILE \$SOURCE_DIR
find \$BACKUP_DIR -type f -mtime +10 -name "*.tar.gz" -exec rm {} \;
EOL

chmod +x /minecraft/backup.sh
EOF

# Set up cron job for backup
(crontab -l 2>/dev/null; echo "0 2 * * * /minecraft/backup.sh") | crontab -

# Output next steps to user
echo "Minecraft server setup is complete. Use the following command to connect to the Minecraft server console:"
echo "sudo -i -u minecraft screen -r minecraft"
echo "Once connected, accept the EULA by editing eula.txt in the server directory."
