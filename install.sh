#!/bin/bash

source "system/lib.sh"

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

echo "Welcome! Checking/preparing environment..."

for SCRIPT in *.sh; do
    chmod +x "$SCRIPT"
    echo "Made $SCRIPT executable"
done


echo "Preparing reverse-proxy..."

path="system/reverse-proxy"
if [[ ! -f "$path/acme.json" ]]; then
    cp "$path/acme-template.json" "$path/acme.json"
    chmod 600 "$path/acme.json"
    echo "Created acme.json and set permission to 600."
else
    echo "OK - acme.json already created."
fi

editEnv "$path/template.env" "$path/.env" "interactive" "Reverse-Proxy settings"

echo "Starting reverse-proxy..."

cd "$path"
$SUDO "docker-compose stop"
$SUDO "docker-compose up -d"

echo "

--------------------
Run ./project.sh to add your first application. Or see README.md for more information how to add new services."
