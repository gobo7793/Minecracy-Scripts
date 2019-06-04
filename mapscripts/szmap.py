#!/usr/bin/env python3

import sys
import yaml
from PIL import Image


# CONFIG #######
MAP_DIMENSIONS = (10016, 10016)
MAP_CENTER = (MAP_DIMENSIONS[0] // 2, MAP_DIMENSIONS[1] // 2)
COLORS = [
    #(0,189,9,255), # grün - sieht man nicht gut bei so viel wald und wiesen
    #(0,170,255,255), # hellblau - zu hell
    #(255,208,0,255), # gelb - sieht man auf Wüste nicht gut
    #(159, 0, 157, 255), # lila - okay
    #(80,80,80,255), # grau - sieht man ja gar nicht
    #(0,0,0,255), # schwarz - etwas besser, aber auch eher kaum
    #(8,0,111,255), # flugghisch blau - blau sieht man nicht gut
    (142, 2, 2, 255),  # flugghisch rot
    ]
ALPHA_PER_LAYER = 100

# Kein Status-Output falls True
QUIET = False

################


def log(msg, level="info"):
    global QUIET
    if QUIET:
        return
    elif level == "info":
        print(msg)


def main(argv):
    if len(argv) <= 2:
        usage(argv)
        return

    residence_config = argv[1]
    output = argv[2]

    f = None
    try:
        f = open(residence_config, "r")
    except FileNotFoundError:
        log("File not found: " + residence_config + ". Abort.", "error")
        exit(1)
    except IOError:
        log("Error reading " + residence_config + ". Abort.")
        exit(1)

    res_cfg = yaml.safe_load(f)
    f.close()

    residences = {}
    for res in res_cfg["Residences"]:
        areas = []
        for area in res_cfg["Residences"][res]["Areas"]:
            areas.append(res_cfg["Residences"][res]["Areas"][area])
        residences[res] = areas

    img = Image.new("RGBA", MAP_DIMENSIONS, (0, 0, 0, 0))
    draw_safezones(residences, img)
    img.save(output)


def rectangle(area):
    """Generator für die Punkte in einer SZ-Area"""

    dim = MAP_DIMENSIONS
    x1 = min(area["X1"], area["X2"]) - 2
    x2 = max(area["X1"], area["X2"]) - 1
    z1 = min(area["Z1"], area["Z2"]) + 1
    z2 = max(area["Z1"], area["Z2"]) + 2
    for i in range(x1, x2):
        for j in range(z1, z2):
            x = MAP_CENTER[0] + i
            y = MAP_CENTER[1] + j
            if x < 0 or x > dim[0] or y < 0 or y > dim[1]:
                continue

            alpha = ALPHA_PER_LAYER
            # border
            if i == x1 or i == x2-1 or j == z1 or j == z2-1:
                alpha = 255

            yield x, y, alpha


def draw_safezones(safezones, img):
    color_i = -1
    for sz in safezones:
        color_i = (color_i + 1) % len(COLORS)
        color = COLORS[color_i]
        for area in safezones[sz]:
            for pixel in rectangle(area):
                alpha = img.getpixel((pixel[0], pixel[1]))[3]
                if alpha > 0:
                    alpha += pixel[2] // 2
                else:
                    alpha += pixel[2]
                if alpha > 255:
                    alpha = 255
                img.putpixel((pixel[0], pixel[1]), (color[0], color[1], color[2], alpha))


def usage(argv):
    print("Usage: "+argv[0] + " RESIDENCE_CONFIG OUTPUT")
    print("")
    print("Erstellt einen Kartenlayer zur Markierung von Safezones.")
    print("Konfigurationsoptionen befinden sich am Anfang des Skripts.")


if __name__ == "__main__":
    main(sys.argv)
