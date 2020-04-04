#!/bin/bash

ROOTDIR="/home/mybackup/backups"
LOGDIR="/home/mybackup/logs"

# copy all output to logfile
#exec > >(tee -i ${LOG})
#exec 2>&1

echo "Pruning backup for minecracy server on $(date)"

borg prune -v ${ROOTDIR} \
--keep-daily=7 \
--keep-weekly=4 \
--keep-monthly=6

echo "Pruning finished"

# prune logfiles
find $LOGDIR/ -mtime +183 -type f -delete
