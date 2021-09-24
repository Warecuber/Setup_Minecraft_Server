#/bin/bash
MC_SERVER_DIR=$1

sudo chown -R root:mc_server_admin $MC_SERVER_DIR
sudo chmod -R 770 $MC_SERVER_DIR
