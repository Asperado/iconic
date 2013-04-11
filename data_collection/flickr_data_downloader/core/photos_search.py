import os
import sys
import time

import config
import helper
from flickrapi import FlickrAPI
from photo_processor import *


def photos_search(minTime, maxTime, thread, extra_info):
    successfulQuery = False
    retries = -1
    log = ''
    while not successfulQuery:
        retries += 1
        if retries > config.numQueryRetries:
            log += 'ERROR: all retries failed' + '\n'
            return None
        elif retries > 0:
            log += 'Retrying query: retry ' + str(retries) + ' of ' + str(config.numQueryRetries) + '\n'
            
        try:
            time.sleep(3 * retries) # 0 sleep on first iteration
            if thread.shouldStop:
                thread.exitThread()

            flickr_api_key = config.flickrAPIKey
            flickr_per_page = str(config.maxPhotosPerPage)
            flickr_query_string = thread.queryString

            response = thread.flickrAPI.photos_search(api_key=flickr_api_key,
                                                      ispublic='1',
                                                      media='photos',
                                                      per_page=flickr_per_page,
                                                      sort='interestingness-desc',
                                                      page='1',
                                                      text=flickr_query_string,
                                                      extras = extra_info,
                                                      min_upload_date=str(minTime),
                                                      max_upload_date=str(maxTime))

            time.sleep(1)
            if thread.shouldStop:
                thread.exitThread()

            
            # Make sure that we can get the number of images from the response.
            numImages = helper.numImagesInResponse(response)

            # If no images were returned in the query, retry the query (it seems that
            # sometimes Flickr may just return an empty query if it is busy.
            if numImages == 0:
                log += 'WARNING: 0 images in response' + '\n'
                continue
            
        except KeyboardInterrupt:
            print(thread.processPrint + 'Rasing interrupt...')
            raise
     
        except Exception as error:
            log += 'ERROR: there was an exception while querying' + '\n'
            log += str(error) + '\n'
            print (log)
            continue
        
        successfulQuery = True
    return response


if __name__ == "__main__":
    
    flickr_api_key = config.flickrAPIKey
    flickr_per_page = str(config.maxPhotosPerPage)
    flickrAPI = FlickrAPI(config.flickrAPIKey, config.flickrSecret)
    response = flickrAPI.photos_search(
        api_key=flickr_api_key,
        sort='interestingness-desc',
        ispublic='1',
        media='photos',
        per_page=flickr_per_page,
        page='1',
        text='love',
        extras = config.photo_extras,
        min_upload_date='1300822535',
        max_upload_date='1300882535')
    count = 0
    for photo in response[0]:
        image = photo.attrib
        print (extract_url(image))
        if(is_valid_photo(image)):
            count = count + 1
    print (count)


