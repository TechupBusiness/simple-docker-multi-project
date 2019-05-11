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

mariadbBackup() {
    PROJECT="$1"
    PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    BACKUP_PATH="applications/backups/$PROJECT/mariadb"

    FILE_NAME="$2"

    DATE=$(date +"%d-%b-%Y")
    if [[ -z $FILE_NAME ]]; then
        FILE_NAME="export-$DATE"
    fi

    MARIADB_ROOT_PASSWORD=$(configGetValueByFile MARIADB_ROOT_PASSWORD "$PROJECT_ENV")
    MARIADB_DATABASE=$(configGetValueByFile MARIADB_DATABASE "$PROJECT_ENV")

    ./compose.sh "$PROJECT" exec mariadb "/usr/bin/mysqldump --user=root --password=$MARIADB_ROOT_PASSWORD $MARIADB_DATABASE | bzip2 > $BACKUP_PATH/$FILE_NAME.sql.bz2"
}

mariadbRestore() {
    PROJECT="$1"
    PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    BACKUP_PATH="applications/backups/$PROJECT/mariadb"

    FILE_NAME="$2"

    MARIADB_ROOT_PASSWORD=$(configGetValueByFile MARIADB_ROOT_PASSWORD "$PROJECT_ENV")
    MARIADB_DATABASE=$(configGetValueByFile MARIADB_DATABASE "$PROJECT_ENV")

    bunzip2 < $BACKUP_PATH/$FILE_NAME.sql.bz2 | sudo docker exec -i $(./compose.sh $PROJECT ps -q mariadb) /usr/bin/mysql -uroot -p$MARIADB_ROOT_PASSWORD $MARIADB_DATABASE
}

mariadbBackupList() {
    PROJECT="$1"
    PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    BACKUP_PATH="applications/backups/$PROJECT/mariadb"

    for i in $BACKUP_PATH/*.sql.bz2; do
        [ -f "$i" ] || break

        backupName=$(basename "$i")
        echo "$backupName"
    done
}
