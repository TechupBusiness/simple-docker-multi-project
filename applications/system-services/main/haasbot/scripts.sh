#!/bin/bash

haasbotSetup() {
    PROJECT="$1"
    mkdir -p "applications/instance-data/$PROJECT/haas-install"
}

haasbotInstructions() {
    PROJECT="$1"
    ENV_FILE="applications/docker-data/$PROJECT/.env"

  HAASBOT_WEBSOCKET_DOMAIN="$(configGetValueByFile HAASBOT_WEBSOCKET_DOMAIN "$ENV_FILE")"
  WEB_HOST="$(configGetValueByFile WEB_HOST "$ENV_FILE")"

    echo "HAASBOT:"
    echo "- Place the linux32.tar.gz file in 'applications/instance-data/$PROJECT/haas-install' BEFORE you start the project"
    echo "  You will find it (in a AllPlatforms.zip) in your customer area to download."
    echo "- Make sure that all domains point to your server ($WEB_HOST and $HAASBOT_WEBSOCKET_DOMAIN)"
}