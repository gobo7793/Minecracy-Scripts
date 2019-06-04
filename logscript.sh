#!/bin/bash

mclogdir="/home/minecraft/logs"
essentialsdatadir="/home/minecraft/plugins/Essentials/userdata"

mapscript="/home/minecraft/maps/genmaps.sh"
source $mapscript

#remove server logs older than 6 months
find $mclogdir/ -mtime +176 -type f -delete
find $maplogdir/ -mtime +30 -type f -delete
tmux send-keys -t minecraft 'co purge t:183d #optimize' C-m

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
