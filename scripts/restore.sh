#!/bin/sh
# Restore Uptime Kuma from a backup file:  ./scripts/restore.sh backups/kuma-2026-10-12_0200.tar.gz
set -eu
file=${1:?usage: restore.sh backups/kuma-YYYY-MM-DD_HHMM.tar.gz}
[ -f "$file" ] || { echo "not found: $file" >&2; exit 1; }
docker compose stop kuma
docker compose run --rm --no-deps -v "$(pwd)/$(dirname "$file"):/restore:ro" --entrypoint sh kuma \
  -c "rm -rf /app/data/* && tar -xzf /restore/$(basename "$file") -C /app/data"
docker compose start kuma
echo "restored from $file"
