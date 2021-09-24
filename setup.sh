#!/bin/bash

# variables
MC_USER_HOME_DIR="/home/minecraft"
MC_SERVER_DIR="/opt/minecraft/server"
JAVA_HOME="/opt/jdk-16.0.2"
UNAME=$(uname)

#############
# Functions #
#############

# Install packages
installPackagesForCentOS() {
  sudo dnf update -y
  sudo dnf install epel-release wget -y
  sudo dnf install htop glances neofetch nano tmux -y
}
installPackagesForOracleLinux() {
  sudo dnf update -y
  sudo dnf install oracle-epel-release-el8 wget -y
  sudo dnf install htop glances neofetch nano tmux -y
}
installPackagesForUbuntu() {
  sudo apt-get update -y
  sudo apt-get install wget htop glances neofetch nano tmux -y
}

# Set firewall rules
setFirewallRulesRHEL() {
  sudo firewall-cmd --permanent --zone=public --add-port=25565/tcp
  read -n1 -p "Do you want to open port 22 for SSH? y/n: " openSSH
  if [[ "$openSSH" == "y" || "$openSSH" == "Y" ]]; then
    sudo firewall-cmd --permanent --zone=public --add-port=22/tcp
  fi
  sudo firewall-cmd --reload
}
setFirewallRulesUbuntu() {
  sudo ufw allow 25565
  read -n1 -p "Do you want to open port 22 for SSH? y/n: " openSSH
  if [[ "$openSSH" == "y" || "$openSSH" == "Y" ]]; then
    sudo ufw allow 22
  fi
  sudo ufw enable
}

# Create MC User
createMCUserAndGroups() {
  CHECK_MC_SERVICE_ACCOUNT_EXISTS=$(id -u minecraft)
  if [[ "$CHECK_MC_SERVICE_ACCOUNT_EXISTS" == "" ]]; then
    echo "Minecraft user does not exist. Creating..."
    sudo useradd minecraft
    sudo groupadd mc_server_admin
    sudo usermod -aG mc_server_admin minecraft
    sudo usermod -aG mc_server_admin $USER #adds current user to Minecraft admin group
  else
    CHECK_MC_SERVICE_ACCOUNT_GROUPS=$(groups minecraft)
    if [[ ! "$CHECK_MC_SERVICE_ACCOUNT_GROUPS" == *"mc_server_admin"* ]]; then
      echo "Minecraft user exists, but is missing te right groups. Updating...."
      sudo groupadd mc_server_admin
      sudo usermod -aG mc_server_admin minecraft
      sudo usermod -aG mc_server_admin $USER #adds current user to Minecraft admin group
    else
      echo "Minecraft Service account already exists with groups"
    fi
  fi
}

# Install Java
installJava() {
  WHERE_IS_JAVA=$(whereis java)
  if [[ "$WHERE_IS_JAVA" == *"/opt/jdk"* ]]; then
    echo "Java already installed"
  else
    curl -O https://download.java.net/java/GA/jdk16.0.2/d4a915d82b4c4fbb9bde534da945d746/7/GPL/openjdk-16.0.2_linux-x64_bin.tar.gz
    sudo tar xvf openjdk-16.0.2_linux-x64_bin.tar.gz
    sudo mv jdk-16.0.2 /opt/
    rm openjdk-16.0.2_linux-x64_bin.tar.gz
    # Add Java variables to admin bashrc
    echo "export JAVA_HOME=$JAVA_HOME" >>~/.bashrc
    echo "export PATH=$PATH:$JAVA_HOME/bin" >>~/.bashrc
    # Add Java variables to Minecraft Service Account Bashrc
    echo "export JAVA_HOME=/opt/jdk-16.0.2" >>$MC_USER_HOME_DIR/.bashrc
    echo "export PATH=$PATH:$JAVA_HOME/bin" >>$MC_USER_HOME_DIR/.bashrc
    . ~/.bashrc
  fi
}

# Create and configure the MC server direcotyr
setupMCServerDirectory() {
  if [[ ! -d "$MC_SERVER_DIR" ]]; then
    sudo mkdir /opt/minecraft
    sudo mkdir $MC_SERVER_DIR
    sudo mv ~/Setup_Minecraft_Server/start_minecraft_server.sh $MC_SERVER_DIR/start_minecraft_server.sh
    chmod +x $MC_SERVER_DIR/start_minecraft_server.sh
  else
    echo "$MC_SERVER_DIR already exists"
  fi
}

# Install MC Server 1.17.1
installMCServer() {
  read -n1 -p "Do you want to install a vanilla Minecraft 1.17.1 server now? y/n: " installServer
  if [[ "$installServer" == "y" || "$installServer" == "Y" ]]; then
    echo "Installing MC Server 1.17.1"
    sudo wget https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar -P $MC_SERVER_DIR
    echo "eula=true" >eula.txt
    sudo mv eula.txt $MC_SERVER_DIR/eula.txt
  else
    echo "Not installing MC server 1.17.1"
  fi
  sudo chown -R root:mc_server_admin $MC_SERVER_DIR
  sudo chmod 770 -R $MC_SERVER_DIR
}

# Install and start MC Service
installAndStartMCService() {
  echo "Installing service..."
  sudo mv minecraft.service /etc/systemd/system/minecraft.service
  sudo chmod +x /etc/systemd/system/minecraft.service
  sudo systemctl daemon-reload
  sudo systemctl enable minecraft.service
  sudo systemctl start minecraft.service
}

determineIfServiceIsDesired() {
  read -n1 -p "Do you want to add a Minecraft service? This allows you to start or stop the server with systemctl y/n: " addService
  if [[ "$addService" == "y" || "$addService" == "Y" ]]; then
    installAndStartMCService
  fi
}

##############################################
# Logic to determine which functions to call #
##############################################

if [[ "$UNAME" == "Darwin" ]]; then
  echo "You are on a Mac. This process is not yet supported on MacOS"
else
  ISSUE_FILE=$(cat /etc/issue)
  if [[ "$ISSUE_FILE" == *"Ubuntu"* ]]; then
    echo "You are on Ubuntu"
    installPackagesForUbuntu
    setFirewallRulesUbuntu
    createMCUserAndGroups
    installJava
    setupMCServerDirectory
    installMCServer
    determineIfServiceIsDesired
  else
    RHEL_VERSION=$(hostnamectl | grep "Operating System")
    if [[ "$RHEL_VERSION" == *"Oracle"* ]]; then
      echo "You are on Oracle Linux"
      installPackagesForOracleLinux
      setFirewallRulesRHEL
      createMCUserAndGroups
      installJava
      setupMCServerDirectory
      installMCServer
      determineIfServiceIsDesired
    elif [["$RHEL_VERSION" == *"CentOS"*]]; then
      echo "You are on CentOS"
      installPackagesForCentOS
      setFirewallRulesRHEL
      createMCUserAndGroups
      installJava
      setupMCServerDirectory
      installMCServer
      determineIfServiceIsDesired
    elif [["$RHEL_VERSION" == *"Alma"*]]; then
      echo "You are on Alma Linux!"
      installPackagesForCentOS
      setFirewallRulesRHEL
      createMCUserAndGroups
      installJava
      setupMCServerDirectory
      installMCServer
      determineIfServiceIsDesired
    else
      echo "Unfortunately, this script is not setup for $RHEL_VERSION"
    fi
  fi
fi
