#!/bin/bash
set -e

# 1. Navigate to server directory
cd /home/minecraft/servers

# Check if "init" argument is provided
if [ "$1" = "init" ]; then
  docker compose -f docker-compose.backup.yml up -d
  docker compose -f docker-compose.backup.yml exec borgmatic borgmatic init --encryption keyfile-blake2
  docker compose -f docker-compose.backup.yml exec borgmatic borg key export /opt/backup/ /etc/borgmatic.d/encrypted-key-backup
  docker compose -f docker-compose.backup.yml down
  echo "Borg repository initialized."
  exit 0
fi

# 2. Stop Minecraft containers
docker compose down

# 3. Copy data to staging folder
mkdir -p to-backup config plugins data

sudo rsync -a --no-perms --no-owner --no-group config/ plugins/ data/ docker-compose.yml to-backup/
sudo chown -R minecraft:minecraft to-backup/

# 4. Restart Minecraft quickly
docker compose up -d

# 5. Run borgmatic backup and prune
docker compose -f docker-compose.backup.yml up -d
docker compose -f docker-compose.backup.yml exec borgmatic borgmatic create --stats -v 1
docker compose -f docker-compose.backup.yml exec borgmatic borgmatic prune
docker compose -f docker-compose.backup.yml down

echo "Borg Backup Done"