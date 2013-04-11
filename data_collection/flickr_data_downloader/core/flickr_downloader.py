# Author: Jared Heinly
# Email: jheinly@cs.unc.edu

# USAGE: FlickrDownloader.py <queryFile> <pcdbFile> <outputDir> [configFile]
#   This script expects 3 or 4 arguments. The first argument, queryFile, specifies
#   the location of the file that contains the Flickr query to execute. The second
#   argument, pcdbFile, specifies the location of a database file (in PCDB format)
#   that contains the target locations for the downloaded images and thumbnails.
#   The third argument, outputDir, specifies the director where the meta, log, and
#   completed image list files/folders will be created. The last (and optional)
#   argument is configFile. This specifies a file that contains settings which
#   will override the default values provided in config.py.

def usage():
    print('USAGE: FlickrDownloader.py <queryFile> <pcdbFile> <outputDir> [configFile]')
    print('         queryFile  [required] - the name of the file containing the Flickr')
    print('                                 query to execute')
    print('         pcdbFile   [required] - the name of the PCDB database file containing')
    print('                                 the target locations of the downloaded images')
    print('                                 and thumbnails')
    print('         outputDir  [required] - the directory to which output files/folders')
    print('                                 will be written')
    print('         configFile [optional] - the name of a file which contains settings')
    print('                                 that will override the default values')

import json
import os
import subprocess
import sys
import threading
import time

import config
import helper
from pcdb import PCDB
from flickr_downloader_thread import FlickrDownloaderThread

def computeStartingIndex(indicesPath):
    listFiles = os.listdir(indicesPath)
    extension = config.indicesExtension + '.txt'
    maxIndex = -1
    for fileName in listFiles:
        if not fileName[-len(extension):] == extension:
            continue
    
        file = open(indicesPath + '/' + fileName, 'r')
        
        for line in file:
            if len(line) > 0:
                index = int(line)
                if index > maxIndex:
                    maxIndex = index
        file.close()
    
    return maxIndex + 1

def createThread(threadIndex, queryString, pcdbFileName, outputDir):
    
    paddedNum = ('%0' + str(config.numDivisionDigits) + 'd') % threadIndex
    minTime = helper.interpolate(threadIndex, config.numSearchDivisions,
                                 config.startTime, config.endTime)
    maxTime = helper.interpolate(threadIndex + 1, config.numSearchDivisions,
                                 config.startTime, config.endTime)
    return FlickrDownloaderThread(queryString, pcdbFileName,
                                  minTime, maxTime,
                                  outputDir, paddedNum)

def waitForThreads(activeThreads, secondsPerThread):
    for processNum in range(0, config.numSearchThreads):
        # If a process actually exists
        if activeThreads[processNum] != None:
            # If the process is still running
            if activeThreads[processNum].isAlive():
                # Wait 1 second for the thread to finish if it is still running
                activeThreads[processNum].join(secondsPerThread)

def stopThreads(activeThreads):
    for processNum in range(0, config.numSearchThreads):
        # If a process actually exists
        if activeThreads[processNum] != None:
            # If the process is still running
            if activeThreads[processNum].isAlive():
                activeThreads[processNum].stop()
    waitForThreads(activeThreads, 1)

