#!/bin/bash

FILE_NAME="$1"

if [[ -z "$FILE_NAME" ]]; then
    echo "Parameter 3 FILE_NAME is missing!"
    exit
fi

pg_restore -j 8 -U "$POSTGRES_USER" -d "$POSTGRES_DB" "/backups/$FILE_NAME.pgcustom"
