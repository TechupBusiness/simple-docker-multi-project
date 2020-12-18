#!/bin/bash
# runs weekly at 3am on sunday

# Text colors
TEXT_BG_BLUE="\e[44m"
TEXT_BG_GREEN="\e[42m"
TEXT_BG_RED="\e[41m"
TEXT_BG_DEFAULT="\e[49m"
TEXT_WHITE="\e[97m"
TEXT_GREEN="\e[92m"
TEXT_RED="\e[91m"
TEXT_BLUE="\e[34m"
TEXT_BOLD="\e[1m"
TEXT_CLEAR="\e[0m"

CONFIG="forget --keep-daily $BACKUP_KEEP_DAILY --keep-weekly $BACKUP_KEEP_WEEKLY --keep-monthly $BACKUP_KEEP_MONTHLY --keep-yearly $BACKUP_KEEP_YEARLY --keep-last 1"

# Outputs date to log
echo -e "${TEXT_BG_BLUE}${TEXT_BOLD}${TEXT_WHITE}CLEANUP STARTED $(date):${TEXT_CLEAR}
${TEXT_BLUE}CONFIGURATION:${TEXT_CLEAR} $CONFIG"

# Repo params
O_PARAM=""
if [[ ! -z "$BACKUP_RESTIC_SSH_PASSWORD" ]]; then
    O_PARAM="-o sftp.command='sshpass -p $BACKUP_RESTIC_SSH_PASSWORD ssh $BACKUP_RESTIC_SSH_USER@$BACKUP_RESTIC_SSH_HOST -s sftp'"
fi

CMD_RESTIC="restic -r $BACKUP_RESTIC_REPO $O_PARAM $CONFIG"
eval $CMD_RESTIC
