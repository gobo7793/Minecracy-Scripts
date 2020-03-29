#!/bin/bash
rdiff-backup --exclude-filelist excludes --remote-schema 'ssh -C %s sudo rdiff-backup --server' minecraft@minecracy.de::/ /mnt/nas/MY-Backup/
