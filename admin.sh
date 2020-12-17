#!/bin/bash

source "system/lib.sh"

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo '
fi

cd "system/configuration"

# get all system services together when starting (exclude configuration folder)
SERVICES="-f \"../docker-compose.yml\""
for service in ../services/*; do
    if [[ -d "$service" ]]; then
      serviceName=$(basename "$service")
      if [[ "$serviceName" == "$1" ]] && [[ -z "$2" ]]; then
        editEnv "../services/$serviceName/template.env" ".env" "interactive" "$serviceName"
        runScript "../services/$serviceName" "Setup" "multiproject-system" "$serviceName"
        exit
      fi
      SERVICES="$SERVICES -f \"../$serviceName/docker-compose.yml\""
    fi
done

$SUDO docker-compose -p "multiproject-system" $SERVICES $@
