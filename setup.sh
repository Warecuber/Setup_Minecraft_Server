#!/bin/bash
# variables
$MC_USER_HOME_DIR="/home/minecraft"
$MC_SERVER_DIR="/opt/minecraft/server"
$JAVA_HOME="/opt/jdk-16.0.2"

# Install packages
sudo dnf update -y
sudo dnf install epel-release wget -y
sudo dnf install htop glances neofetch nano -y

# Open port 25565 on the firewall
sudo firewall-cmd --permanent --zone=public --add-port=25565/tcp
sudo firewall-cmd --reload

# Create new user and groups
sudo useradd minecraft
sudo groupadd mc_server_admin
sudo usermod -aG mc_server_admin minecraft
sudo usermod -aG mc_server_admin $USER #adds current user to Minecraft admin group

# Set Minecraft up as a service
mv minecraft.service /etc/systemd/system/minecraft.service
chmod +x /etc/systemd/system/minecraft.service

# Download and install JDK 16
curl -O https://download.java.net/java/GA/jdk16.0.2/d4a915d82b4c4fbb9bde534da945d746/7/GPL/openjdk-16.0.2_linux-x64_bin.tar.gz
sudo tar xvf openjdk-16.0.2_linux-x64_bin.tar.gz
sudo mv jdk-16.0.2 /opt/
rm openjdk-16.0.2_linux-x64_bin.tar.gz
# Add Java variables to admin bashrc
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo "export PATH=$PATH:$JAVA_HOME/bin" >> ~/.bashrc
# Add Java variables to Minecraft Service Account Bashrc
echo "export JAVA_HOME=/opt/jdk-16.0.2" >> $MC_USER_HOME_DIR/.bashrc
echo "export PATH=$PATH:$JAVA_HOME/bin" >> $MC_USER_HOME_DIR/.bashrc
. ~/.bashrc

# Setup server directories
sudo mkdir $MC_SERVER_DIR
sudo wget https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar -P $MC_SERVER_DIR

# Auto accept Minecraft EULA
echo "eula=true" > $MC_SERVER_DIR/eula.txt

# Move the start script 
mv ~/Setup_Minecraft_Server/start_minecraft_server.sh start_minecraft_server.sh
chmod +x start_mincraft_server.sh

# Fix file permissions
sudo chown -R root:mc_server_admin $MC_SERVER_DIR
sudo chmod 770 -R $MC_SERVER_DIR

# Update services and start MC server
sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service
