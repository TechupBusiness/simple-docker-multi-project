#!/bin/bash

source "system/lib.sh"

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

pathServices="system/services"

# get all system services together when starting (exclude configuration folder)
SERVICES="-f $pathServices/docker-compose.yml"
for service in system/services/*; do
  if [[ -d "$service" ]]; then
    serviceName=$(basename "$service")
    if [[ "$serviceName" == "$1" ]] && [[ -z "$2" ]]; then
      editEnv "$pathServices/$serviceName/template.env" "system/configuration/.env" "interactive" "$serviceName"
      runScript "$pathServices/$serviceName" "Setup" "multiproject" "$serviceName"
      exit
    else
      runScript "$pathServices/$serviceName" "Build" "multiproject" "$serviceName"
      SERVICES="$SERVICES -f $pathServices/$serviceName/docker-compose.yml"
    fi
  fi
done

$SUDO docker-compose --project-directory "system/configuration" -p "multiproject" $SERVICES $@
