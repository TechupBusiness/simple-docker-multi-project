#!/bin/bash

# runs weekly at 3am on sunday

# Repo params
O_PARAM=""
if [[ ! -z "$BACKUP_RESTIC_SSH_PASSWORD" ]]; then
    O_PARAM="-o sftp.command='sshpass -p $BACKUP_RESTIC_SSH_PASSWORD ssh $BACKUP_RESTIC_SSH_USER@$BACKUP_RESTIC_SSH_HOST -s sftp'"
fi

CMD_RESTIC="restic -r $BACKUP_RESTIC_REPO $O_PARAM forget --keep-daily $BACKUP_KEEP_DAILY --keep-weekly $BACKUP_KEEP_WEEKLY --keep-monthly $BACKUP_KEEP_MONTHLY --keep-yearly $BACKUP_KEEP_YEARLY --keep-last 1"
eval $CMD_RESTIC
