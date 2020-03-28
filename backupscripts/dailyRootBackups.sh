targetdir=home/minecraft/backups/system

# get installed packages
dpkg --get-selections > "$targetdir/installed_packages"

# minecracy mysql databases
for DB in $(mysql -e 'show databases' -s --skip-column-names); do
    if [[ $DB == my_* ]]; then
        mysqldump $DB | gzip -c > "$targetdir/$DB.sql.gz";
    fi
done
