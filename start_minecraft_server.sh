#!/bin/bash

# Variables
JAVA_HOME="/opt/jdk-16.0.2/bin"
RAM_TO_USE="4G" #change this if you want to change the amount of RAM it uses

# Start script
$JAVA_HOME/java -Xmx$RAM_TO_USE -Xms$RAM_TO_USE -jar *server*.jar nogui
