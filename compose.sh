#!/bin/bash

source "system/lib.sh"

PROJECT=""
stepChooseProjectName "$@"
shift;

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then SUDO='sudo'; fi

ENV_FILE="applications/docker-data/$PROJECT/.env"

if [ -f "$ENV_FILE" ]; then

    if [ ! -z "$LAMP_TMP_RUNNING" ]; then
        echo "There is already compose.sh running for project $LAMP_TMP_RUNNING. Please wait until it is finished and try again."
        exit
    fi
    export LAMP_TMP_RUNNING="$PROJECT"

    # Check for modules installed
    MAIN_SERVICE=$(configGetValueByFile MAIN_SERVICE "$ENV_FILE")
    EXTRA_SERVICES=$(configGetValueByFile EXTRA_SERVICES "$ENV_FILE")
    HAS_MAIN_SERVICE=$(has_service "$MAIN_SERVICE" "main")
    if [[ "$HAS_MAIN_SERVICE" = "0" ]]; then
        echo "MAIN SERVICE \"$MAIN_SERVICE\" DOES NOT EXIST!"
        exit
    fi
    EXTRA_SERVICES=$(configGetValueByFile EXTRA_SERVICES "$ENV_FILE")
    for service in $EXTRA_SERVICES; do
        HAS_EXTRA_SERVICE=$(has_service "$service" "extra")
        if [[ "$HAS_EXTRA_SERVICE" = "0" ]]; then
            echo "EXTRA SERVICE \"$service\" DOES NOT EXIST."
            exit
        fi
    done


    STATUS=$(configGetValueByFile STATUS "$ENV_FILE")
    if [ "$STATUS" != "enabled" ]; then
        echo "STATUS of $PROJECT is not enabled - skip processing"
        exit
    fi

    PROJECT_NAME=$(configGetValueByFile PROJECT_NAME "$ENV_FILE")
    if [ "$PROJECT_NAME" != "$PROJECT" ]; then
        echo "Project name in .env ($PROJECT_NAME) differs from path folder ($PROJECT). Please fix it and try again."
        exit
    fi

    # Add base composer file & run scripts
    COMPOSER_FILE_OPTIONS="-f ../../system-services/general/docker-compose.yml"

    # Add main service files & run scripts
    MAIN_SERVICE_YAMLS=$(getDockerComposeYamls $PROJECT "main" $MAIN_SERVICE)
    COMPOSER_FILE_OPTIONS="$COMPOSER_FILE_OPTIONS$MAIN_SERVICE_YAMLS"

    for extraService in $EXTRA_SERVICES; do
        EXTRA_SERVICE_YAMLS=$(getDockerComposeYamls $PROJECT "extra" $extraService)
        COMPOSER_FILE_OPTIONS="$COMPOSER_FILE_OPTIONS$EXTRA_SERVICE_YAMLS"
    done

    stepRunScripts "$ENV_FILE" "Build" "$PROJECT"

    # Go into folder to use the present .env file
    cd "applications/docker-data/$PROJECT"
    #$SUDO docker-compose -p "$PROJECT" --env-file "$ENV_FILE" $COMPOSER_FILE_OPTIONS "$@"
    $SUDO docker-compose -p "$PROJECT" $COMPOSER_FILE_OPTIONS "$@"

    # Clear global environment variable
    unset LAMP_TMP_RUNNING
else
    echo "[ERROR] Can't find $ENV_FILE"
fi
