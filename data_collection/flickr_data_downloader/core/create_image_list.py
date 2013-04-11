# Author: Jared Heinly
# Email: jheinly@cs.unc.edu

import sys
import os
import config

if len(sys.argv) < 2:
    print('ERROR: please specify the input folder path for the completed query folder')
    sys.exit(1)

completedFolder = sys.argv[1] # 0 is the command name
completedFolder = completedFolder.replace('"', '')

print('')
print('Processing completed folder: ' + completedFolder)

outputFileName = completedFolder[:-len(config.completedExtension)] + '-imlist.txt'
print('Writing to: ' + outputFileName)
print('')

outputFile = open(outputFileName, 'w')
listFiles = os.listdir(completedFolder)
imageSet = set([])

extension = config.completedExtension + '.txt'

for fileName in listFiles:
    if not fileName[-len(extension):] == extension:
        continue
    
    file = open(completedFolder + '/' + fileName, 'r')

    duplicate_photos = 0
    for line in file:
        if len(line) > 0:
            # Remove duplicates by not writing them to the final image
            # list if they have already been processed.
            splitLine = line.split('_')
            imageId = int(splitLine[1])
            if imageId not in imageSet:
                imageSet.add(imageId)
                outputFile.write(line)
            else:
                duplicate_photos += 1
    file.close()

outputFile.close()

print(str(len(imageSet)) + ' completed files')
print(str(duplicate_photos) + ' duplicate photos')
