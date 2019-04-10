#!/bin/bash

#Setup() {
#
#}
#
#Build() {
#
#}

generalInstructions() {
    PROJECT="$1"
    ENV_FILE="applications/docker-data/$PROJECT/.env"

    WEB_HOST=$(configGetValueByFile WEB_HOST "$ENV_FILE")

    echo "GENERAL:"
    echo "- Read README.md"
    echo "- Point your domain $WEB_HOST to this server (DNS)"
    echo "- Wait for TTL expiration to finish the DNS change (otherwise your free SSL certificate will not be valid), then run: ./compose.sh $PROJECT up -d"
}

generalFieldDescriptions() {
    FIELD="$2"
    PROJECT="$1"

#    echo "SCRIPT-TEST $PROJECT $FIELD"
}