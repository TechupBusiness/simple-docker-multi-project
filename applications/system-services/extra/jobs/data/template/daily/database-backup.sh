#!/bin/sh


if [ -z "$MYSQL_ROOT_PASSWORD" ]; then

    #Installed via Dockerfile; which mysqldump >/dev/null || (apk update && apk add --no-cache mariadb-client)

    # Other options
    BACKUP_PATH="/home/backup/mysql"
    DATE=$(date +"%d-%b-%Y")

    if [ ! -d $BACKUP_PATH ]; then
        mkdir -p $BACKUP_PATH
    fi

    # Dump database into SQL file
    mysqldump --user=root --password=$MYSQL_ROOT_PASSWORD --host=$MYSQL_HOST $MYSQL_DATABASE | bzip2 > $BACKUP_PATH/$DATE.sql.bz

    # Restore via bunzip2 < $DATE.sql.bz2 | mysql -u user -p

    # Delete files older than 30 days
    find $BACKUP_PATH/* -mtime +$KEEP_BACKUP_DAYS -exec rm {} \;

fi
