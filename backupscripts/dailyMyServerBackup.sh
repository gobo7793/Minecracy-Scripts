#!/bin/bash

BACKUPDATADIR="/home/minecraft/backups/system"
source "$BACKUPDATADIR/repodata.sh"
LOG="$BACKUPDATADIR/logs/$(date +\%Y-\%m-\%d).log"

# Write output to logfile
#exec > >(tee -i ${LOG})
#exec 2>&1

echo "Starting backup on $(date)"

# Create list of installed software
dpkg --get-selections > "$BACKUPDATADIR/software.list"

# Create minecracy database dumps
for DBNAME in $(mysql -e 'show databases' -s --skip-column-names); do
    if [[ "$DBNAME" == my_* ]]; then
        echo "Creating backup for database $DBNAME"
        mysqldump -u "$DBUSER" -p"$DBPASS" "$DBNAME" | gzip -c > "$BACKUPDATADIR/$DBNAME.sql.gz";
    fi
done

# Sync backup data
echo "Syncing backup files ..."
borg create -v --stats                                  \
    $REPOSITORY::"$(date +%Y-%m-%d_%H:%M)"              \
    /root                                               \
    /etc                                                \
    /var/www                                            \
    /var/mail                                           \
    /home                                               \
    --exclude /home/minecraft/config                    \
    --exclude /home/minecraft/mods                      \
    --exclude /home/minecraft/plugins                   \
    --exclude /home/minecraft/world5                    \
    --exclude /home/minecraft/world5_nether             \
    --exclude /home/minecraft/world5_the_end            \
    --exclude /home/minecraft/world6_creative           \
    --exclude '/home/minecraft/maps/*/.git/objects/*'   \
    --exclude '/home/minecraft/maps/BlockMap/*/build'

echo "Finished backup on $(date)"
