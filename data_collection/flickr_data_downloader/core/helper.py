# Author: Jared Heinly
# Email: jheinly@cs.unc.edu

# Function used to linearly interpolate between two values given the current index
# and the total number of indices. For example, interpolate(0, 10, 1.1, 2.2)
# is the first iteration of interpolation between 1.1 and 2.2 (and it would return
# 1.1 as the result. interpolate(10, 10, 1.1, 2.2) is the last iteration and would
# return 2.2
def interpolate(currentIndex, maxIndex, minVal, maxVal):
    return currentIndex * (maxVal - minVal) / maxIndex + minVal

# Get the total number of images reported by the Flickr query response.
def numImagesInResponse(response):
    return int(len(response[0]))

# Remove any double-quotes that may be found in the provided string.
def removeQuotes(text):
    return text.replace('"', '')

def replaceSpaces(text):
    return text.replace(' ', '_')
