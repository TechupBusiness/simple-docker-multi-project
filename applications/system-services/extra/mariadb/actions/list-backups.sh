#!/bin/bash

for i in /backups/*.sql.bz2; do
    [[ -f "$i" ]]|| break

    backupName=$(basename "$i")
    echo "- ${backupName%.*}"
done
