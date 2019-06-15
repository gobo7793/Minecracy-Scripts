#!/bin/bash

currDate=$(date +%Y-%m)
echo "Kartenscript gestartet!"

tmux send-keys -t minecraft "say Kartenscript wurde gestartet!" C-m
tmux send-keys -t minecraft "say [MAPS] In zwei Minuten werden alle Spieler vom Server geworfen und der Server neu gestartet." C-m
#tmux send-keys -t minecraft "say [MAPS] Bitte erst 5-10 Minuten nach dem Rauswurf wieder verbinden." C-m

sleep 60

echo " -> 60"

tmux send-keys -t minecraft "say [MAPS] kick-all in einer Minute" C-m

sleep 30

echo " -> 30"

tmux send-keys -t minecraft "say Zur Kartengenerierung werden alle Spieler in 30 Sekunden vom Server geworfen." C-m
tmux send-keys -t minecraft "say Anschließend wird ein Backup gemacht und der Server neu gestartet. Bitte erst nach 5 bis 10 Minuten wieder verbinden." C-m

sleep 10

tmux send-keys -t minecraft "say [MAPS] kick-all in 20 Sekunden" C-m

sleep 10

tmux send-keys -t minecraft "say [MAPS] kick-all in 10 Sekunden" C-m

sleep 5

tmux send-keys -t minecraft "say [MAPS] kick-all in 5 Sekunden" C-m

sleep 5

tmux send-keys -t minecraft "say Backup wird jetzt durchgeführt!" C-m

sleep 2

tmux send-keys -t minecraft "kickall" C-m

sleep 10


# Trim

echo "Alle Spieler gekickt, trimme Welt 'world5'"

tmux send-keys -t minecraft "wb world5 trim 500 1" C-m
tmux send-keys -t minecraft "wb trim confirm" C-m

sleep 10

echo "beendet. trimme Welt 'world5_creative'"

tmux send-keys -t minecraft "wb world5_creative trim 500 1" C-m
tmux send-keys -t minecraft "wb trim confirm" C-m

sleep 10

echo "beendet."

#echo "Speichere Welt..."

#tmux send-keys -t minecraft "save-all" C-m

echo "Beende Minecraft..."

~/initscript stop

sleep 5

echo "Erstelle Backups..."

echo "Taegliches Backup ..."
~/initscript backup -on backups/script_resource/daily daily

if [ $(date '+%u') == 1 ]
then
	echo "Woechentliches Backup ..."
	~/initscript backup -on backups/script_resource/weekly weekly
fi

if [ $(date '+%d') == 01 ]
then
	echo "Monatliches Backup ..."
	~/initscript backup -on backups/script_resource/monthly monthly
fi

echo "Starte Minecraft..."

~/initscript start

sleep 30

tmux send-keys -t minecraft "say [MAPS] Backup abgeschlossen. Generiere Karten..." C-m

echo "Beginne mit Kartengenerierung …"

echo " Overviewer, 3D-Karte World5, Tag und Nachtansicht"

overviewer.py --config=/home/minecraft/maps/overviewer_config/world5.py > /home/minecraft/maps/overviewer_log/world5_render.log 2>&1
overviewer.py --config=/home/minecraft/maps/overviewer_config/world5.py --genpoi > /home/minecraft/maps/overviewer_log/world5_genpoi.log 2>&1

tmux send-keys -t minecraft "say [MAPS] Generierung der Overviewer-Karte von world5 abgeschlossen" C-m

echo " Overviewer, 3D-Karte World5, Nether"

overviewer.py --config=/home/minecraft/maps/overviewer_config/nether5.py > /home/minecraft/maps/overviewer_log/nether5_render.log 2>&1
overviewer.py --config=/home/minecraft/maps/overviewer_config/nether5.py --genpoi > /home/minecraft/maps/overviewer_log/nether5_genpoi.log 2>&1

tmux send-keys -t minecraft "say [MAPS] Generierung der Overviewer-Karte von world5_nether abgeschlossen" C-m

echo " Overviewer, 3D-Karte Creative, Tagansicht"

overviewer.py --config=/home/minecraft/maps/overviewer_config/creative5.py > /home/minecraft/maps/overviewer_log/creative5_render.log 2>&1
overviewer.py --config=/home/minecraft/maps/overviewer_config/creative5.py --genpoi > /home/minecraft/maps/overviewer_log/creative5_genpoi.log 2>&1

tmux send-keys -t minecraft "say [MAPS] Generierung der Overviewer-Karte von world5_creative abgeschlossen" C-m

echo " TMCMR, 2D-Karte world5"

/usr/bin/java -jar /home/minecraft/maps/TMCMR/TMCMR.jar -create-big-image -o /home/minecraft/maps/maps.minecracy.de/world5/tmcmr/ /home/minecraft/maps/world5/region/

gm convert /home/minecraft/maps/maps.minecracy.de/world5/tmcmr/big.png -crop 10016x10016+114+114 /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5/current-10016px.jpg

gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5/current-5000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5/current-2500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5/current-1000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5/current-500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5/current-250px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5/current-100px.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5/current-5000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5/current-2500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5/current-1000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5/current-500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5/current-250px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5/current-100px.jpg

tmux send-keys -t minecraft "say [MAPS] Generierung der Karte von world5 abgeschlossen" C-m

echo " TMCMR, 2D-Karte world5_creative"

/usr/bin/java -jar /home/minecraft/maps/TMCMR/TMCMR.jar -create-big-image -o /home/minecraft/maps/maps.minecracy.de/world5_creative/tmcmr/ /home/minecraft/maps/world5_creative/region/

gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/tmcmr/big.png -crop 10016x10016+114+114 /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5_creative/current-10016px.jpg

gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-5000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-2500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-1000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-250px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-100px.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-5000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-2500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-1000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-250px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-100px.jpg

tmux send-keys -t minecraft "say [MAPS] Generierung der Karte world5_creative abgeschlossen" C-m

echo " Rasterkarte world5"

gm composite -gravity center /home/minecraft/maps/raster5k.png /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5/raster/current-10016px.jpg

gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-5000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-2500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-1000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-250px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-100px.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-5000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-2500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-1000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-250px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-100px.jpg

tmux send-keys -t minecraft "say [MAPS] Generierung der Rasterkarte von world5 abgeschlossen" C-m

echo " Rasterkarte world5_creative"

gm composite -gravity center /home/minecraft/maps/raster5k.png /home/minecraft/maps/maps.minecracy.de/world5_creative/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-10016px.jpg

gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-5000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-2500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-1000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-250px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-100px.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-5000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-2500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-1000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-250px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-100px.jpg

tmux send-keys -t minecraft "say [MAPS] Generierung der Rasterkarte von world5_creative abgeschlossen" C-m

echo " Grenzkarte world5"

gm composite -gravity center /home/minecraft/maps/w5-projektlayer.png /home/minecraft/maps/maps.minecracy.de/world5/raster/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-10016px.jpg

gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-5000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-2500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-1000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-250px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-100px.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-5000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-2500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-1000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-250px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-100px.jpg

tmux send-keys -t minecraft "say [MAPS] Generierung der Raster-Grenzkarte von world5 abgeschlossen" C-m

echo " Bahnkarte world5"

/usr/bin/java -jar /home/minecraft/maps/TMCMR/TMCMR.jar -create-big-image -color-map /home/minecraft/maps/tmcmr-colors-bahn.txt -o /home/minecraft/maps/maps.minecracy.de/world5/bahn/tmcmr/ /home/minecraft/maps/world5/region/

python /home/minecraft/maps/bahnstrecken.py /home/minecraft/maps/maps.minecracy.de/world5/bahn/tmcmr/big.png /home/minecraft/maps/maps.minecracy.de/world5/bahn/tmcmr/bahn.png
gm composite -gravity center /home/minecraft/maps/maps.minecracy.de/world5/bahn/tmcmr/bahn.png /home/minecraft/maps/maps.minecracy.de/world5/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png
gm composite -gravity center /home/minecraft/maps/w5-bahnhoflayer.png /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/tmcmr/big.png -crop 10016x10016+114+114 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-raw.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/tmcmr/bahn.png -crop 10016x10016+114+114 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-layer.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-10016px.jpg

gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-5000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-2500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-1000px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-500px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-250px.png
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-100px.png

gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 5000x5000 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-5000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 2500x12500 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-2500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-1000px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 500x500 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-500px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 250x250 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-250px.jpg
gm convert /home/minecraft/maps/maps.minecracy.de/world5/bahn/$currDate.png -resize 100x100 /home/minecraft/maps/maps.minecracy.de/world5/bahn/current-100px.jpg

tmux send-keys -t minecraft "say [MAPS] Generierung der Bahnkarte von world5 abgeschlossen." C-m

tmux send-keys -t minecraft "say [MAPS] Generierung aller Karten abgeschlossen" C-m

echo "Generierung der Karten abgeschlossen."

#
