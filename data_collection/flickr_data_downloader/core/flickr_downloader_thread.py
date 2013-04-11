# Author: Jared Heinly
# Email: jheinly@cs.unc.edu

import math
import os
import subprocess
import sys
import threading
import time

import config
import helper
from pcdb import PCDB
from photos_search import photos_search
from flickrapi import FlickrAPI
from photo_processor import is_valid_photo, extract_url, download_image, photo_to_string

class FlickrDownloaderThread(threading.Thread):

    globalImageIndex = 0
    globalMaxImageIndex = 0
    imageIndexLock = threading.Lock()

    def __init__(self, queryString, pcdbFileName,
                 startTime, endTime, outputDir, processNum):

        threading.Thread.__init__(self)
        
        self.shouldStop = False
        
        self.queryString = queryString
        self.startTime = startTime
        self.endTime = endTime

        if len(self.queryString) == 0:
            print('ERROR: FlickrDownloaderThread - no query string specified')
            sys.exit(1)
        if len(pcdbFileName) == 0:
            print('ERROR: FlickrDownloaderThread - no PCDB file name specified')
            sys.exit(1)
        if self.startTime == 0:
            print('ERROR: FlickrDownloaderThread - no start time specified')
            sys.exit(1)
        if self.endTime == 0:
            print('ERROR: FlickrDownloaderThread - no end time specified')
            sys.exit(1)
        if len(outputDir) == 0:
            print('ERROR: FlickrDownloaderThread - no output directory specified')
            sys.exit(1)
        if len(processNum) == 0:
            print('WARNING: FlickrDownloaderThread - no process number specified')

        self.processPrint = ''
        if len(processNum) > 0:
            self.processPrint = processNum + '> '

        self.pcdb = PCDB(pcdbFileName)

        # Main FlickrDownloader will create these folders.
        queryStringNoSpace = helper.replaceSpaces(self.queryString)
        basePathName = outputDir + '/' + queryStringNoSpace
        metaPath = basePathName + config.metaExtension
        completedPath = basePathName + config.completedExtension
        logPath = basePathName + config.logExtension
        indicesPath = logPath + '/' + config.indicesFolderName

        processBaseFileName = queryStringNoSpace + '-' + processNum
        metaFileName = metaPath + '/' + processBaseFileName + config.metaExtension + '.txt'
        self.metaFile = open(metaFileName, 'a')
        
        logFileName = logPath + '/' + processBaseFileName + config.logExtension + '.txt'
        self.logFile = open(logFileName, 'a')
        
        indicesFileName = indicesPath + '/' + processNum + config.indicesExtension + '.txt'
        self.indicesFile = open(indicesFileName, 'a')

        self.completedImages = set([])

        completedFileName = completedPath + '/' + processBaseFileName + config.completedExtension + '.txt'
        if os.path.exists(completedFileName):
            completedFile = open(completedFileName, 'r')
            for line in completedFile:
                line = line.strip()
                if len(line) > 0:
                    splitLine = line.split('_')
                    image_id = splitLine[1]
                    self.completedImages.add(int(image_id))
            completedFile.close()

        self.completedFile = open(completedFileName, 'a')
        
        self.flickrAPI = FlickrAPI(config.flickrAPIKey, config.flickrSecret)
        
        self.downloadTimer = None
        self.thumbnailTimer = None
        self.downloadProcess = None
        self.thumbnailProcess = None
        
        self.totalImagesQueried = 0
        self.totalCompletedImages = 0
        self.totalSkippedImages = 0
        self.totalBadURLs = 0
        self.totalDiscardedImages = 0
        self.totalFailedImages = 0
        self.totalEmptyQueries = 0

    def get_running_status(self, status_type):
        status = ''
        if (status_type == 1):
            status += self.processPrint + 'Total queried:   ' + str(self.totalImagesQueried) + '\n'
            status += self.processPrint + 'Total completed: ' + str(self.totalCompletedImages) + '\n'
            status += self.processPrint + 'Total skipped:   ' + str(self.totalSkippedImages) + '\n'
            status += self.processPrint + 'Total bad URLs:  ' + str(self.totalBadURLs) + '\n'
            status += self.processPrint + 'Total discarded: ' + str(self.totalDiscardedImages) + '\n'
            status += self.processPrint + 'Total failed:    ' + str(self.totalFailedImages) + '\n'
            status += self.processPrint + 'Empty queries:   ' + str(self.totalEmptyQueries) + '\n'
        if (status_type == 2):
            status += (self.processPrint + 'Current queried:   ' + str(self.current_num_images)) + '\n'
            status += (self.processPrint + 'Current completed: ' + str(self.currentCompletedImages)) + '\n'
            status += (self.processPrint + 'Curretn skipped:   ' + str(self.currentSkippedImages)) + '\n'
            status += (self.processPrint + 'Current bad URLs:  ' + str(self.currentBadURLs)) + '\n' 
            status += (self.processPrint + 'Current discarded: ' + str(self.currentDiscardedImages)) + '\n'
            status += (self.processPrint + 'Current failed:    ' + str(self.currentFailedImages)) + '\n'

        status += self.processPrint + 'Current Index: ' + str(FlickrDownloaderThread.globalImageIndex) + '\n'
        status += '\n'
        return status
    
    def run(self):
        status = self.get_running_status(1)
        print (status)

        self.queryTimeRange(self.startTime, self.endTime)

        self.logFile.write(status)
        self.completedFile.close()
        self.metaFile.close()
        self.logFile.close()
        self.indicesFile.close()
    
    def stop(self):
        self.shouldStop = True
        if self.downloadTimer != None:
            self.downloadTimer.cancel()
        if self.thumbnailTimer != None:
            self.thumbnailTimer.cancel()
        if self.downloadProcess != None:
            if self.downloadProcess.poll() == None:
                self.downloadProcess.terminate()
        if self.thumbnailProcess != None:
            if self.thumbnailProcess.poll() == None:
                self.thumbnailProcess.terminate()
    
    def exitThread(self):
        self.completedFile.close()
        self.metaFile.close()
        self.logFile.close()
        self.indicesFile.close()
        sys.exit(0)
    
    def getImageIndex(self):
        with FlickrDownloaderThread.imageIndexLock:
            index = FlickrDownloaderThread.globalImageIndex
        return index
    
    def incrementImageIndex(self):
        with FlickrDownloaderThread.imageIndexLock:
            index = FlickrDownloaderThread.globalImageIndex
            if index >= FlickrDownloaderThread.globalMaxImageIndex:
                self.shouldStop = True
            else:
                FlickrDownloaderThread.globalImageIndex += 1
                
        if self.shouldStop:
            self.exitThread()

        return index

    def queryTimeRange(self, minTime, maxTime, splitAttempts = 0):
        if self.shouldStop:
            self.exitThread()
        
        response = photos_search(minTime, maxTime, self, config.photo_extras)
        
        if response == None:
            if splitAttempts < config.maxSplitAttempts:
                # Try to split the query into two parts
                midTime = (minTime + maxTime) / 2
                self.queryTimeRange(minTime, midTime, splitAttempts + 1)
                self.queryTimeRange(midTime, maxTime, splitAttempts + 1)
            else:
                self.totalEmptyQueries += 1
            return
        
        numImages = helper.numImagesInResponse(response)
        
        # If chunk is too large and we still have split-attempts remaining, then split
        # the chunk into smaller queries.
        if numImages > config.maxPhotosPerPage and splitAttempts < config.maxSplitAttempts:
            self.splitQuery(numImages, minTime, maxTime, splitAttempts)

        # If the chunk is a valid size or we need to force it to its max sie because we
        # have reached the maximum number of splitting attempts.
        elif numImages > 0:
            self.handleResponse(response, numImages)

    def splitQuery(self, numImages, minTime, maxTime, splitAttempts):
        targetNumChunks = math.ceil(numImages / config.targetPhotosPerPage)
        for chunk in range(0, targetNumChunks):
            newMin = helper.interpolate(chunk, targetNumChunks, minTime, maxTime)
            newMax = helper.interpolate(chunk + 1, targetNumChunks, minTime, maxTime)
            self.queryTimeRange(newMin, newMax, splitAttempts + 1)

    def handleResponse(self, response, numImages):
        self.currentCompletedImages = 0
        self.currentSkippedImages = 0
        self.currentBadURLs = 0
        self.currentDiscardedImages = 0
        self.currentFailedImages = 0
        
        self.totalImagesQueried += numImages

        if numImages > config.maxPhotosPerPage:
            self.currentDiscardedImages += numImages - config.maxPhotosPerPage
            self.totalDiscardedImages += numImages - config.maxPhotosPerPage
        
        self.current_num_images = numImages

        for image in response[0]:
            if self.shouldStop:
                self.exitThread()
            
            if image != None:
                image = image.attrib
                image_id = str(image['id'])
                # Check to see if this image has already been successfully downloaded.
                if self.is_downloaded(image_id):
                    self.currentSkippedImages += 1
                    self.totalSkippedImages += 1
                    continue

                url = extract_url(image)
                if len(url) == 0:
                    self.currentBadURLs += 1
                    self.totalBadURLs += 1
                    continue

                if (not(self.isSupportedFormat(url))):
                    self.currentBadURLs += 1
                    self.totalBadURLs += 1
                    continue
                
                imageName = self.getImageName(image_id)
                imagePath = self.get_image_path(imageName)
                imagePath = self.replaceExtension(imagePath, url)
                if config.download_image:
                    download_image_done = download_image(url, imagePath)

                    if download_image_done != True:
                        self.logFile.write('ERROR: image download thread timed-out' + '\n')
                        self.currentFailedImages += 1
                        self.totalFailedImages += 1
                        self.downloadProcess = None
                        continue
                    self.downloadProcess = None
                
                    if config.createThumbnailEnabled:
                        thumbnailPath = self.getThumbnailPath(imageName)
                        success = self.createThumbnail(imagePath, thumbnailPath)
                    else:
                        if os.path.exists(imagePath) and os.path.getsize(imagePath) > 0:
                            success = True
                        else:
                            success = False
                else:
                    success = True
                
                # If the thumbnail was successfully created, write the meta data
                # data and log the success.
                if success:
                    image_meta_file_path = self.get_meta_path(imageName)
                    meta_file = open(image_meta_file_path, 'w')
                    meta_file.write('ID: ' + imageName + '\n')
                    meta_file.write(photo_to_string(image))
                    meta_file.write('\n')
                    meta_file.close()

                    self.metaFile.write('ID: ' + imageName + '\n')
                    self.writeMeta(image, url)
                    self.metaFile.write('\n')
                    self.currentCompletedImages += 1
                    self.totalCompletedImages += 1
                    self.completedFile.write(imageName + '\n')
                    print (self.get_running_status(0))
                else:
                    self.currentFailedImages += 1
                    self.totalFailedImages += 1
        current_status = self.get_running_status(2)
        self.logFile.write(current_status)
        print (current_status)
        

    def handleProcessTimeout(self, process):
        print('Terminating process...')
        process.terminate()
    
    def getImageName(self, image_id):
        index = self.incrementImageIndex()
        self.indicesFile.write(str(index) + '\n')
        
        imageNum = math.floor(index / config.imagesPerFolder) * config.indexSkipPerFolder \
                   + (index % config.imagesPerFolder)
        
        return self.pcdb.padNum(imageNum, 'image') + '_' + str(image_id)

    def isSupportedFormat(self, url):
        extension = self.extractExtension(url)
        extension = extension.lower()
        if extension != 'jpg' and extension != 'jpeg' and extension != 'png':
            return False;
        else:
            return True;

    def get_image_path(self, imageName):
        return self.pcdb.getPath(imageName, 'image')
    
    def get_meta_path(self, imageName):
        return self.pcdb.getPath(imageName, 'meta')

    def replaceExtension(self, imagePath, url):
        extension = self.extractExtension(url)
        extension = extension.lower()
        if extension != 'jpg' and extension != 'jpeg':
            dot = imagePath.rfind('.')
            imagePath = imagePath[:dot + 1]
            imagePath += extension
        return imagePath

    def extractExtension(self, name):
        dot = name.rfind('.')
        extension = ''
        index = dot + 1
        while index < len(name):
            if name[index].isalpha():
                extension += name[index]
            else:
                break
            index += 1
        return extension
        
    def getThumbnailPath(self, imageName):
        return self.pcdb.getPath(imageName, 'thumbnail')
        
    def writeMeta(self, photo, url):
        self.metaFile.write(photo_to_string(photo))

    def createThumbnail(self, imagePath, thumbnailPath):
        print ('Tumbnail not supported yet')

    def is_downloaded(self, image_id):
        return int(image_id) in self.completedImages
        
