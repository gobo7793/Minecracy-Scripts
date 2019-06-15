import sys
import os

import cv2
import numpy as np

'''==============================
classification params
=============================='''
minimal_track_length = 100

'''==============================
image processing params
=============================='''
threshold_min = 1
threshold_max = 255

'''==============================
drawing params
=============================='''
contour_width = 5
color = (0,0,255,0)

'''==============================
usage
=============================='''
usage = '''Usage:\n\t{} path_to_original_image desired_path_to_output_image.'''.format(__file__)


'''==============================
functions
=============================='''

def getTrackImage(im,
                  minimal_track_length,
                  threshold_min,
                  threshold_max,
                  contour_width,
                  color):
    '''
    Return a track image.
    '''
    
    # apply thresholding
    _,thresh = cv2.threshold(im,
                             threshold_min,
                             threshold_max,
                             cv2.THRESH_BINARY)
    # obtain blob contours
    contours, _ = cv2.findContours(thresh,
                                   cv2.RETR_TREE,
                                   cv2.CHAIN_APPROX_SIMPLE)

    # calculate blob areas as a measure of track length
    areas = np.array([cv2.contourArea(c) for c in contours])

    # remove contours of too short tracks
    contours = np.delete(contours, np.where(areas < minimal_track_length)[0])

    # allocate final image
    im_r = np.zeros([im.shape[0], im.shape[1], 4])

    # draw final image
    im_r = cv2.drawContours(im_r, contours, -1, (0,0,255,255), contour_width)

    return im_r

if __name__ == '__main__':

    argv = sys.argv

    if len(argv) == 1:
        print(usage)

    else:
        path_to_input_image = argv[1]

        if len(argv) == 2:
            path_to_output_image = os.path.join(os.getcwd(), 'track_output.png')
        else:
            path_to_output_image = sys.argv[2]

        # read image
        im_input = cv2.imread(path_to_input_image, cv2.IMREAD_GRAYSCALE)

        track_image = getTrackImage(im_input,
                                    minimal_track_length,
                                    threshold_min,
                                    threshold_max,
                                    contour_width,
                                    color)   

        cv2.imwrite(path_to_output_image, track_image)
