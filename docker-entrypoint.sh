#!/bin/bash

echo "Generating cron schedules"
echo "${BARMAN_CRON_SCHEDULE} root barman cron" > /etc/crontab
echo "${BARMAN_BACKUP_SCHEDULE} root barman backup all" >> /etc/crontab

echo "Generating Barman configurations"
cat /etc/barman.conf.template | envsubst > /etc/barman.conf

echo "Checking/Creating replication slot"
barman replication-status pg --minimal --target=wal-streamer | grep barman || barman receive-wal --create-slot pg
barman cron
sleep ${BARMAN_RECEIVE_WAL_TIMEOUT}
barman switch-xlog --force --archive pg

echo "Initializing done"

exec "$@"
