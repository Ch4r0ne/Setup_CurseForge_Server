#!/bin/bash

# Funktion zur Fehlerbehandlung
function handle_error {
    echo "Fehler in Zeile $1"
    exit 1
}

# Fehlerbehandlung aktivieren
trap 'handle_error $LINENO' ERR

# Parameter für die Download-URL und Server-Dateinamen
DOWNLOAD_URL="https://edge.forgecdn.net/files/5225/986/Server-Files-0.1.13.zip"
SERVER_DIR_NAME="Server-Files-0.1.13"

# Update und Installation der benötigten Pakete
sudo apt update -y
sudo apt upgrade -y
sudo apt install openjdk-17-jdk wget unzip screen ufw -y

# Firewall Konfiguration
sudo ufw allow 25565/tcp
sudo ufw allow 25565/udp
sudo ufw --force enable
sudo ufw reload

# Benutzer für Minecraft ohne Passwort erstellen
sudo adduser --gecos "" --disabled-password minecraft

# Minecraft-Verzeichnis erstellen und Berechtigungen setzen
sudo mkdir -p /home/minecraft
sudo chown -R minecraft:minecraft /home/minecraft

# Minecraft-Dienst einrichten
if [ ! -f "/etc/systemd/system/minecraft.service" ]; then
    sudo bash -c 'cat << EOF > /etc/systemd/system/minecraft.service
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
WorkingDirectory=/home/minecraft/'"$SERVER_DIR_NAME"'
ExecStart=/usr/bin/screen -DmS minecraft /home/minecraft/'"$SERVER_DIR_NAME"'/startserver.sh
Restart=on-failure
ExecStop=/usr/bin/screen -S minecraft -X quit

[Install]
WantedBy=multi-user.target
EOF'
fi

sudo systemctl enable minecraft

# Backup-Skript erstellen
sudo -u minecraft bash << EOF
cat << 'EOL' > /home/minecraft/backup.sh
#!/bin/bash

BACKUP_DIR="/home/minecraft/backups"
SOURCE_DIR="/home/minecraft/'"$SERVER_DIR_NAME"'"
TIMESTAMP=\$(date +"%F")
BACKUP_FILE="\$BACKUP_DIR/minecraft_backup_\$TIMESTAMP.tar.gz"

mkdir -p \$BACKUP_DIR
tar -czvf \$BACKUP_FILE \$SOURCE_DIR
find \$BACKUP_DIR -type f -mtime +10 -name "*.tar.gz" -exec rm {} \;
EOL

chmod +x /home/minecraft/backup.sh
EOF

# Cron-Job für Backup einrichten
(crontab -l 2>/dev/null; echo "0 2 * * * /home/minecraft/backup.sh") | crontab -

echo "Die Einrichtung des Minecraft-Servers ist abgeschlossen. Der Server wird jetzt installiert."

# Minecraft-Server herunterladen und installieren
sudo -u minecraft bash << EOF
cd /home/minecraft
wget -O server.zip "$DOWNLOAD_URL"
unzip -o server.zip
rm -f server.zip
cd "$SERVER_DIR_NAME"
echo "eula=true" > eula.txt
chmod +x startserver.sh
EOF

# Minecraft-Server starten
sudo systemctl start minecraft
sudo -u minecraft screen -r minecraft
