#!/bin/bash

mysqlInstructions() {
    PROJECT="$1"
    PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    MYSQL_ROOT_PASSWORD=$(configGetValueByFile MYSQL_ROOT_PASSWORD "$PROJECT_ENV")
    MYSQL_DATABASE=$(configGetValueByFile MYSQL_DATABASE "$PROJECT_ENV")

    echo "MYSQL:"
    echo "- If existing production project: Put it in maintenance mode before moving (to avoid lost changes in database)"
    echo "- Start the database by running: ./compose.sh $PROJECT up -d mysql"
    echo "- Import your database by running (replace {...}): cat {PATH/TO}/database.sql | sudo docker exec -i \$(./compose.sh $PROJECT ps -q mysql) /usr/bin/mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"
}