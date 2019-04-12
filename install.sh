#!/bin/bash

source "system/lib.sh"

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo '
fi

echo "Welcome! Checking/preparing environment..."

for SCRIPT in *.sh; do
    if [[ -x "$SCRIPT" ]]; then
        chmod +x "$SCRIPT"
        echo "Made $SCRIPT executable"
    fi
done

echo "Preparing reverse-proxy..."

path="system/reverse-proxy"
if [[ ! -f "$path/acme.json" ]]; then
    cp "$path/acme-template.json" "$path/acme.json"
    echo "Created acme.json."
else
    echo "OK - acme.json already existing."
fi

if [[ $(stat --format '%a' acme.json) != "600" ]]; then
    chmod 600 "$path/acme.json"
    echo "Set permission of acme.json to 600."
fi

editEnv "$path/template.env" "$path/.env" "interactive" "Reverse-Proxy settings"

echo "Starting reverse-proxy..."

cd "$path"
$SUDO docker-compose stop
$SUDO docker-compose up -d

echo "

--------------------
Run ./project.sh to add your first application. Or see README.md for more information how to add new services."
