#!/bin/bash

nextcloudInstructions() {
    PROJECT="$1"
    ENV_FILE="applications/docker-data/$PROJECT/.env"

    WEB_HOST=$(configGetValueByFile WEB_HOST "$ENV_FILE")

    echo "NEXTCLOUD:"
    echo "- Go to https://$WEB_HOST/ and log in with your admin credentials"
}