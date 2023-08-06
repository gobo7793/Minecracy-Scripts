#!/bin/bash

ROOTDIR="/home/mybackup/backups"
LOGDIR="/home/mybackup/logs"

# copy all output to logfile
#exec > >(tee -i ${LOG})
#exec 2>&1

echo "Pruning backup for minecracy server on $(date)"

borg prune -v ${ROOTDIR} \
        --keep-daily=90 \
        --keep-weekly=52 \
        --keep-monthly=36

# make sure repo is unlocked after
borg break-lock ${ROOTDIR}

# prune logfiles
find $LOGDIR/ -mtime +365 -type f -delete

echo "Pruning finished on $(date)"
