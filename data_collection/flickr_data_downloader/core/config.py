# Author: Jared Heinly
# Email: jheinly@cs.unc.edu

import math
import os
import sys
import time
import random

# Flickr authentication information. Change these to your Flickr API key and secret.
keys=[ '52df479f651659f2f938081769b33d0b', 'ba38cf95b8bc28ce513957d92c4682e0', '1bafc820bfa1e73dca798916872ed3d1', 'a1b8f319603d9b94dda4f97945be2674', '41780cd5a3bd2f3c1d9f9a7348321b9e', '3fea4cb13670c4390d6e57284964555a', '02f68b13f6c8b732409460f26631cbb6']

secrets=[ 'd6bdbcacc2ddc007', 'ded98a7520abab09', '1d43b8e9ed785fad', 'efcc913fe4ac26d6', '58de2bc012a031f7', '0b42bef79775d346', '14b8baf68ffa88c0']

photo_extras = 'tags, original_format, license,  geo, date_taken, url_o, url_b, url_z, url_-, url_m, url_t, url_q, url_s'

random_key_index = int(random.random() * len(keys))
print (random_key_index)
flickrAPIKey = keys[random_key_index] # API key
flickrSecret = secrets[random_key_index]  # shared 'secret'

# Whether or not EXIF data should be queried and downloaded for each image.
getExifEnabled = True

# Whether or not thumbnails should be created for each image.
createThumbnailEnabled = False

# Whether or not the focal length of the image (in pixels) should be computed.
# NOTE - getExifEnabled must be set to True for this to work.
computeFocalEnabled = False

# startTime and endTime define the maximum range for photos that can be searched.
# The end time should be a day or two before the current time. In some cases it seems
# that querying too close to the current time causes Flickr to give empty results.
# WARNING - These values should not be changed during the course of downloading
#           an entire dataset. If they are changed, the time-ranges assigned to
#           each thread will be different causing duplicate images to be downloaded.
startTime = 1072915200 # 1/1/2004
endTime = 1300852535 # 3/22/2011

# numSearchDivisions defines the number of large divisions that will be made
# over the entire time range of the search (endTime - startTime). This is done
# so that the estimate of the density of the images for a given time can be updated
# more than once during the entire search
numSearchDivisions = 1024

# 
numThreadPerDivisions = 256

# numSearchThreads defines the number of threads that will be used to simultaneously
# download search-divisions
numSearchThreads = 16

# The maximum number of photo results per page. This value (500) is enforced
# by the flickr API.
maxPhotosPerPage = 500

# The target number of photos to be returned per page when calculating the queries.
targetPhotosPerPage = maxPhotosPerPage / 2

# The number of times to retry a flickr query before giving up.
numQueryRetries = 2

# The number of times to retry a flickr EXIF query before giving up.
numExifRetries = 1

# The amount of time to wait for the download to complete. The actual amount of
# time spent waiting will be longer because the FlickrDownloaderThread waits
# for the EXIF query to finish before starting the timer.
downloadTimeout = 60

# The amount of time to wait for the thumbnail to be created.
thumbnailTimeout = 30

# Maximum number of times a time range will be recursively split.
maxSplitAttempts = 3

# The dimensions for the square thumbnail that will be generated.
thumbnailSize = 128

# The number of images to store per folder.
imagesPerFolder = 250

# The extension to append to the end of the name of the completed files/folder.
completedExtension = '-completed'

# The extension to append to the end of the name of the log files/folder.
logExtension = '-log'

# The extension to append to the end of the name of the meta files/folder.
metaExtension = '-meta'

# Folder to use to store the image indices that each thread used.
indicesFolderName = 'indices'

# The extension to append to the end of the name of the indice files.
indicesExtension = '-indices'

# The command to run when invoking python. This can be changed to the absolute path of the
# python executable in case python is not on the system path.
PythonCommand = 'python'

# Construct the path to the CreateImageList.py file given this file's location.
CreateImageListPath = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'create_image_list.py')

# If set true, will download images.
download_image = True

# Set the maximum number of images, otherwise(set as -1) will download foldernum * image per folder images.
maxImages = -1;

# ----------------------------------------------------------------------------------
# This section performs checks on the settings as well as sets up global variables.

numDivisionDigits = 0
numIndexSkipDigits = 0
indexSkipPerFolder = 0


def check_config():
    global numSearchThreads
    global numSearchDivisions
    global numDivisionDigits
    global indexSkipPerFolder
    global numIndexSkipDigits
    global computeFocalEnabled
    global getExifEnabled
    global imagesPerFolder
    global WgetPath
    global CreateThumbnailPath
    global CreateImageListPath

    # Make sure that we don't have more threads than divisions to search.
    if numSearchDivisions < numSearchThreads:
        print('WARNING: numSearchDivisions = ' + str(numSearchDivisions) +
              ' and numSearchThreads = ' + str(numSearchThreads) +
              ', reducing numSearchThreads')
        numSearchThreads = numSearchDivisions

    # Subtract 1 from numSearchDivisions because we start at 0. For instance,
    # if we have numSearchDivisions=32 we only need values from 0-31.
    numDivisionDigits = math.floor(math.log10(numSearchDivisions - 1)) + 1

    # Subtract 1 from imagesPerFolder because we start at 0. For instance,
    # if imagesPerFolder equals 1000, we only need 3 digits because the
    # range is from 0-999.
    numIndexSkipDigits = math.floor(math.log10(imagesPerFolder - 1)) + 1
    
    # The difference between the starting indices of two consecutive folders.
    indexSkipPerFolder = round(math.pow(10, numIndexSkipDigits))

    if computeFocalEnabled and not getExifEnabled:
        print('ERROR: computeFocalEnabled is True but the required getExifEnabled is False')
        sys.exit(1)

    if not os.path.exists(CreateImageListPath):
        print('ERROR: could not find "' + CreateImageListPath + '"')
        sys.exit(1)

check_config()
