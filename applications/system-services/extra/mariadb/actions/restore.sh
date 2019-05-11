#!/bin/bash

FILE_NAME="$1"

if [[ -z "$FILE_NAME" ]]; then
    echo "Parameter 3 FILE_NAME is missing!"
    exit
fi

bunzip2 < /backups/$FILE_NAME.sql.bz2 | mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE
