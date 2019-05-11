#!/bin/bash

FILE_NAME="$1"

DATE=$(date +"%Y-%m-%d")
if [[ -z $FILE_NAME ]]; then
    FILE_NAME="export-$DATE"
fi

mysqldump --user=root --password=$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE | bzip2 > /backups/$FILE_NAME.sql.bz2

chown $USER_ID:$GROUP_ID /backups/$FILE_NAME.sql.bz2
