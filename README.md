# ware_mc
This script automates setup of a Minecraft server. It was created and tested with Alma Linux, but should work with any RHEL distro.

NOTE: this script assumes you clone this repo to ~/Setup_Minecraft_Server. If you do not, it will fail to cpoy the correct files.

To execute it, clone the repo and mark all .sh files as executable.
Use `git clone https://github.com/Warecuber/Setup_Minecraft_Server.git && cd Setup_Minecraft_Server && chmod +x *.sh` to complete this all at once. 

Your server files are located in `/opt/minecraft/server`
If you make any changes, you will need to update the file permissions to avoid errors. Just use the following: 
`chown -R root:mc_server_admin /opt/minecraft/server && sudo chmod -R 770 /opt/minecraft/server` 
