#!/bin/bash

FILE_NAME="$1"

DATE=$(date +"%Y-%m-%d")
if [[ -z "$FILE_NAME" ]]; then
    FILE_NAME="export-$DATE"
fi

pg_dump -Fc -h "postgresql" -U "$POSTGRES_USER" "$POSTGRES_DB" -f "/backups/$FILE_NAME.pgcustom"

chown $USER_ID:$GROUP_ID "/backups/$FILE_NAME.pgcustom"
