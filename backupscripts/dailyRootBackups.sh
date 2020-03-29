#!/bin/bash
targetdir=/home/minecraft/backups/system

# get installed packages
dpkg --get-selections > "$targetdir/installed_packages"

# minecracy mysql databases
for DB in $(mysql -e 'show databases' -s --skip-column-names); do
    mysqldump $DB | gzip -c > "$targetdir/$DB.sql.gz";
done
