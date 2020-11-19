#!/bin/bash

#################################################
# This script backup mysql, mariadb, postgres
#################################################
#
# Sources that were used for this script (thanks!!):
# - https://wiki.postgresql.org/wiki/Automated_Backup_on_Linux
#
# Search for "[ADD-NEW-DATABASE-HERE]" in this
# script to find the sections where you need
# to handle a new database
#
#################################################

###############################
# Check if we need database
# backups
###############################

declare -a DO_DATABASE_BACKUP_LIST

# BEGIN [ADD-NEW-DATABASE-HERE]
if [[ -n $POSTGRES_PASSWORD ]] && [[ -n $JOBS_BACKUP_HOST_POSTGRESQL ]]; then
  DO_DATABASE_BACKUP_LIST+=(postgresql)
fi

if [[ -n $MARIADB_PASSWORD ]] && [[ -n $JOBS_BACKUP_HOST_MARIADB ]]; then
  DO_DATABASE_BACKUP_LIST+=(mariadb)
fi

if [[ -n $MYSQL_PASSWORD ]] && [[ -n $JOBS_BACKUP_HOST_MYSQL ]]; then
  DO_DATABASE_BACKUP_LIST+=(mysql)
fi
# END [ADD-NEW-DATABASE-HERE]

if [[ ${#DO_DATABASE_BACKUP_LIST[@]} = 0 ]]; then
  exit 0;
else
  printf "[INFO] Start database backups for %s" "${DO_DATABASE_BACKUP_LIST[@]}"
fi

###############################
# Perform backups
###############################

BACKUP_DIR="/home/backup/databases"

# Set globals
export PGPASSWORD="$POSTGRES_PASSWORD"

function write_backup()
{
  DATABASE=$1
  DATE_SUFFIX=$2

  ERROR_MSG="[ERROR] Could not backup %s database %s"
  FINAL_BACKUP_DIR=$BACKUP_DIR"/$DATE_SUFFIX"
  TARGET="$FINAL_BACKUP_DIR/$DATABASE"

  if ! mkdir -p $TARGET; then
    echo "[ERROR] Cannot create backup directory in $TARGET. Go and fix it!" 1>&2
    exit 1;
  fi;

  set -o pipefail

  # BEGIN [ADD-NEW-DATABASE-HERE]
  if [[ $DATABASE = "mariadb" ]]; then
    if ! mysqldump --user=root --password=$MARIADB_ROOT_PASSWORD --host=$JOBS_BACKUP_HOST_MARIADB $MARIADB_DATABASE | bzip2 > "$TARGET.sql.bz.in_progress"; then
       printf "$ERROR_MSG" $DATABASE $MARIADB_DATABASE
    else
      mv "$TARGET.sql.bz.in_progress" "$TARGET.sql.bz"
    fi
  fi

  if [[ $DATABASE = "mysql" ]]; then
    if ! mmysqldump --user=root --password=$MYSQL_ROOT_PASSWORD --host=$JOBS_BACKUP_HOST_MYSQL $MYSQL_DATABASE | bzip2 > "$TARGET.sql.bz.in_progress"; then
      printf "$ERROR_MSG" $DATABASE $MYSQL_DATABASE
    else
      mv "$TARGET.sql.bz.in_progress" "$TARGET.sql.bz"
    fi
  fi

  if [[ $DATABASE = "postgresql" ]]; then
			if ! pg_dump -Fc -h "$JOBS_BACKUP_HOST_POSTGRESQL" -U "$POSTGRES_USER" "$POSTGRES_DB" -f "$TARGET.custom.in_progress"; then
				printf "$ERROR_MSG" $DATABASE $POSTGRES_DB
			else
				mv "$TARGET.custom.in_progress" "$TARGET.custom"
			fi
  fi
  # END [ADD-NEW-DATABASE-HERE]

	set +o pipefail
}

function perform_backups()
{
	DATE_SUFFIX=$1

  for i in "${DO_DATABASE_BACKUP_LIST[@]}"; do
    write_backup "$i" "$DATE_SUFFIX"
  done
}


if [[ $JOBS_BACKUP_DISABLE_ROTATION = true ]]; then
  perform_backups "last"
  exit 0;
fi

###############################
#### BACKUP WITH ROTATION #####
###############################

# MONTHLY BACKUPS
DAY_OF_MONTH=`date +%d`
if [ $DAY_OF_MONTH -eq 1 ]; then
	# Delete all expired monthly directories
	find $BACKUP_DIR -maxdepth 1 -name "*-monthly" -exec rm -rf '{}' ';'
	perform_backups "`date +\%Y-\%m-\%d`-monthly"
	exit 0;
fi

# WEEKLY BACKUPS
DAY_OF_WEEK=`date +%u` #1-7 (Monday-Sunday)
EXPIRED_DAYS=`expr $((($JOBS_BACKUP_WEEKS_TO_KEEP * 7) + 1))`
if [ $DAY_OF_WEEK = $JOBS_BACKUP_DAY_OF_WEEK_TO_KEEP ]; then
	# Delete all expired weekly directories
	find $BACKUP_DIR -maxdepth 1 -mtime +$EXPIRED_DAYS -name "*-weekly" -exec rm -rf '{}' ';'
	perform_backups "`date +\%Y-\%m-\%d`-weekly"
	exit 0;
fi

# DAILY BACKUPS
# Delete daily backups x days old or more
find $BACKUP_DIR -maxdepth 1 -mtime +$JOBS_BACKUP_DAYS_TO_KEEP -name "*-daily" -exec rm -rf '{}' ';'
perform_backups "`date +\%Y-\%m-\%d`-daily"
