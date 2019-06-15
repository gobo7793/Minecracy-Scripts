#/bin/bash

date=$(date +%Y-%m)
maps="/home/minecraft/maps/maps.minecracy.de/"

echo "Beginne mit Kartengenerierung …"

tmux send-keys -t minecraft "mci [MAPS] Generierung der Overviewer-Karte abgeschlossen" C-m

echo " TMCMR, 2D-Karte world5"

/usr/bin/java -jar /home/minecraft/maps/TMCMR/TMCMR.jar -create-big-image -o /home/minecraft/maps/maps.minecracy.de/world5/tmcmr/ /home/minecraft/maps/world5/region/

convert /home/minecraft/maps/maps.minecracy.de/world5/tmcmr/big.png -crop 10016x10016+114+114 /home/minecraft/maps/maps.minecracy.de/world5/$date.png

convert /home/minecraft/maps/maps.minecracy.de/world5/$date.png /home/minecraft/maps/maps.minecracy.de/world5/current-10016px.jpg

convert /home/minecraft/maps/maps.minecracy.de/world5/$date.png -resize 5008x5008 /home/minecraft/maps/maps.minecracy.de/world5/current-5008px.png

convert /home/minecraft/maps/maps.minecracy.de/world5/$date.png -resize 256x256 /home/minecraft/maps/maps.minecracy.de/world5/current-256px.png

convert /home/minecraft/maps/maps.minecracy.de/world5/$date.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5/current-1000px.png

convert /home/minecraft/maps/maps.minecracy.de/world5/$date.png -resize 160x160\! /home/minecraft/maps/maps.minecracy.de/world5/current-160px.png

tmux send-keys -t minecraft "mci [MAPS] Generierung der Karte von world5 abgeschlossen" C-m

echo " TMCMR, 2D-Karte world5_creative"

/usr/bin/java -jar /home/minecraft/maps/TMCMR/TMCMR.jar -create-big-image -o /home/minecraft/maps/maps.minecracy.de/world5_creative/tmcmr/ /home/minecraft/maps/world5_creative/region/

convert /home/minecraft/maps/maps.minecracy.de/world5_creative/tmcmr/big.png -crop 10016x10016+114+114 /home/minecraft/maps/maps.minecracy.de/world5_creative/$date.png

convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$date.png /home/minecraft/maps/maps.minecracy.de/world5_creative/current-10016px.jpg

convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$date.png -resize 5008x5008 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-5008px.png

convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$date.png -resize 256x256 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-256px.png

convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$date.png -resize 1000x1000 /home/minecraft/maps/maps.minecracy.de/world5_creative/current-1000px.png

convert /home/minecraft/maps/maps.minecracy.de/world5_creative/$date.png -resize 160x160\! /home/minecraft/maps/maps.minecracy.de/world5_creative/current-160px.png

tmux send-keys -t minecraft "mci [MAPS] Generierung der Karte world5_creative abgeschlossen" C-m

echo " Rasterkarte world5"

composite -gravity center /home/minecraft/maps/Raster5k.png /home/minecraft/maps/maps.minecracy.de/world5/$date.png /home/minecraft/maps/maps.minecracy.de/world5/raster/$date.png

convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$date.png /home/minecraft/maps/maps.minecracy.de/world5/raster/current-10016px.jpg

convert /home/minecraft/maps/maps.minecracy.de/world5/raster/$date.png -resize 5008x5008 /home/minecraft/maps/maps.minecracy.de/world5/raster/current-5008px.png

tmux send-keys -t minecraft "mci [MAPS] Generierung der Rasterkarte von world5 abgeschlossen" C-m

echo " Rasterkarte world5_creative"

composite -gravity center /home/minecraft/maps/Raster5k.png /home/minecraft/maps/maps.minecracy.de/world5_creative/$date.png /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$date.png

convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$date.png /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-10016px.jpg

convert /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/$date.png -resize 5008x5008 /home/minecraft/maps/maps.minecracy.de/world5_creative/raster/current-5008px.png

tmux send-keys -t minecraft "mci [MAPS] Generierung der Rasterkarte von world3_creative abgeschlossen" C-m

echo " Grenzkarte world5"

composite -gravity center /home/minecraft/maps/Grenzkarte-world5.png /home/minecraft/maps/maps.minecracy.de/world5/raster/$date.png /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$date.png

convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$date.png /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-10016px.jpg

convert /home/minecraft/maps/maps.minecracy.de/world5/grenzen/$date.png -resize 5008x5008 /home/minecraft/maps/maps.minecracy.de/world5/grenzen/current-5008px.png

tmux send-keys -t minecraft "mct [MAPS] Generierung der Raster-Grenzkarte von world5 abgeschlossen" C-m

echo " Bahnkarte world5"

/usr/bin/java -jar /home/minecraft/maps/TMCMR/TMCMR.jar -create-big-image -color-map /home/minecraft/maps/tmcmr-colors-bahn.txt -o /home/minecraft/maps/maps.minecracy.de/world5/bahn/tmcmr/ /home/minecraft/maps/world5/region/

python /home/minecraft/maps/bahnstrecken.py $maps/world5/bahn/tmcmr/big.png $maps/world5/bahn/tmcmr/bahn.png
composite -gravity center $maps/world5/bahn/tmcmr/bahn.png $maps/world5/$date.png $maps/world5/bahn/$date.png
convert $maps/world5/bahn/$date.png $maps/world5/bahn/current-10016px.jpg
convert $maps/world5/bahn/$date.png -resize 5008x5008 $maps/world5/bahn/current-5008px.png
tmux send-keys -t minecraft "mci [MAPS] Generierung der Bahnkarte von world5 abgeschlossen." C-m

tmux send-keys -t minecraft "mci [MAPS] Generierung aller Karten abgeschlossen" C-m

echo "Generierung der Karten abgeschlossen."

#
