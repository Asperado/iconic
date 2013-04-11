import json
import os
import subprocess
import sys
import threading
import time

from flickr_downloader import *
import config
import helper
from pcdb import PCDB
from flickr_downloader_thread import FlickrDownloaderThread

def downloadQuery(queryString, configFileName, pcdbFileName, outputDir, download_division_id):
    pcdbFileName = helper.removeQuotes(pcdbFileName)
    outputDir = helper.removeQuotes(outputDir)    
    
    # Check that the first three arguments specify valid paths.
    if not os.path.exists(pcdbFileName):
        print('ERROR: could not find PCDB file "' + pcdbFileName + '"')
        sys.exit(1)
    if not os.path.exists(outputDir):
        print('ERROR: could not find output directory "' + outputDir + '"')
        sys.exit(1)
    
    if not os.path.exists(configFileName):
        print('ERROR: could not find config file "' + configFileName + '"')
        sys.exit(1)
    else:
        # Read the config file.
        configFile = open(configFileName, 'r')
    
        for line in configFile:
            line = line.strip()
            if len(line) == 0:
                continue
            
            # Skip over comments.
            if line[0] == '#':
                continue
            
            splitLine = line.split(':')
            if len(splitLine) != 2:
                continue
            
            tag = splitLine[0].strip()
            value = splitLine[1].strip()
            
            if len(tag) == 0 or len(value) == 0:
                continue
            
            if tag == 'startTime':
                config.startTime = int(value)
                print('startTime read from config file...')
            elif tag == 'endTime':
                config.endTime = int(value)
                print('endTime read from config file...')
            elif tag == 'numSearchDivisions':
                config.numSearchDivisions = int(value)
                print('numSearchDivisions read from config file...')
            elif tag == 'numSearchThreads':
                config.numSearchThreads = int(value)
                print('numSearchThreads read from config file...')
            elif tag == 'thumbnailSize':
                config.thumbnailSize = int(value)
                print('thumbnailSize read from config file...')
            elif tag == 'imagesPerFolder':
                config.imagesPerFolder = int(value)
                print('imagesPerFolder read from config file...')
            elif tag == 'getExifEnabled':
                config.getExifEnabled = (value.lower() == 'true')
                print('getExifEnabled read from config file...')
            elif tag == 'createThumbnailEnabled':
                config.createThumbnailEnabled = (value.lower() == 'true')
                print('createThumbnailEnabled read from config file...')
            elif tag == 'computeFocalEnabled':
                config.computeFocalEnabled = (value.lower() == 'true')
                print('computeFocalEnabled read from config file...')
            elif tag == 'maxImages':
                config.maxImages = int(value)
            
        configFile.close()
        config.check_config()
   
    
    if len(queryString) == 0:
        print('ERROR: no query string found in query file')
        sys.exit(1)
    
    basePathName = outputDir + '/' + helper.replaceSpaces(queryString)
    metaPath = basePathName + config.metaExtension
    completedPath = basePathName + config.completedExtension
    logPath = basePathName + config.logExtension
    indicesPath = logPath + '/' + config.indicesFolderName
    
    # Create the meta/log/completed folders if the don't already exist.
    if not os.path.exists(metaPath):
        os.mkdir(metaPath)
    if not os.path.exists(completedPath):
        os.mkdir(completedPath)
    if not os.path.exists(logPath):
        os.mkdir(logPath)
    if not os.path.exists(indicesPath):
        os.mkdir(indicesPath)
    
    pcdb = PCDB(pcdbFileName)
    
    settingsFileName = logPath + '/settings.txt'
    
    # Check to see if existing settings have been written to file.
    if os.path.exists(settingsFileName):
        settingsFile = open(settingsFileName, 'r')
        
        # Iterate through the existing settings and check to see if any have changed.
        settingsChanged = False
        pcdbChanged = False
        for line in settingsFile:
            line = line.strip()
            if len(line) == 0:
                continue
            
            colon = line.find(':')
            if colon == -1:
                continue
            
            tag = line[:colon].strip()
            value = line[colon+1:].strip()
            
            if len(tag) == 0 or len(value) == 0:
                continue
            
            if tag == 'queryString':
                if value != queryString:
                    print('')
                    print('WARNING: queryString value has changed!')
                    settingsChanged = True
            elif tag == 'startTime':
                if int(value) != config.startTime:
                    print('')
                    print('WARNING: startTime value has changed!')
                    settingsChanged = True
            elif tag == 'endTime':
                if int(value) != config.endTime:
                    print('')
                    print('WARNING: endTime value has changed!')
                    settingsChanged = True
            elif tag == 'numSearchDivisions':
                if int(value) != config.numSearchDivisions:
                    print('')
                    print('WARNING: numSearchDivisions value has changed!')
                    settingsChanged = True
            elif tag == 'thumbnailSize':
                if int(value) != config.thumbnailSize:
                    print('')
                    print('WARNING: thumbnailSize value has changed!')
                    settingsChanged = True
            elif tag == 'imagesPerFolder':
                if int(value) != config.imagesPerFolder:
                    print('')
                    print('WARNING: imagesPerFolder value has changed!')
                    settingsChanged = True
            elif tag == 'getExifEnabled':
                if value != str(config.getExifEnabled):
                    print('')
                    print('WARNING: getExifEnabled value has changed!')
                    settingsChanged = True
            elif tag == 'createThumbnailEnabled':
                if value != str(config.createThumbnailEnabled):
                    print('')
                    print('WARNING: createThumbnailEnabled value has changed!')
                    settingsChanged = True
            elif tag == 'computeFocalEnabled':
                if value != str(config.computeFocalEnabled):
                    print('')
                    print('WARNING: computeFocalEnabled value has changed!')
                    settingsChanged = True
            elif tag == 'pcdb' and not pcdbChanged:
                dot = value.find('.')
                dirName = value[:dot]
                value = value[dot+1:]
                
                equal = value.find('=')
                varName = value[:equal]
                value = value[equal+1:]
                
                if json.loads(value) != getattr(pcdb.dirs[dirName], varName):
                    print('')
                    print('WARNING: pcdb has changed!')
                    settingsChanged = True
                    pcdbChanged = True
        
        settingsFile.close()
        
        if settingsChanged:
            print('Continue? (y/n)')
            answer = input().strip().lower()
            if answer not in ('y', 'yes'):
                sys.exit(0)
            print('')
    
    # Write the current settings to file.
    settingsFile = open(settingsFileName, 'w')
    settingsFile.write('queryString: ' + queryString + '\n')
    settingsFile.write('startTime: ' + str(config.startTime) + '\n')
    settingsFile.write('endTime: ' + str(config.endTime) + '\n')
    settingsFile.write('numSearchDivisions: ' + str(config.numSearchDivisions) + '\n')
    settingsFile.write('thumbnailSize: ' + str(config.thumbnailSize) + '\n')
    settingsFile.write('imagesPerFolder: ' + str(config.imagesPerFolder) + '\n')
    settingsFile.write('getExifEnabled: ' + str(config.getExifEnabled) + '\n')
    settingsFile.write('createThumbnailEnabled: ' + str(config.createThumbnailEnabled) + '\n')
    settingsFile.write('computeFocalEnabled: ' + str(config.computeFocalEnabled) + '\n')
    for key in pcdb.dirs:
        settingsFile.write('pcdb: ' + key + '.extension=' + json.dumps(pcdb.dirs[key].extension) + '\n')
        settingsFile.write('pcdb: ' + key + '.divisions=' + json.dumps(pcdb.dirs[key].divisions) + '\n')
        settingsFile.write('pcdb: ' + key + '.folders=' + json.dumps(pcdb.dirs[key].folders) + '\n')
    settingsFile.close()
    
    print('Query String: ' + queryString)
    print('')
    
    pcdb.checkDirExistence(PCDB.imageKey)
    if config.createThumbnailEnabled:
        pcdb.checkDirExistence(PCDB.thumbnailKey)
    
    # Create the folder structures for the image and thumbnail downloads.
    print('Creating folders...')
    numImageFoldersCreated = pcdb.createFolders(PCDB.imageKey)
    print(str(numImageFoldersCreated) + ' image folders created')
    numImageFoldersCreated = pcdb.createFolders(PCDB.meta)
    print(str(numImageFoldersCreated) + ' meta folders created')
    if config.createThumbnailEnabled:
        numThumbnailFoldersCreated = pcdb.createFolders(PCDB.thumbnailKey)
        print(str(numThumbnailFoldersCreated) + ' thumbnail folders created')
    print('')
    
    maxImageIndex = pcdb.getNumFolders(PCDB.imageKey)
    if config.createThumbnailEnabled:
        maxImageIndex = min(maxImageIndex, pcdb.getNumFolders(PCDB.thumbnailKey))
    maxImageIndex *= config.imagesPerFolder
    FlickrDownloaderThread.globalMaxImageIndex = maxImageIndex
    print('Maximum image index: ' + str(FlickrDownloaderThread.globalMaxImageIndex))
    print('')

    if (config.maxImages != -1):
        print('Set max images as ' + str(config.maxImages))
        FlickrDownloaderThread.globalMaxImageIndex = config.maxImages

    global_image_index = computeStartingIndex(indicesPath)
    if global_image_index >= FlickrDownloaderThread.globalMaxImageIndex:
        print('MAXIMUM IMAGE INDEX REACHED')
        sys.exit(0)
        
    try:
        next_search_thread_id = download_division_id * config.numThreadPerDivisions;
        activeThreads = [None] * config.numSearchThreads

        FlickrDownloaderThread.globalImageIndex = global_image_index
        print('Starting at image index: ' + str(FlickrDownloaderThread.globalImageIndex))

        for i in range(0, config.numSearchThreads):
            processNum = next_search_thread_id
            next_search_thread_id = next_search_thread_id + 1;
            print('Starting thread: ' + str(processNum))
            print('')
            activeThreads[i] = createThread(processNum, queryString, pcdbFileName, outputDir)
        
        for i in range(0, config.numSearchThreads):
            activeThreads[i].start()
            time.sleep(1)

    
        numCompleted = 0
        numStarted = config.numSearchThreads
        # While all of the processes have not finished
        while numCompleted < config.numThreadPerDivisions:
            # Iterate over the active processes
            for processNum in range(0, config.numSearchThreads):
                # If a process actually exists
                if activeThreads[processNum] != None:
                    # If the process is finished
                    if not activeThreads[processNum].is_alive():
                        numCompleted += 1
                        activeThreads[processNum] = None
                        if numStarted < config.numSearchDivisions:
                          print('Starting thread: ' + str(numStarted))
                          print('')
                          activeThreads[processNum] = createThread(next_search_thread_id, queryString, pcdbFileName, outputDir)
                          activeThreads[processNum].start()
                          next_search_thread_id = next_search_thread_id + 1
                          numStarted += 1
                          time.sleep(1)
                    
            time.sleep(5)
            index = activeThreads[0].getImageIndex()
            if index >= FlickrDownloaderThread.globalMaxImageIndex:
                print('')
                print('MAXIMUM IMAGE INDEX REACHED')
                print('Stopping threads...')
                waitForThreads(activeThreads, 2)
                stopThreads(activeThreads)
                break
                
    except KeyboardInterrupt:
        print('')
        print('KEYBOARD INTERRUPT')
        print('Stopping threads...')
        print('')
        stopThreads(activeThreads)
        subprocess.call([config.PythonCommand,
                         config.CreateImageListPath,
                         completedPath])
        sys.exit(1)
    
    subprocess.call([config.PythonCommand,
                     config.CreateImageListPath,
                     completedPath])
    

