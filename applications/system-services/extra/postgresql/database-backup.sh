#!/bin/sh

# Inspired by https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux

###############################
# Perform backups
###############################

BACKUP_DIR="/backups"

export PGPASSWORD="$POSTGRES_PASSWORD"

perform_backups()
{
	DATE_PATH_PART=$1
  TARGET="$BACKUP_DIR/$POSTGRES_DB-$DATE_PATH_PART"
  pg_dump -Fc -h "postgresql" -U "$POSTGRES_USER" "$POSTGRES_DB" -f "$TARGET.pgcustom"
}


if [ "$POSTGRES_BACKUP_ROTATION" = "false" ]; then
  perform_backups "last"
  exit 0
fi

###############################
#### BACKUP WITH ROTATION #####
###############################

# MONTHLY BACKUPS
DAY_OF_MONTH=$(date +%d)
if [ "$DAY_OF_MONTH" -eq 1 ]; then
	# Delete all expired monthly directories
	find $BACKUP_DIR -maxdepth 1 -name "*-monthly*" -exec rm -rf '{}' ';'
	perform_backups "$(date +\%Y-\%m-\%d)-monthly"
	exit 0
fi

# WEEKLY BACKUPS
DAY_OF_WEEK=$(date +%u) #1-7 (Monday-Sunday)
EXPIRED_DAYS=$(expr $((($POSTGRES_BACKUP_WEEKS_TO_KEEP * 7) + 1)))
if [ "$DAY_OF_WEEK" = "$POSTGRES_BACKUP_DAY_OF_WEEK_TO_KEEP" ]; then
	# Delete all expired weekly directories
	find $BACKUP_DIR -maxdepth 1 -mtime +"$EXPIRED_DAYS" -name "*-weekly*" -exec rm -rf '{}' ';'
	perform_backups "$(date +\%Y-\%m-\%d)-weekly"
	exit 0
fi

# DAILY BACKUPS
find $BACKUP_DIR -maxdepth 1 -mtime +"$POSTGRES_BACKUP_DAYS_TO_KEEP" -name "*-daily*" -exec rm -rf '{}' ';'
perform_backups "$(date +\%Y-\%m-\%d)-daily"
