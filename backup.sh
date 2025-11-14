#!/bin/bash
set -e

# # 1. Navigate to server directory
# cd /home/minecraft/servers

# # Check if "init" argument is provided
# if [ "$1" = "init" ]; then
#   docker compose -f docker-compose.backup.yml up -d
#   docker compose -f docker-compose.backup.yml exec borgmatic borgmatic init --encryption keyfile-blake2
#   docker compose -f docker-compose.backup.yml exec borgmatic borg key export /opt/backup/ /etc/borgmatic.d/encrypted-key-backup
#   docker compose -f docker-compose.backup.yml down
#   echo "Borg repository initialized."
#   exit 0
# fi

# # 2. Stop Minecraft containers
# docker compose down

# # 3. Copy data to staging folder
# mkdir -p to-backup config plugins data

# sudo rsync -a --no-perms --no-owner --no-group config/ plugins/ data/ docker-compose.yml to-backup/
# sudo chown -R minecraft:minecraft to-backup/

# # 4. Restart Minecraft quickly
# docker compose up -d

docker compose -f docker-compose.backup.yml up -d
docker compose -f docker-compose.backup.yml exec borgmatic borgmatic create --stats -v 1
docker compose -f docker-compose.backup.yml exec borgmatic borgmatic prune
docker compose -f docker-compose.backup.yml down

# # 5. Run borgmatic backup
# docker run --rm \
#   -v "$PWD/to-backup":/mnt/source:ro \
#   -v ./.borgmatic/etc.d:/etc/borgmatic.d/ \
#   -v ./.borgmatic/rclone.conf:/root/.config/rclone.conf:ro \
#   -v ./.borgmatic/local-staging:/opt/backup \
#   ghcr.io/borgmatic-collective/borgmatic \
#   create --stats -v 0

# # 6. Prune old archives
# docker run --rm \
#   -v /home/minecraft/borgconfig:/etc/borgmatic.d/ \
#   -v /home/minecraft/rclone.conf:/root/.config/rclone.conf:ro \
#   ghcr.io/borgmatic-collective/borgmatic \
#   prune


