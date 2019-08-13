#!/bin/bash

source "system/lib.sh"

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo '
fi

echo "Stop all services (including core services as backup and reverse-proxy):"
echo "-----"
echo "Nothing will be deleted, you can start everything again by executing 'install.sh' and afterwards 'all-compose.sh up -d'"
echo "-----"
read -p "   Do you want to continue (y/n): " STOP_ALL

if [[ "$STOP_ALL" == "y" ]]; then
    echo "Stopping all projects"
    ./all-compose.sh stop

    echo "Stopping reverse-proxy..."
    pathProxy="system/reverse-proxy"
    $SUDO docker-compose -p "reverse-proxy" -f "../../$pathProxy/docker-compose.yml" stop

    echo "Stopping backup scheduler..."
    pathBackup="system/backup"
    $SUDO docker-compose -p "backup" -f "../../$pathBackup/docker-compose.yml" stop

    echo "DONE. Everything stopped. Please call './install.sh' for the core services and afterwards './all-compose.sh up -d' to start all projects again."
else
    echo "Canceled. Everything is still running."
fi
