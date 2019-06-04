#!/usr/bin/env python2
# -*- coding: UTF-8 -*-

import sys
import time
import datetime
import math

from PIL import Image

####################################
### Config #########################

# minimale Länge einer Strecke, die dargestellt wird
MIN_TRACK = 100

# Farbpalette; Form: (R,G,B,A)
COLORS = [
    #(0,189,9,255), # grün
    #(8,0,111,255), # flugghisch blau
    (142, 2, 2, 255)  # flugghisch rot
    ]

# Pinseldurchmesser; muss ungerade sein (wird im Zweifel aufgerundet)
C_SIZE = 13

# %-Schrittweite für Fortschrittsanzeige; 0 für keine
PERCENTAGE = 10

# Kein Status-Output falls True
QUIET = False

#####################################

img = None
israilcounter = 0


def main(argv):
    if len(argv) <= 1:
        usage(argv)
        return
        
    global img
    tracks = []
    now = int(time.time())
    
    img = Image.open(argv[1])
    if len(argv) == 2:
        output = argv[1]
    else:
        output = argv[2]

    log("Lese Bahnkarte ein")
    
    for i in xrange(0, img.size[0]):
        progress(i, img.size[0])
        for j in xrange(0, img.size[1]):
            if is_rail((i, j)):
                p = (i, j)
                found = False
                for track in tracks:
                    if track.is_inside(p):
                        found = True

                # neuer Track
                if not found:
                    t = Track(p)
                    if t.length() < MIN_TRACK:
                        t.remove()
                        del t
                    else:
                        tracks.append(t)

    log("Kurze Strecken entfernt, bemale verbliebene")
    colors = Colors()
    for track in tracks:
        c = colors.nextcolor()
        track.colorize(c)

    log("Speichere Karte")
    img.save(output)
    i = 0
    for track in tracks:
        i += 1
        j = 0
        j += len(track.subtracks)

    diff = int(time.time()) - now
    diff = datetime.datetime.fromtimestamp(diff).strftime('%M:%S')
    log(diff + " benötigt.")


def usage(argv):
    print("Usage: "+argv[0] + " SCHIENENKARTE [OUTPUT]")
    print()
    print("Entfernt kurze Schienenstücke und zeichnet übrig bleibende nach.")
    print("Konfigurationsoptionen befinden sich am Anfang des Skripts.")


# Generator für die Blickrichtung (direction) sowie
# links und rechts davon.
def heading_towards(direction):
    if direction == "o":
        dirs = ["o", "l", "r"]
    elif direction == "l":
        dirs = ["l", "u", "o"]
    elif direction == "u":
        dirs = ["u", "r", "l"]
    elif direction == "r":
        dirs = ["r", "o", "u"]
    else:
        raise Exception("unknown direction: '" + str(direction)+"'")
        
    for direction in dirs:
        yield direction


# Liefert von current aus den nächsten Punkt in richtung direction.
# IndexError falls dieser nicht im Bild ist.
def next_point(current, direction):
    global img
    dirs = {"o": (0, -1),
            "l": (-1, 0),
            "u": (0, 1),
            "r": (1, 0)}
    nextp = map(lambda x, y: x + y, current, dirs[direction])
    nextp = (nextp[0], nextp[1])
    if (nextp[0] < 0 or nextp[1] < 0 or nextp[0] >= img.size[0]
            or nextp[1] >= img.size[1]):
        p = "(" + str(nextp[0]) + "," + str(nextp[1]) + ")"
        raise IndexError(p + ": point out of image")
    else:
        return nextp


# Entscheidet ob an point eine Schiene liegt.
def is_rail(point):
    global israilcounter
    israilcounter += 1
    global img
    try:
        px = img.getpixel(point)
    # point nicht im bild
    except Exception:
        return False
        
    # transparentes oder schwarzes feld
    if (px[3] == 0 or (px[0] == 0 and px[1] == 0 and px[2] == 0)):
        return False
    else:
        return True


def counterdir(direction):
    if direction == "o":
        return "u"
    if direction == "l":
        return "r"
    if direction == "u":
        return "o"
    if direction == "r":
        return "l"


def is_in_parts(point, parts):
    for part in parts:
        if part[0][0] == part[1][0]:
            c = 0
        else:
            c = 1
        if (point[c] == part[0][c]
                and min(part[0][1-c], part[1][1-c]) <= point[1-c] <= max(part[0][1-c], part[1][1-c])):
            return True
    return False


# Fortschrittsanzeige
def progress(i, full):
    global PERCENTAGE
    p = PERCENTAGE
    if p == 0:
        return
    if i == full:
        log("100% eingelesen")

    if (i*100/full) % p == 0 and (((i-1)*100)/full) % p != 0:
        log(str((i*100)/full) + "% eingelesen")


def log(msg):
    global QUIET
    if not QUIET:
        print(msg)


# Generator für die Punkte in einem Quadrat mit Durchmesser d
# um den Punkt p
def square(d, p):
    r = abs(d/2)
    for i in xrange(p[0]-r, p[0]+r + 1):
        for j in xrange(p[1]-r, p[1]+r + 1):
            yield (i, j)


def circle(d, p):
    r = abs(d/2)
    for i in xrange(p[0]-r, p[0]+r + 1):
        for j in xrange(p[1]-r, p[1]+r + 1):
            w = abs(i - p[0]) - 0.25
            h = abs(j - p[1]) - 0.25
            if math.sqrt(w*w + h*h) <= r:
                yield(i, j)


def cursortest(cursor, d, output=None):
    global COLORS
    if not output:
        output = "cursortest.png"
    offset_x = 2
    offset_y = 0
    imgsize = d + 6
    image = Image.new("RGBA", (imgsize, imgsize), (255, 0, 0, 0))

    center = (d // 2 + 1 + 2 + offset_x, d // 2 + 1 + 2 + offset_y)
    for pixel in cursor(d, center):
        image.putpixel(pixel, COLORS[0])

    image.putpixel(center, (0, 0, 0, 255))

    image.save(output, "PNG")


# Farbpaletten-"Iterator"
class Colors(object):
    
    def __init__(self):
        global COLORS
        self.colors = COLORS
        self.index = -1
        self.size = len(self.colors)

    def nextcolor(self):
        self.index = (self.index + 1) % self.size
        return self.colors[self.index]


# Ein zusammenhängendes Stück Schienen
class Track(object):

    def __init__(self, start):
        # Auswahl der Pinselfunktion. Wir haben circle und square.
        self.brush = circle

        # Ein Subtrack ist eine Liste von Streckenparts. Sie repräsentiert
        # das Stück Strecke zwischen zwei Abzweigungen.
        # Ein Streckenpart ist eine Liste mit dem Anfangs- und dem
        # Endpunkt einer Geraden.
        self.subtracks = []

        # Startpunkte suchen
        found = []
        for direc in ["o", "l", "u", "r"]:
            try:
                cond = is_rail(next_point(start, direc))
            except IndexError:
                cond = False
            if cond:
                found.append(direc)

        # Einzelne Schiene
        if len(found) == 0:
            self.subtracks = [[[start, start]]]
            return
                
        for startdir in found:
            self.build_subtracks(start, start, startdir)

    # Füllt self.subtracks.
    # point = start, wird für Kreischeck in der Rekursion benötigt
    def build_subtracks(self, start, point, direction):
        # Kreis direkt nach Rekursion bzw. Abzweig
        if self.is_inside(point):
            return
            
        current = point
        partstart = point
        parts = []
        while True:
            # Sucht Nachbarn
            found = []
            for direc in heading_towards(direction):
                try:
                    np = next_point(current, direc)
                except IndexError:
                    continue
                if is_rail(np) and not self.is_inside(np):
                    found.append(direc)

            # Ende der Strecke
            if len(found) == 0:
                parts.append([partstart, current])
                self.subtracks.append(parts)
                return

            # Keine Abzweigung
            if len(found) == 1:
                # Keine Kurve
                if found[0] == direction:
                    current = next_point(current, direction)

                # Kurve
                else:
                    # Kreis
                    if is_in_parts(current, parts):
                        return
                    parts.append([partstart, current])
                    direction = found[0]
                    current = next_point(current, direction)
                    partstart = current
                    
                continue

            # Abzweigung, Subtrack eintragen, Rekursion
            else:
                parts.append([partstart, current])
                self.subtracks.append(parts)
                for direc in found:
                    np = next_point(current, direc)
                    self.build_subtracks(start, np, direc)
                return

    # Generator für alle Punkte im Track
    def points(self):
        for st in self.subtracks:
            for part in st:
                if part[0][0] == part[1][0]:
                    c = 1
                elif part[0][1] == part[1][1]:
                    c = 0
                else:
                    s1 = "("+str(part[0][0])+","+str(part[0][1])+")"
                    s2 = "("+str(part[1][0])+","+str(part[1][1])+")"
                    raise Exception(s1+","+s2+" isn't a part")

                if part[0][c] < part[1][c]:
                    inf = part[0][c]
                    sup = part[1][c]
                else:
                    inf = part[1][c]
                    sup = part[0][c]
                    
                for i in xrange(inf, sup+1):
                    if c == 0:
                        yield (i, part[0][1])
                    else:
                        yield (part[0][0], i)

    # Entfernt diesen Track aus dem Bild.
    def remove(self):
        global img
        for point in self.points():
            img.putpixel(point, (0, 0, 0, 0))

    # Malt die Schienen vernünftig
    def colorize(self, color):
        global C_SIZE
        global img

        for point in self.points():
            for pixel in self.brush(C_SIZE, point):
                if 0 <= pixel[0] < img.size[0] and 0 <= pixel[1] < img.size[1]:
                    img.putpixel(pixel, color)

    def is_inside(self, point):
        for st in self.subtracks:
            if is_in_parts(point, st):
                return True
        return False

    def length(self):
        r = 0
        for st in self.subtracks:
            for part in st:
                if part[0][0] == part[1][0]:
                    c = 1
                else:
                    c = 0
                r += abs(part[0][c] - part[1][c])+1
        return r

if __name__ == "__main__":
    main(sys.argv)
