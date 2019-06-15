#/bin/bash

echo "Kartenscript gestartet!"

tmux send-keys -t minecraft "say Der Server wird jetzt neu gestartet!" C-m

sleep 2

tmux send-keys -t minecraft "kickall" C-m

sleep 30


# Trim

echo "Alle Spieler gekickt, trimme Welt 'world5'"

tmux send-keys -t minecraft "wb world5 trim 5000 1" C-m
tmux send-keys -t minecraft "wb trim confirm" C-m

sleep 60

echo "beendet. trimme Welt 'world5_creative'"

tmux send-keys -t minecraft "wb world5_creative trim 5000 1" C-m
tmux send-keys -t minecraft "wb trim confirm" C-m

sleep 60

echo "beendet."

echo "Erstelle Backups..."

echo "Taegliches Backup ..."
~/initscript backup -on backups/script_resource/daily daily

if [[ $(date '+%u') == 1 ]]
then
	echo "Woechentliches Backup ..."
	~/initscript backup -on backups/script_resource/weekly weekly
fi

if [[ $(date '+%d') == 01 ]]
then
	echo "Monatliches Backup ..."
	~/initscript backup -on backups/script_resource/monthly monthly
fi

#
