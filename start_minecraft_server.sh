#!/bin/bash

# Variables
JAVA_HOME="/opt/jdk-16.0.2/bin"
MC_SERVER_DIR = /opt/minecraft/server

RAM_TO_USE="4G" #change this if you want to change the amount of RAM it uses

# Start script
$JAVA_HOME/java -Xmx$RAM_TO_USE -Xms$RAM_TO_USE -jar $MC_SERVER_DIR/server.jar nogui
