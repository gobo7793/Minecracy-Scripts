#!/bin/bash

# current world names
world="world5"
world2="world6"
worldc="world6_creative"

# world sizes
worldmax=5000
world2max=1500
worldcmax=500

# base directories
mapsdir="/home/minecraft/maps"
mapstargetdir="$mapsdir/maps.minecracy.de"
configdir="$mapsdir/config"
maplogdir="$mapsdir/logs"
origworlddir="/home/minecraft/$world"
origworld2dir="/home/minecraft/$world2"
dailydir="/home/minecraft/backups/daily"
weeklydir="/home/minecraft/backups/weekly"
monthlydir="/home/minecraft/backups/monthly"

# tool directories
mapgentool="$mapsdir/BlockMap/BlockMap-cli-1.5.1.1.jar"
overviewerdir="$mapsdir/Overviewer"
railwayscript="$mapsdir/bahnstrecken_fast.py"
trimtool="$mapsdir/Minecraft-Map-Auto-Trim/mmat-fix.jar"
safezonescript="$mapsdir/szmap.py"

# initscript related
initscript="/home/minecraft/initscript"
backupinfosrc="/home/minecraft/backups/script_resource"

# image/config sources
raster5k="$configdir/raster5k.png"
projectlayer="$configdir/w5-projektlayer"
railwaylayer="$configdir/w5-bahnhoflayer"
projectlayer2="$configdir/w6-projektlayer"
railwaylayer2="$configdir/w6-bahnhoflayer"

#railcolors="$configdir/tmcmr-colors-bahn.txt"
railcolors="$configdir/block-colors-rails.json"
safezonelist="/home/minecraft/plugins/Residence/Save/Worlds/res_world5.yml"
safezonelist2="/home/minecraft/plugins/Residence/Save/Worlds/res_world6.yml"

# overviewer configs, without file extension '.py'
# file extension will be added on exection!
ovworldcfg="$configdir/ov"

# script settings
script_name="$(basename $0)"
currMonth=$(date +%Y-%m)
currDay=$(date +%Y-%m-%d)
quiet=false
cmdtofile=false
mcout=true
simulate=false

# check if we are being sourced by another script or shell
[[ "${#BASH_SOURCE[@]}" -gt "1" ]] && { return 0; }

# Logging output
log(){
    if [[ "$quiet" == false ]]; then
        if [[ "$cmdtofile" == true ]]; then
            logecho "$@" >> $maplogdir/$currDay.log
        else
            logecho "$@"
        fi
    fi
}

# Echos the log output
logecho(){
    echo "[$(date +%H:%M:%S)] $@"
}

# Perform operation $@
per(){
    log "Execute: '"$@"'"
    if [[ "$simulate" == false ]]; then
        $($@ >> $maplogdir/$currDay.log 2>&1)
    fi
}

# Execute minecraft command
mc(){
    mcmessend 0 "$@"
}

# Sends all to minecraft chat if $mcout is true
mcs(){
    mcmessend 1 "$@"
}

# Sends all to minecraft chat and discord if $mcout is true
mcsd(){
    mcmessend 2 "$@"
}

# Sends the message to minecraft as command, say oder say+discord, if $mcout is true
# $1: Indicates the message type:
#       0: command (default)
#       1: say to minecraft ingame chat
#       2: say to minecraft ingame chat and discord chat
# $@: the message to send
mcmessend(){
    
    mctype=$1
    shift
    mcmess="$@"
    if [[ $mctype == 1 || $mctype == 2 ]]; then
        mcmess="[MAPS] $@"
    fi
    
    log "tmux (type=$mctype) -> $mcmess"
    if [[ $mctype == 0 ]]; then
        tmuxsend "$mcmess"
    elif [[ $mctype == 1 ]]; then
        tmuxsend "say $mcmess"
    elif [[ $mctype == 2 ]]; then
        tmuxsend "discord broadcast $mcmess"
    fi
}

# Sends all to minecraft tmux window
tmuxsend(){
    if [[ "$mcout" != false ]]; then
        tmux send-keys -t minecraft "$@" C-m
    fi
}

# Generates new 2D map
# $1: world directory
# $2: world size
# $3: colormap name (optional)
# $4: subdirectory in world directory for target (only if $3 given)
tmcmr(){
    local w="$1"
    local size="$2"
    if [[ -n $3 && -n $4 ]]; then
        local colormap="--color-map $3 --shader=FLAT"
        local subdir="/$4"
    fi

    #per "/usr/bin/java -jar $mapgentool render --lazy --create-big-image --create-tile-html $colormap --max-X=$size --max-Z=$size --min-X=-$size --min-Z=-$size -o $mapstargetdir/$w$subdir/tmcmr/ $dailydir/$w/region/" #old blockmap syntax
    per "/usr/bin/java -jar $mapgentool render --lazy --create-big-image --create-tile-html $colormap --max-X=$size --max-Z=$size --min-X=-$size --min-Z=-$size -o $mapstargetdir/$w$subdir/tmcmr/ $dailydir/$w/region/"
}

# Renews the overviewer and markers
# $1: config file
# $2: ct: execute with --check-tiles option
#     poi: generate POIs instead of map
overviewer(){
    local ovconf="$1.py"
    #ovlog="$maplogdir/$currDay-ov.log"
    local checktiles=""
    local ovgenpoi=false
    if [[ $2 == "ct" ]]; then
        checktiles="--check-tiles"
    elif [[ $2 == "poi" ]]; then
        ovgenpoi=true
    fi
    
    if [[ $ovgenpoi == "true" ]]; then
        log "Generiere Overviewer-POIs $ovconf"
        per $overviewerdir/overviewer.py --config=$ovconf --genpoi
    else
        log "Generiere Overviewer $ovconf"
        if [[ -n $checktiles ]]; then
            log "Info: --check-tiles aktiviert!"
        fi
        per $overviewerdir/overviewer.py --config=$ovconf $checktiles
    fi
}

# Converts the file
# $1: source file
# $2: target file
# $3+: convert options
gmcon(){
    src="$1"
    targ="$2"
    shift 2
    opt="$@"

    per gm convert $src $opt $targ
}

# Composites the given sources
# $1: upper layer source
# $2: base layer source
# $3: target file
gmcomp(){
    upper="$1"
    down="$2"
    target="$3"

    per gm composite -gravity center $upper $down $target
}

# Resize the source file to png and jpg thumbnails
# $1: source file
# $2: target directory
# $3: image width
gmmapres(){
    basefile="$1"
    basedir="$2"
    width="$3px"

    gmcon $basefile $basedir/current-$width.png -resize $3x$3
    gmcon $basefile $basedir/current-$width.jpg -resize $3x$3
}

# Crops the source file to 10kx10k if greater (formerly 10016x10016+114+114)
# $1: source file
# $2: target file
# $3: file pixel size
gmcrop(){
    local src="$1"
    local targ="$2"
    local size="$3"

    gmcon $src $targ -crop "$size""x$size>" #10016x10016 +114+114 old settings
}

# Renew the layer render and composites it with 5k raster
# Will only be executed if svg source is newer than png target
# $1: svg source
# $2: png target
render_svgtoraster(){
    svg="$1"
    png="$2"

    if [[ "$svg" -nt "$png" ]]; then
        per inkscape -z -f $svg -e $png
        gmcomp $png $raster5k $png
    fi
}

# Send kick messages to minecraft
init_kickall(){
    mcsd "In zwei Minuten werden alle Spieler vom Server geworfen, ein Backup durchgefuehrt und der Server neu gestartet."

    per sleep 60

    log " -> 60"
    mcs "kick-all in einer Minute!"

    per sleep 30

    log " -> 30"
    mcs "Zur Kartengenerierung werden alle Spieler in 30 Sekunden vom Server geworfen."
    mcs "Danach wird ein Backup gemacht und der Server neu gestartet."
    mcs "Bitte erst nach dem Neustart wieder verbinden!"

    per sleep 10

    mcs "kick-all in 20 Sekunden!"

    per sleep 10

    mcs "kick-all in 10 Sekunden!"

    per sleep 5

    mcs "kick-all in 5 Sekunden!"

    per sleep 5

    mcsd "Backup wird jetzt durchgefuehrt! Bis zum Neustart nicht mehr mit dem Server verbinden!"

    per sleep 2

    mc "kickall"

    log "Alle Spieler gekickt"
}

# Trim the minecraft world
# $1: world name
# $2: world size (optional, else $worldmax)
trim(){
    w="$1"
    local size="$worldmax"
    if [[ -n $2 ]]; then
        local size="$2"
    fi
    log "Trimme Welt $w"

    mc "wb $w set $size 0 0"
    mc "wb $w trim 1000 0"
    mc "wb trim confirm"
    per sleep 120
    mc "wb $w clear"

    # -p 1 macht, dass alle Chunks, in denen Stein (id=1) vorkommt, bleiben
    #per java -jar $trimtool -w $w -r -5000,5000,-5000,5000 -p 1 # not compatible with MC1.13
}

# Create daily, weekly and monthly backups
backups(){
    log "Erstelle Backups"

    log "Erstelle tägliches Backup"
    per $initscript backup -on $backupinfosrc/daily daily
    #trim $dailydir/$world

    if [[ $(date '+%u') == 1 ]]; then
        log "Erstelle wöchentliches Backup"
        per $initscript backup -on $backupinfosrc/weekly weekly
    fi

    if [[ $(date '+%d') == 01 ]]; then
        log "Erstelle monatliches Backup"
        per $initscript backup -on $backupinfosrc/monthly monthly
        #trim $monthlydir/$world
    fi
}

# Trim backups
#trim_backups(){
#    log "Trimme Backups"
#
#    log "Trimme tägliches Backup"
#    trim $dailydir/$world
#
#    if [[ $(date '+%u') == 1 ]]; then
#        log "Trimme wöchentliches Backup"
#        # nothing to do because weekly default trim
#    fi
#
#    if [[ $(date '+%d') == 01 ]]; then
#        log "Trimme monatliches Backup"
#        trim $monthlydir/$world
#    fi
#}

# Generates the thumbnails
# $1: source file
# $2: target directory
# $3: world size
resize2d(){
    local resBasefile="$1"
    local resBasedir="$2"
    local size="$3"
    
    gmcon $resBasefile "$resBasedir/current-$((size*2))px.jpg"
    gmmapres $resBasefile $resBasedir $size
    gmmapres $resBasefile $resBasedir $((size/2))
    gmmapres $resBasefile $resBasedir 150
}

# Generates the raw map
# $1: world directory name
# $2: world maps base directory
# $3: world size
gen2draw(){
    local w="$1"
    local basedir="$2"
    local rawfile="$2/$currMonth.png"
    local size="$3"

    tmcmr $w $size
    per cp "$basedir/tmcmr/big.png" "$rawfile"

    resize2d $rawfile $basedir $size
}

# Generates the raster map
# $1: world maps base directory
# $2: world size
raster2d(){
    local basedir="$1/raster"
    local rawfile="$1/$currMonth.png"
    local basefile="$basedir/$currMonth.png"
    local size="$2"

    gmcomp $raster5k $rawfile $basefile

    resize2d $basefile $basedir $size
}

# Generates the project map
# $1: world maps base directory
# $3: world size
# $2: project layer base svg file WITHOUT file extension
project2d(){
    local basedir="$1/grenzen"
    local rawfile="$1/$currMonth.png"
    local basefile="$basedir/$currMonth.png"
    local size="$2"
    local projectsvg="$3.svg"
    local projectpng="$3.png"

    render_svgtoraster $projectsvg $projectpng

    gmcomp $projectpng $rawfile $basefile

    resize2d $basefile $basedir $size
}

# Generates the safezone map
# $1: world maps base directory
# $2: world size
# $3: Residence safezone list for world
gen2dsafezones(){
    local basedir="$1/sz"
    local basefile="$basedir/$currMonth.png"
    local rawfile="$1/$currMonth.png"
    local rawszfile="$basedir/current-raw.png"
    local size="$2"
    local szlist="$3"

    per python3 $safezonescript $szlist $rawszfile
    gmcomp $rawszfile $rawfile $basefile
    resize2d $basefile $basedir $size
}

# Generates the railway map (uses $worldmax)
# $1: world directory name
# $2: world maps base directory
# $3: world size
# $4: railmap layer base svg file WITHOUT file extension
gen2drail(){
    local w="$1"
    local basedir="$2/bahn"
    local basefile="$basedir/$currMonth.png"
    local rawfile="$2/$currMonth.png"
    local rawlayerfile="$basedir/tmcmr/bahn.png"
    local rawlayerfilecropped="$basedir/current-layer.png"
    local rawrailwayfile="$basedir/current-raw.png"
    local size="$3"
    local railwaysvg="$4.svg"
    local railwaypng="$4.png"

    tmcmr $w $worldmax RAILS bahn

    render_svgtoraster $railwaysvg $railwaypng
    per python3 $railwayscript "$basedir/tmcmr/big.png" $rawlayerfile

    gmcrop "$basedir/tmcmr/big.png" $rawrailwayfile $((size*2))
    gmcrop $rawlayerfile $rawlayerfilecropped $((size*2))

    gmcomp $rawlayerfilecropped $rawfile $basefile
    gmcomp $railwaypng $basefile $basefile

    resize2d $basefile $basedir $size
}

# Generates all 2D maps for the world. If world name in $1 is not $world or $world2, then no extended maps will be generated.
# $1: world directory name
# $2: world size
# $2: not empty for generating project and railway maps
gen2d(){
    w="$1"
    local size="$2"
    local extendedmaps=false
    if [[ $3 == "true" ]]; then
        extendedmaps=true
    fi
    local rawdir="$mapstargetdir/$w"
    local projlayer=""
    local raillayer=""
    local szlist=""
    if [[ $1 == "$world" ]]; then
        projlayer="$projectlayer"
        raillayer="$railwaylayer"
        szlist="$safezonelist"
    elif [[ $1 == "$world2" ]]; then
        projlayer="$projectlayer2"
        raillayer="$railwaylayer2"
        szlist="$safezonelist2"
    else
       extendedmaps=false
    fi

    mcsd "Generiere 2D-Karten von $w."

    log "Generiere 2D-Karte $w"
    gen2draw $w $rawdir $size
    mcs "Generierung der Karte von $w abgeschlossen."

    log "Generiere Rasterkarte $w"
    raster2d $rawdir $size
    mcs "Generierung der Rasterkarte von $w abgeschlossen."

    if [[ $extendedmaps == true ]]; then
        log "Generiere Grenzkarte $w"
        project2d $rawdir $size $projlayer
        mcs "Generierung der Grenzkarte von $w abgeschlossen."

        log "Generiere Safezone-Karte $w"
        gen2dsafezones $rawdir $size $szlist
        mcs "Generierung der Safezone-Karte von $w abgeschlossen."

        log "Generiere Bahnkarte $w"
        gen2drail $w $rawdir $size $raillayer
        mcs "Generierung der Bahnkarte von $w abgeschlossen."
    fi
    
    mcsd "Generierung der 2D-Karten von $w abgeschlossen."
}

# Generates all daily maps with backup
fullgen(){
    log "Kartenscript gestartet"
    
    # return value used to calculation if any played the day, so no per function is used!
    playerdatadate=$(stat -c "%Y" "$origworlddir/playerdata/")
    playerdata2date=$(stat -c "%Y" "$origworld2dir/playerdata/")
    yesterday=$(date -d "24 hours ago" +%s)
    #if [[ $yesterday -ge $playerdatadate ]] && [[ $(date '+%d') != 01 ]]; then
    if ([[ $yesterday -ge $playerdatadate ]] || [[ $yesterday -ge $playerdata2date ]]) && [[ $(date '+%d') != 01 ]]; then
        log "Letzter Spieler offline am $(stat -c "%y" "$dailydir/$world/playerdata/")."
        log "Breche Kartenscript ab, da Datum vor $(date -d "24 hours ago")."
        return
    fi
    
    mcsd "Kartenscript wurde gestartet!"

    init_kickall
    if [[ $(date '+%u') == 1 ]]; then
        trim $world $worldmax
        per sleep 10
        trim $world2 $world2max
        per sleep 10
    fi
    trim $worldc $worldcmax

    log "Beende Minecraft"
    per $initscript stop -f
    per sleep 10
    backups
    log "Starte Minecraft"
    per $initscript start
    per sleep 10
    #trim_backups
    #per sleep 10

    log "Beginne mit Kartengenerierung"

    gen2d $world $worldmax true
    gen2d $world2 $world2max true
    gen2d $worldc $worldcmax false
    
    if [[ $(date '+%d') == 01 ]]; then
        log "Nutze Overviewer mit --check-tiles"
        ovChecktiles="ct"
    fi

    mcsd "Generiere Overviewer."
    overviewer $ovworldcfg $ovChecktiles
    overviewer $ovworldcfg poi
    mcs "Overviewer generiert."

    mcsd "Generierung aller Karten abgeschlossen!"
    log "Generierung aller Karten abgeschlossen"
}

print_help(){
cat << EOM
Usage: $0 [OPTIONS] COMMAND [args]

Options:
  -h, --help        Print help message
  -n, --nomc        Disables log messages to minecraft
  -q, --quiet       Disables log messages to stdout
  -f, --fileecho    Echos all log messages only to logfile
  -s, --simulate    Simulate execution, includes -n

Commands:
  rendersvg <src> <dest>            Renews layer render and composites
                                      with 5k raster if src is newer than dest

  backup                            Creates automatic backups
  trim <world>                      Trims world in minecraft

  overviewer <config> <options>     Renews overviewer, config file without .py!
                                      Possible options:
                                        ct: --chek-tiles option for OV
                                        poi: generate POIs instead of the map
  tmcmr <world> [colormap subdir]   Renews 2D map, optionally using colormap
                                      and to world subdir as destination

  daily                             Generates all daily maps. Only executes if
                                      anyone was online in the last 24h.
  daily <world> <worldsize> [extended]
                                    Generates all daily 2D maps for the world,
                                      worldsize is the max coordinates value,
                                      set extended true more than raw/raster.

                                    For all following gen commands:
                                      worldmapsdir must be full base path for
                                      the world like maps.minecracy.de/world5.
                                      worldsize is the max coordinates value.

  gen raw <world> <worldmapsdir> <worldsize>
                                    Generates raw map of world to worldmapsdir.

  gen raster <worldmapsdir> <worldsize>
                                    Generates raster map in worldmapsdir.

  gen project <worldmapsdir> <worldsize> <projectlayer>
                                    Generates project map in worldmapsdir.
                                      projectlayer is full path to layer svg
                                      file WITHOUT file extension (eg. ".svg").

  gen sz <worldmapsdir> <worldsize> <residenceWorldfile>
                                    Generates safezone map in worldmapsdir.
                                      residenceWorldfile is full path to the
                                      world safe file from the Spigot plugin
                                      Residence with the residences inside.

  gen rail <world> <worldmapsdir> <worldsize> <railmaplayer>
                                    Generates railway map in worldmapsdir.
                                      railmaplayer is full path to layer file
                                      file WITHOUT file extension (eg. ".svg").
EOM
  #trimbackup                        Trims all backups
}

command=
while [[ $# > 0 ]]; do
  case $1 in
    -h|--help)
        print_help
        exit
        ;;
    -n|--nomc)
        mcout="false"
        shift
        ;;
    -q|--quiet)
        quiet="true"
        shift
        ;;
    -f|--fileecho)
        cmdtofile="true"
        shift
        ;;
    -s|--simulate)
        simulate="true"
        mcout="false"
        shift
        ;;
    rendersvg)
        command="render_svgtoraster"
        shift
        break
        ;;
    backup)
        command="backups"
        shift
        break
        ;;
#    trimbackups)
#        command="trim_backups"
#        shift
#        break
#        ;;
    kickall)
        command="init_kickall"
        break
        ;;
    trim)
        command="trim"
        shift
        break
        ;;
    overviewer)
        command="overviewer"
        shift
        break
        ;;
    tmcmr)
        command="tmcmr"
        shift
        break
        ;;
    daily)
        shift
        if [[ -z $1 ]] ; then
            command="fullgen"
        else
            command="gen2d"
        fi
        break
        ;;
    gen)
        shift
        case $1 in
        raw)
            command="gen2draw"
            ;;
        raster)
            command="raster2d"
            ;;
        project)
            command="project2d"
            ;;
        rail)
            command="gen2drail"
            ;;
        sz)
            command="gen2dsafezones"
            ;;
        *)
            echo "$1: Unknown command or argument"
            print_help
            exit
            ;;
        esac
        shift
        break
        ;;
    *)
        echo "$1: Unknown command or argument"
        print_help
        exit
        ;;
  esac
done

if [[ -z $command ]]; then
  print_help
  exit
fi


$command "$@"

