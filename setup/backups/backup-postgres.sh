#!/bin/bash
# Daily PostgreSQL backup with local + S3 retention
# Installed to ~/backups/backup-postgres.sh on the server by install.sh
# Runs via cron: 0 3 * * * (3am UTC daily)

set -euo pipefail

BACKUP_DIR="$HOME/backups"
LOCAL_RETENTION_DAYS=30
S3_BUCKET="s3://backups-kleer/eventer"
S3_RETENTION_DAYS=365
AWS="$HOME/.local/bin/aws"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FILENAME="eventer_production-$TIMESTAMP.dump"
BACKUP_FILE="$BACKUP_DIR/$FILENAME"

# Dump production database
docker exec postgres pg_dump -U postgres -Fc eventer_production > "$BACKUP_FILE"

# Verify backup is not empty
if [ ! -s "$BACKUP_FILE" ]; then
  echo "ERROR: Backup file is empty" >&2
  rm -f "$BACKUP_FILE"
  exit 1
fi

SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "$(date): Backup created: $FILENAME ($SIZE)"

# Upload to S3
$AWS s3 cp "$BACKUP_FILE" "$S3_BUCKET/$FILENAME" --quiet
echo "$(date): Uploaded to $S3_BUCKET/$FILENAME"

# Clean up old local backups
find "$BACKUP_DIR" -name "eventer_production-*.dump" -mtime +$LOCAL_RETENTION_DAYS -delete
echo "$(date): Cleaned local backups older than $LOCAL_RETENTION_DAYS days"

# Clean up old S3 backups
CUTOFF_DATE=$(date -d "-${S3_RETENTION_DAYS} days" +%Y%m%d)
$AWS s3 ls "$S3_BUCKET/" | grep "eventer_production-" | while read -r line; do
  FILE_DATE=$(echo "$line" | grep -oP "eventer_production-\K\d{8}")
  FILE_NAME=$(echo "$line" | awk '{print $4}')
  if [ -n "$FILE_DATE" ] && [ "$FILE_DATE" -lt "$CUTOFF_DATE" ]; then
    $AWS s3 rm "$S3_BUCKET/$FILE_NAME" --quiet
    echo "$(date): Deleted from S3: $FILE_NAME"
  fi
done
echo "$(date): S3 cleanup done (retention: $S3_RETENTION_DAYS days)"
