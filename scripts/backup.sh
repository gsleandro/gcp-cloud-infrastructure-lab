#!/bin/bash
set -euo pipefail

BUCKET="gs://carleandro-gcp-cloud-lab-2026"
BACKUP_DIR="$HOME/backups"
TIMESTAMP="$(date +%Y-%m-%d-%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/nginx-backup-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

sudo tar -czf "$BACKUP_FILE" /etc/nginx /var/www/html

gcloud storage cp "$BACKUP_FILE" "$BUCKET/backups/"

echo "Backup uploaded successfully: $BACKUP_FILE"
