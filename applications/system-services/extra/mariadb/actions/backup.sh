#!/bin/bash

FILE_NAME="$1"

DATE=$(date +"%d-%b-%Y")
if [[ -z $FILE_NAME ]]; then
    FILE_NAME="export-$DATE"
fi

mysqldump --user=root --password=$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE | bzip2 > /backups/$FILE_NAME.sql.bz2
