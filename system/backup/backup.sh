#!/bin/bash

# runs daily at 2am

# Variables
PROJECT_FOLDER_PARENTS="applications/backups applications/cronjobs applications/docker-data applications/instance-data applications/logs"
BACKUP_FOLDERS=system/configuration

# Repo params
O_PARAM=""
if [[ ! -z "$BACKUP_RESTIC_SSH_PASSWORD" ]]; then
    O_PARAM="-o sftp.command='sshpass -p $BACKUP_RESTIC_SSH_PASSWORD ssh $BACKUP_RESTIC_SSH_USER@$BACKUP_RESTIC_SSH_HOST -s sftp'"
fi

if [[ ! -z "$BACKUP_ADDITIONAL_PROJECT_FOLDER" ]]; then
    PROJECT_FOLDER_PARENTS="$PROJECT_FOLDER_PARENTS $BACKUP_ADDITIONAL_PROJECT_FOLDER"
fi

if [[ ! -z "$BACKUP_ADDITIONAL_FOLDER" ]]; then
    BACKUP_FOLDERS="$BACKUP_FOLDERS $BACKUP_ADDITIONAL_FOLDER"
fi

# Iterate all projects
PATH_ROOT=/docker-projects
PATH_PROJECT_FOLDER="$PATH_ROOT/applications/docker-data"

# Write and tag project specific folder
# Tag for each project + tags according to folder type (backup, logs, instance-data, docker-data)

for PATH_PROJECT in $PATH_PROJECT_FOLDER/*; do
    PROJECT=$(basename "$PATH_PROJECT")
    for PROJECT_FOLDER_PARENT in $PROJECT_FOLDER_PARENTS; do
        PATH_PROJECT_FOLDER="$PATH_ROOT/$PROJECT_FOLDER_PARENT/$PROJECT"
        if [[ -d "$PATH_PROJECT_FOLDER" ]]; then
            CMD_RESTIC="restic -r $BACKUP_RESTIC_REPO $O_PARAM backup --tag 'project:$PROJECT' --tag 'folder:$PROJECT_FOLDER_PARENT' $PATH_PROJECT_FOLDER"
            eval $CMD_RESTIC
        fi
    done
done

for BACKUP_FOLDER in $BACKUP_FOLDERS; do
    CMD_RESTIC="restic -r $BACKUP_RESTIC_REPO $O_PARAM backup --tag 'folder:$BACKUP_FOLDER' $PATH_ROOT/$BACKUP_FOLDER"
    eval $CMD_RESTIC
done