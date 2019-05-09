#!/bin/bash

mariadbInstructions() {
    PROJECT="$1"
    PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    MARIADB_ROOT_PASSWORD=$(configGetValueByFile MARIADB_ROOT_PASSWORD "$PROJECT_ENV")
    MARIADB_DATABASE=$(configGetValueByFile MARIADB_DATABASE "$PROJECT_ENV")

    echo "MariaDB (MYSQL):"
    echo "- If existing production project: Put it in maintenance mode before moving (to avoid lost changes in database)"
    echo "- Start the database by running: ./compose.sh $PROJECT up -d mariadb"
    echo "- Import your database by running (replace {...}): cat {PATH/TO}/database.sql | sudo docker exec -i \$(./compose.sh $PROJECT ps -q mariadb) /usr/bin/mysql -uroot -p$MARIADB_ROOT_PASSWORD $MARIADB_DATABASE"
}