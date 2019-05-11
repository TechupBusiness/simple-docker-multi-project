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
shift; shift;

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

servicePath=$(getServicePath "$SERVICE" "$PROJECT")

if [[ -z $COMMAND ]] || [[ ! -f "$servicePath/actions/$COMMAND.sh" ]]; then
    echo "Parameter 2 COMMAND is missing or wrong. Available commands are: "
    for i in $servicePath/actions/*.sh; do
        [[ -f "$i" ]]|| break
        actionName=$(basename "$i")
        echo "- ${actionName%.*}"
    done
    exit
fi

./compose.sh "$PROJECT" exec "$SERVICE" /bin/bash /actions/$COMMAND.sh $@
