#!/bin/bash

echo "Available backups:"

for i in /backups/*.sql.bz2; do
    [[ -f "$i" ]]|| break

    backupName=$(basename "$i")
    echo "${backupName:0:-8}"
done
