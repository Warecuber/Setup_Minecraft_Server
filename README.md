# ware_mc

This script automates setup of a Minecraft server. It was created and tested with Alma Linux and Ubuntu Server 20.10, but should work with any RHEL distro or Ubuntu.

NOTE: this script assumes you clone this repo to ~/Setup_Minecraft_Server. If you do not, it will fail to cpoy the correct files.

To execute it, clone the repo and mark all .sh files as executable.
Use `git clone https://github.com/Warecuber/Setup_Minecraft_Server.git && cd Setup_Minecraft_Server && chmod +x *.sh` to complete this all at once.

To start the setup, run `./setup.sh`

Your server files are located in `/opt/minecraft/server`

If you opted not to install the Vanilla 1.17.1 server, just place your desired server jar in /opt/minecraft/server (or the shared folder if you selected the option to install the SMB share). Make sure the jar file says server somewhere in the name or it won't work.

If you make any changes, you will need to update the file permissions to avoid errors. Just use the following:
`updateFilePermissions`
