#!/bin/bash

source "system/lib.sh"


##########################################
#
#               STEP HELPER
#
##########################################

PROJECT=""
MAIN_SERVICE=""
EXTRA_SERVICES=""

stepChooseGeneralEnv() {
    PROJECT_ENV="$1"
    PROJECT="$2"

    editEnv "applications/system-services/general/template.env" "$PROJECT_ENV" "interactive" "general" "general" "$PROJECT"

    MAIN_SERVICE=$(configGetValueByFile MAIN_SERVICE "$PROJECT_ENV")
    HAS_MAIN_SERVICE=$(has_service "$MAIN_SERVICE" "main")
    if [[ "$HAS_MAIN_SERVICE" = "0" ]]; then
        echo "

MAIN SERVICE \"$MAIN_SERVICE\" DOES NOT EXIST! TRY AGAIN."
        stepChooseGeneralEnv "$PROJECT_ENV"
    fi

    EXTRA_SERVICES=$(configGetValueByFile EXTRA_SERVICES "$PROJECT_ENV")
    for service in $EXTRA_SERVICES; do
        HAS_EXTRA_SERVICE=$(has_service "$service" "extra")
        if [[ "$HAS_EXTRA_SERVICE" = "0" ]]; then
            echo "

EXTRA SERVICE \"$service\" DOES NOT EXIST. PLEASE CHOOSE EXISTING SERVICES!"
            stepChooseGeneralEnv "$PROJECT_ENV"
        fi
    done
}


##########################################
#
#               APP FLOW
#
##########################################

stepChooseProjectName "$@"

PROJECT_ENV="applications/docker-data/$PROJECT/.env"

if [ ! -f "$PROJECT_ENV" ]; then
    touchFile $PROJECT_ENV
    echo "#+++++++++++++++++++++++++++++++++
# [HIDDEN] Main services to activate.
# Is set on project setup. Needs to be the same as the folder name of the project.
#---------------------------------
PROJECT_NAME=$PROJECT" >> $PROJECT_ENV
fi

stepChooseGeneralEnv "$PROJECT_ENV" "$PROJECT"

stepRunEnv "$PROJECT_ENV" "$PROJECT"

stepRunScripts "$PROJECT_ENV" "Setup" "$PROJECT"


echo "NOTES:"

stepRunScripts "$PROJECT_ENV" "Instructions" "$PROJECT"

echo "-------------"
echo "Enjoy!"
