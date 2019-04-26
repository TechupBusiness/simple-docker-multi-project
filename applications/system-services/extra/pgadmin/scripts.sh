#!/bin/bash

pgadminInstructions() {
    PROJECT="$1"
    PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    PGADMIN_WEB_HOST=$(configGetValueByFile PGADMIN_WEB_HOST "$PROJECT_ENV")

    echo "PG-ADMIN:"
    echo "- To setup the connection to your postgreSQL server: log into https://${PGADMIN_WEB_HOST}/ and add the postgreSQL server connection (its not added automatically)"
}