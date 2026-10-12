#!/bin/sh
# Back up the Uptime Kuma data volume to ./backups as a dated tar.gz and keep the last KEEP_DAYS days.
#   backup.sh           run once
#   backup.sh --loop    run every day at BACKUP_HOUR (container mode)
set -eu

SRC=${SRC:-/data}
DEST=${DEST:-/backups}
KEEP_DAYS=${KEEP_DAYS:-7}
BACKUP_HOUR=${BACKUP_HOUR:-2}

backup_once() {
  mkdir -p "$DEST"
  stamp=$(date +%Y-%m-%d_%H%M)
  out="$DEST/kuma-$stamp.tar.gz"
  # copy first so SQLite is read from a consistent snapshot of the files
  tmp=$(mktemp -d)
  cp -a "$SRC/." "$tmp/"
  tar -czf "$out.part" -C "$tmp" .
  mv "$out.part" "$out"
  rm -rf "$tmp"
  find "$DEST" -name 'kuma-*.tar.gz' -mtime +"$KEEP_DAYS" -delete
  echo "$(date '+%F %T') backup ok: $out ($(du -h "$out" | cut -f1))"
}

if [ "${1:-}" = "--loop" ]; then
  echo "backup loop: daily at ${BACKUP_HOUR}:00, keeping ${KEEP_DAYS} days"
  while true; do
    now_h=$(date +%-H)
    if [ "$now_h" -eq "$BACKUP_HOUR" ]; then
      backup_once
      sleep 3600
    fi
    sleep 300
  done
else
  backup_once
fi
