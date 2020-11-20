#!/bin/bash

echo "Available backups:"

for i in /backups/*.pgcustom; do
    [[ -f "$i" ]]|| break

    backupName=$(basename "$i")
    echo "${backupName:0:-9}"
done
