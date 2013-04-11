 FlickrDownloader
==================

Author: Jared Heinly
Email: jheinly@cs.unc.edu
Designed for: Python 2.0

>python FlickrDownloader.py <queryFile> <pcdbFile> <outputDir> [configFile]

queryFile [required] - The name of the file containing the Flickr query to execute.
                       This file should contain a single line of text that corresponds
                       to the Flickr query to be executed. No special formatting is
                       required. Simply type the query as you would in the Flickr search
                       box. Note: lines starting with a # sign will be ignored in the
                       query file.

pcdbFile  [required] - The name of the PCDB database file containing the target locations
                       of the downloaded images and thumbnails. The following is an example
                       of such a file:
                       
                           #DB_VERSION_0

                           image DIR jpg 2 3 2
                           image DEF 0   29  K:\switzerland1
                           image DEF 30  59  L:\switzerland2
                           image DEF 60  89  M:\switzerland3

                           thumbnail DIR jpg 2 3 2
                           thumbnail DEF 0   29  K:\switzerland_thumb1
                           thumbnail DEF 30  59  L:\switzerland_thumb2
                           thumbnail DEF 60  89  M:\switzerland_thumb3
                       
outputDir [required] - The directory to which output files/folders will be written.
                       Specifically, three folders will be created: *-completed, *-log,
                       and *-meta where the * represents the query string being used.

configFile [optional] - The name of a file which contains settings that will override
                        the defaults found in config.py. An empty config file with a
                        list of all the supported settings is provided in empty_config.txt.
                        Using this file without modification will have no effect on the
                        program. In order to change the settings, copy the file, modify
                        the settings as desired, and provide the path to that file to
                        FlickrDownloader.py at runtime. A sample config file is as follows:
                        
                            startTime: 1072915200
                            endTime: 1300852535
                            numSearchDivisions: 100
                            numSearchThreads: 20
                            thumbnailSize: 128
                            imagesPerFolder: 250
                            getExifEnabled: False
                            createThumbnailEnabled: True
                            computeFocalEnabled: False

config.py and the optional config file are used if you want to change any settings of the
program. Two important settings to be aware of are numSearchDivisions and numSearchThreads.
FlickrDownloader operates by dividing the entire query into smaller chunks based on
time intervals. For instance, if we are querying 4 years of data, and we have 16 chunks,
each chunk corresponds to 3 months of images. It is numSearchDivisions which determines
how many chunks are used. These chunks are then used as tasks which are passed off to
a group of threads. When a thread finishes the chunk that it is working on, it is assigned
a new chunk, until all of the chunks have been assigned and processed. It is the
numSearchThreads variable that determines how many threads will be used. In general,
you want each search chunk (also called a division) to contain ~100-10000 images.
Smaller or larger chunks are not bad, but smaller chunks create extra overhead as each
chunk does take time to initialize and smaller queries do not use the Flickr API as
efficiently as larger queries (querying images one at a time takes much longer than
querying images in chunks of 500 at a time). Large chunks can be a problem as this
creates poor load balancing between the threads. If you have one chunk that is very
large, you may be stuck waiting for that single thread to finish at the end of your
program. Generally, 1000 images per division is a good target. Based on the size of
your query (the number of images you expect to download in all), you can adjust the
numSearchDivisions accordingly. In regard to the number of threads (numSearchThreads),
16 has proven to be a good value.

Once you have started a download, it is important not to change any settings that will
have an impact on the download logic of the program (for example, changing the time
range or number of search divisions). This will cause images to be reassigned to different
divisions on successive runs, and will cause duplicate downloads. The final CreateImageList
script will remove duplicates from the image list, but downloading duplicates is not
desirable. To help avoid this issue, the FlickrDownloader program saves the current
settings in *-log/settings.txt. When starting, FlickrDownloader checks for the existance
of this file, and checks to see if any of the important settings have changed. If any
settings have been changed, a message will be printed to the screen, and the user is
prompted to either continue, or exit the program.

The downloader can be terminated and restarted at any time. This will cause the program
to re-execute the Flickr query in its entirety, but any images that have already been
successfully processed and completed will be skipped. Therefore, it is usually good idea
to restart the FlickrDownloader once it has finished to attempt to download and process
images that had previously failed.

As the program runs, it will print statistics about the images that it is processing.
A description of those statistics is as follows:
    Images Queried   - The number of images found in the query responses.
    Completed Images - The number of images that were successfully completed. This means
                       that the image was downloaded, and that its thumbnail creation
                       was successful.
    Skipped Images   - The number of images that were skipped because they had already
                       been successfully completed in a previous run of the program.
    Bad URLs         - This is the number of images for which a valid URL could not be
                       found. Many times this can be caused by an image being too small
                       (we only want URLs that correspond to images of a decent size).
    Discarded Images - This is the number of images that were discarded because all
                       attempts to split a query response into a smaller size failed.
                       This could happen if greater than 500 images all correspond to
                       a very tight range of timestamps (though this rarely occurs).
    Failed Images    - This is the number of images for which a thumbnail could not be
                       created. This means that either the downloaded image is corrupt,
                       or it is in a format that cannot be handled (ex. GIF).
    Empty Queries    - This is the number of queries that failed to yield image results.
                       This will occur if there are no images to be downloaded in the
                       current time range, or if the Flickr API fails to give a response
                       after several repeated attempts.
