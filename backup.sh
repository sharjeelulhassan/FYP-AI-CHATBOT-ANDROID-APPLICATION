#!/bin/bash

# Define variables
DB_NAME="federation"                    # Database name from your configuration
DB_USER="postgres"               # Database user from your configuration
DB_PASSWORD="1234"               # Database password from your configuration
DB_HOST="localhost"              # Database host from your configuration
DB_PORT="5432"                   # Database port from your configuration
BACKUP_DIR="/home/gnuhealth/thalamus-0.9.16/backup" # Directory to store backups
DATE=$(date +%Y%m%d)       # Timestamp for backup file
DAY_NAME=$(date +%A)            # Day name for backup file
BACKUP_FILE="$BACKUP_DIR/$DAY_NAME.sql"
LOGFILE="/home/gnuhealth/thalamus-0.9.16/backup/cron.log" # Path to the log file

# Export the password for pg_dump
export PGPASSWORD=$DB_PASSWORD

# Start logging
echo "$(date): Starting backup of $DB_NAME to $BACKUP_FILE" >> $LOGFILE

# Remove the existing backup for today if it exists
if [ -f "$BACKUP_FILE" ]; then
    echo "$(date): Removing old backup for today: $BACKUP_FILE" >> $LOGFILE
    rm "$BACKUP_FILE"
fi

# Perform the backup
pg_dump -h $DB_HOST -U $DB_USER -p $DB_PORT $DB_NAME > $BACKUP_FILE 2>> $LOGFILE

# Check if the backup file was created
if [ ! -f "$BACKUP_FILE" ]; then
    echo "$(date): Backup failed. Backup file $BACKUP_FILE does not exist." >> $LOGFILE
else
    echo "$(date): Backup completed successfully." >> $LOGFILE
fi

# Optional: Remove backups older than 7 days
find $BACKUP_DIR -type f -name "*.sql" -mtime +7 -exec rm {} \; 2>> $LOGFILE

# Unset the password environment variable
unset PGPASSWORD
