#!/bin/bash

nodejsInstructions() {
    PROJECT="$1"
    ENV_FILE="applications/docker-data/$PROJECT/.env"

    WEB_ROOT_DOCKER_HOST=$(configGetValueByFile WEB_ROOT_DOCKER_HOST "$ENV_FILE")

    echo "NODEJS:"
    echo "- When the container is started, it will execute \"npm install\" in applications/instance-data/$PROJECT/$WEB_ROOT_DOCKER_HOST"
}