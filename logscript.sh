#!/bin/bash

mclogdir="/home/minecraft/logs"
backuplogdir="/home/minecraft/backups/system/logs"
essentialsdatadir="/home/minecraft/plugins/Essentials/userdata"

mapscript="/home/minecraft/maps/genmaps.sh"
source $mapscript

#remove server logs older than a year and map logs older than a month
# see https://unix.stackexchange.com/a/288031
find $mclogdir/ -type f -name '*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9].log.gz' -exec sh -c 'fdate="${1%-?.log.gz}"; fdate="${fdate##*/}"; [ "$fdate" "<" "$(date +%F -d "1 year ago")" ] && rm "$1"' find-sh {} \;
#find $mclogdir/ -mtime +358 -type f -delete
find $maplogdir/ -mtime +30 -type f -delete
find $backuplogdir/ -mtime +183 -type f -delete
tmux send-keys -t minecraft 'co purge t:365d #optimize' C-m

#remove ips in server logs older than 7 days
logfiles=$(find $mclogdir/*.log.gz -mtime +7 -type f)
for file in $logfiles; do
    cp "$file" "$file~" &&
    rm "$file" &&
    gzip -cd "$file~" |
    sed 's/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/x.x.x.x/g' |
    gzip > "$file" &&
    rm "$file~"
done

#remove ips in essentials player data
find $essentialsdatadir/* -mtime +7 -type f -exec sed -i 's/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/0.0.0.0/g' {} \;
