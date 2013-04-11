# Author: Jared Heinly
# Email: jheinly@cs.unc.edu

import math
import os
import sys

import config

# This class stores information pertaining to a directory definition
# in a PCDB file.
class Dir:
    def __init__(self):
        self.extension = ''
        self.divisions = []
        self.folders = []
        self.nameSize = 0

class PCDB:
    # The directory keywords that are currently recognized.
    imageKey = 'image'
    thumbnailKey = 'thumbnail'
    siftKey = 'sift'
    meta = 'meta'
    recognizedNames = [imageKey, thumbnailKey, siftKey, meta]

    def __init__(self, pcdbFileName):
        self.dirs = {}
        
        pcdbFile = open(pcdbFileName, 'r')
        
        firstLine = True
        for line in pcdbFile:
            line = line.strip()
            if len(line) == 0:
                continue
            
            # Check to see if this is a PCDB file.
            if firstLine:
                if line == '#DB_VERSION_0':
                    firstLine = False
                else:
                    print('ERROR: unrecognized PCDB file format')
                    sys.exit(1)
                    
            # Ignore comments.
            if line[0] == '#':
                continue
            
            # Split the tokens based on whitespace.
            tokens = line.split()
            name = tokens[0].lower()
            
            if name in PCDB.recognizedNames:
                if tokens[1].lower() == 'dir':
                    self.dirs[name] = Dir()
                    self.dirs[name].extension = tokens[2]
                    numDivisions = int(tokens[3])
                    self.dirs[name].divisions = []
                    for i in range(numDivisions):
                        self.dirs[name].divisions.append(int(tokens[4 + i]))
                    self.dirs[name].nameSize = config.numIndexSkipDigits + sum(self.dirs[name].divisions)
                elif tokens[1].lower() == 'def':
                    # Split the line into 5 tokens (4 valid splits) so that the last part
                    # of the line (the file path) remains intact, and is not split by any
                    # spaces that it may contain.
                    tokens = line.split(None, 4)
                    lower = int(tokens[2])
                    upper = int(tokens[3])
                    if lower != len(self.dirs[name].folders):
                        print('ERROR: image folder divisions should be listed ' +
                              'in continuous, increasing order')
                        sys.exit(1)
                    for i in range(lower, upper + 1):
                        self.dirs[name].folders.append(tokens[4].strip())
    
    # Create all of the folders for the provided directory name.
    def createFolders(self, dirName):
        dirName = dirName.lower()
        if dirName not in PCDB.recognizedNames:
            print('ERROR: PCDB does not recognize directory name "' + dirName + '"')
            sys.exit(1)
        
        numFoldersCreated = 0
        
        for i in range(0, len(self.dirs[dirName].folders)):
            folder = self.dirs[dirName].folders[i]
            if not os.path.exists(folder):
                os.mkdir(folder)
                numFoldersCreated += 1
                
            if len(self.dirs[dirName].divisions) == 0:
                continue
                
            numDigits = self.dirs[dirName].divisions[0]
            paddedNum = ('%0' + str(numDigits) + 'd') % i
            path = os.path.join(folder, paddedNum)
            if not os.path.exists(path):
                os.mkdir(path)
                numFoldersCreated += 1
            
            numFoldersCreated += self.createFoldersRecursive(path, self.dirs[dirName].divisions[1:])
        return numFoldersCreated
    
    def createFoldersRecursive(self, folder, remainingDivisions):
        if len(remainingDivisions) == 0:
            return 0
        
        numDigits = remainingDivisions[0]
        numFolders = round(math.pow(10, numDigits))
        
        numFoldersCreated = 0
        
        for i in range(0, numFolders):
            paddedNum = ('%0' + str(numDigits) + 'd') % i
            path = os.path.join(folder, paddedNum)
            if not os.path.exists(path):
                os.mkdir(path)
                numFoldersCreated += 1
            numFoldersCreated += self.createFoldersRecursive(path, remainingDivisions[1:])
        return numFoldersCreated
    
    def padNum(self, imageNum, dirName):
        dirName = dirName.lower()
        if dirName not in PCDB.recognizedNames:
            print('ERROR: PCDB does not recognize directory name "' + dirName + '"')
            sys.exit(1)
        return ('%0' + str(self.dirs[dirName].nameSize) + 'd') % imageNum
    
    def getPath(self, imageName, dirName):
        dirName = dirName.lower()
        if dirName not in PCDB.recognizedNames:
            print('ERROR: PCDB does not recognize directory name "' + dirName + '"')
            sys.exit(1)
        
        if len(self.dirs[dirName].divisions) == 0:
            return self.dirs[dirName].folders[0] + '/' + imageName + '.' + self.dirs[dirName].extension
        
        splitName = imageName.split('_')
        currentName = splitName[0]
        
        divSize = self.dirs[dirName].divisions[0]
        prefixNum = int(currentName[0:divSize])
        path = self.dirs[dirName].folders[prefixNum] + '/'
        
        for i in range(0, len(self.dirs[dirName].divisions)):
            prefix = currentName[0:self.dirs[dirName].divisions[i]]
            path += prefix + '/'
            currentName = currentName[self.dirs[dirName].divisions[i]:]
        
        path += imageName + '.' + self.dirs[dirName].extension
        return path
    
    # Checks whether or not the provided directory name was specified in the PCDB file.
    def checkDirExistence(self, dirName):
        if dirName not in self.dirs:
            print('ERROR: no "' + dirName + '" directory was provided in the PCDB file')
            sys.exit(1)
        if len(self.dirs[dirName].folders) == 0:
            print('ERROR: no folders were defines for the "' + dirName + '" directory')
            sys.exit(1)
    
    # Get the total number of folders used by this PCDB for the given directory name.
    def getNumFolders(self, dirName):
        numFolders = len(self.dirs[dirName].folders)
        for div in range(1, len(self.dirs[dirName].divisions)):
            numSubFolders = round(math.pow(10, self.dirs[dirName].divisions[div]))
            numFolders *= numSubFolders
        return numFolders
    
    # This function allows you to iterate over all of the folders that will be used
    # to store files for the given directory key.
    def getFolderByIndex(self, index, dirName):
        dirName = dirName.lower()
        if dirName not in self.recognizedNames:
            print('ERROR: PCDB does not recognize directory name "' + dirName + '"')
            sys.exit(1)
        
        paddedNum = self.padNum(config.indexSkipPerFolder * index, dirName)
        path = self.getPath(paddedNum, dirName)
        return os.path.dirname(path)
