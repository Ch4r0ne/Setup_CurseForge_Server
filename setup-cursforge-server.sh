#!/bin/bash

# Define variables
minecraft_home="/home/minecraft"
server_files_dir="$minecraft_home/Server-Files"
backup_dir="$minecraft_home/backups"
minecraft_service_file="/etc/systemd/system/minecraft.service"
default_minecraft_download_url="https://edge.forgecdn.net/files/5225/986/Server-Files-0.1.13.zip"

# Read user input for Minecraft server download URL
read -p "Enter the Minecraft server download URL (default: $default_minecraft_download_url): " minecraft_download_url
minecraft_download_url=${minecraft_download_url:-$default_minecraft_download_url}

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
sudo mkdir -p "$minecraft_home"
sudo chown -R minecraft:minecraft "$minecraft_home"

# Set up Minecraft service
if [ ! -f "$minecraft_service_file" ]; then
    sudo bash -c "cat << EOF > $minecraft_service_file
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
WorkingDirectory=$server_files_dir
ExecStart=/usr/bin/screen -DmS minecraft $server_files_dir/startserver.sh
Restart=on-failure
ExecStop=/usr/bin/screen -S minecraft -X quit

[Install]
WantedBy=multi-user.target
EOF"
fi

sudo systemctl enable minecraft

# Create backup script
sudo -i -u minecraft bash << EOF
cat << 'EOL' > "$minecraft_home/backup.sh"
#!/bin/bash

BACKUP_DIR="$backup_dir"
SOURCE_DIR="$server_files_dir"
TIMESTAMP=\$(date +"%F")
BACKUP_FILE="\$BACKUP_DIR/minecraft_backup_\$TIMESTAMP.tar.gz"

mkdir -p \$BACKUP_DIR
tar -czvf \$BACKUP_FILE \$SOURCE_DIR
find \$BACKUP_DIR -type f -mtime +10 -name "*.tar.gz" -exec rm {} \;
EOL

chmod +x "$minecraft_home/backup.sh"
EOF

# Set up cron job for backup
(crontab -l 2>/dev/null; echo "0 2 * * * $minecraft_home/backup.sh") | crontab -

echo "The setup of the Minecraft server is complete, the server will now be installed as the next step."

# Download and install Minecraft server
sudo -i -u minecraft bash << EOF
cd $minecraft_home
wget "$minecraft_download_url" -O server_files.zip
unzip -o server_files.zip -d "$minecraft_home"
rm -f server_files.zip
cd "$server_files_dir"
echo "eula=true" > eula.txt
chmod +x startserver.sh
EOF

# Start Minecraft Server
sudo systemctl start minecraft
sudo -u minecraft screen -r minecraft
