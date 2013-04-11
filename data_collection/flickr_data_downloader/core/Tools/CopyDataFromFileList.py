# Author: Jared Heinly
# Email: jheinly@cs.unc.edu
# Description: This script copies the images, thumbnails, and sift files for the
#              images listed in a provided image list. The files are copied
#              directly into the folders specified below.

from FlickrCode.PCDB import PCDB
import os
import shutil

fileList = open('C:/Documents and Settings/jheinly/Desktop/clock-imlist.txt', 'r')
pcdb = PCDB('C:/Documents and Settings/jheinly/Desktop/switzerland_pcdb.txt')
destinationFolder = 'C:/Documents and Settings/jheinly/Desktop/clock-data'

imageFolder = destinationFolder + '/images'
thumbFolder = destinationFolder + '/thumbnails'
siftFolder = destinationFolder + '/sift'

if not os.path.exists(imageFolder):
    os.mkdir(imageFolder)
if not os.path.exists(thumbFolder):
    os.mkdir(thumbFolder)
if not os.path.exists(siftFolder):
    os.mkdir(siftFolder)

for line in fileList:
    line = line.strip()
    if len(line) == 0:
        continue
    
    imagePath = pcdb.getPath(line, 'image')
    thumbPath = pcdb.getPath(line, 'thumbnail')
    siftPath = pcdb.getPath(line, 'sift')
    
    newImagePath = os.path.join(imageFolder, os.path.basename(imagePath))
    newThumbPath = os.path.join(thumbFolder, os.path.basename(thumbPath))
    newSiftPath = os.path.join(siftFolder, os.path.basename(siftPath))
    
    if os.path.exists(imagePath):
        shutil.copyfile(imagePath, newImagePath)
    else:
        print('Could not find: ' + imagePath)
    
    if os.path.exists(thumbPath):
        shutil.copyfile(thumbPath, newThumbPath)
    else:
        print('Could not find: ' + thumbPath)
    
    if os.path.exists(siftPath):
        shutil.copyfile(siftPath, newSiftPath)
    else:
        print('Could not find: ' + siftPath)
