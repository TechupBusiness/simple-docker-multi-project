#!/bin/bash

if [[ ! -z "$@" ]]; then
    exec "$@"
fi

if [[ ! -d /root/.ssh ]]; then
    mkdir /root/.ssh
fi

if [[ ! -f /root/.ssh/known_hosts ]]; then
    echo "" > /root/.ssh/known_hosts
fi

HOST_EXISTS=$(ssh-keygen -H -F $BACKUP_RESTIC_SSH_HOST)
if [[ -z $HOST_EXISTS ]]; then
    ssh-keyscan $BACKUP_RESTIC_SSH_HOST >> ~/.ssh/known_hosts
fi

O_PARAM=""
if [[ ! -z "$BACKUP_RESTIC_SSH_PASSWORD" ]]; then
    O_PARAM="-o sftp.command='sshpass -p $BACKUP_RESTIC_SSH_PASSWORD ssh $BACKUP_RESTIC_SSH_USER@$BACKUP_RESTIC_SSH_HOST -s sftp'"
fi

CMD_RESTIC="restic -r $BACKUP_RESTIC_REPO $O_PARAM init"
eval $CMD_RESTIC

crond -f -d 8
