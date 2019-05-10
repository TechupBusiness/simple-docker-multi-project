#!/bin/bash

source "system/lib.sh"

PROJECT=""
stepChooseProjectName "$@"
shift;

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then SUDO='sudo'; fi

SERVICE="$1"
COMMAND="$2"
FILE_NAME="$3"

SERVICE_TYPE=""

if [[ -z $SERVICE ]]; then
    echo "Parameter 1 SERVICE NAME is missing"
    exit
else
    HAS_SERVICE=$(has_service "$SERVICE" "$PROJECT")
    if [[ "$HAS_SERVICE" = "0" ]]; then
        echo "Parameter 1 SERVICE NAME is wrong, no service '$SERVICE' found!"
        exit
    fi
fi

if [[ -z $COMMAND ]] || ([[ ! $COMMAND = "list-backups" ]] && [[ ! $COMMAND = "backup" ]] && [[ ! $COMMAND = "restore" ]]); then
    echo "Parameter 2 COMMAND ('list-backups', 'backup' or 'restore') is missing or wrong"
    exit
fi

servicePath=$(getServicePath "$SERVICE" "$PROJECT")
if [[ ! -f "$servicePath/scripts.sh" ]]; then
    echo "Service '$SERVICE' does not contain any actions (scripts.sh does not exist)!"
    exit
fi

if [[ $COMMAND = "list-backups" ]]; then
    runScript "$servicePath" "ListBackups" "$PROJECT" "$SERVICE"
else
    if [[ $COMMAND = "backup" ]]; then
        runScript "$servicePath" "Backup" "$PROJECT" "$SERVICE" "$FILE_NAME"
    elif [[ $COMMAND = "restore" ]]; then
        if [[ -z $FILE_NAME ]]; then
            echo "Parameter 3 FILE NAME is missing"
            exit
        else
            runScript "$servicePath" "Restore" "$PROJECT" "$SERVICE" "$FILE_NAME"
        fi
    fi
fi
