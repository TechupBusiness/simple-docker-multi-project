#!/bin/bash

source "system/lib.sh"

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo '
fi

cd "system/configuration"

SERVICE="$1"
shift;

$SUDO docker-compose -p "$SERVICE" -f "../$SERVICE/docker-compose.yml" $@
