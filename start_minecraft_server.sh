#!/bin/bash

# Variables
JAVA_HOME="/opt/jdk-16.0.2/bin"

# Start script
$JAVA_HOME/java -Xmx4G -Xms4G -jar server.jar nogui
