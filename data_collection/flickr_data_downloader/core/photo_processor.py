def is_valid_photo(photo):
    necessary_key = ['id', 
                     'secret', 
                     'server', 
                     'owner', 
                     'title', 
                     'datetaken', 
                     'tags', 
                     'license', 
                     'latitude', 
                     'longitude',
                     'accuracy']
    bad_key = []
    is_valid = True
    for key in necessary_key:
        if (key not in photo):
            is_valid = False
            bad_key.append(key)
    return is_valid
    
def extract_url(photo):
    # Get the 640 sized image url.
    # If the url is invalid, use the 500 sized image url.
    # If the url is invalid, use the 800 sized image url.
    # If the url is invalid, use the original image url
    # If the url is invalid, use the 240 sized image url.

    url_types = ['url_z', 'url_-', 'url_b', 'url_o', 'url_m', 'url_t', 'url_q', 'url_s']
    url = ''
    for url_type in url_types:
        if (url_type in photo):
            url = photo[url_type]
            if len(url) > 5:
                break
    
    if len(url) <= 5:
        url = ''
    return url

def download_image(image_url, output_path):
    try:
        print(image_url + ' ' + output_path);
        import urllib
        a = urllib.urlopen(image_url);
        f = open(output_path,'wb')
        f.write(a.read());
        f.close()
    except Exception as e:
        print('fail writing to ' + output_path);
        print (e)
        return False;
    return True;

def photo_to_string(photo):
    ret = ''
    ret += ('photo: ' + photo['id'] + ' ' + photo['secret'] + ' ' + photo['server'] + '\n')
    ret += ('secret: ' + ' ' + photo['secret'] + '\n')
    ret += ('farm: ' + ' ' + photo['server'] + '\n')
    ret += ('owner: ' + photo['owner'] + '\n') 
    url = extract_url(photo)
    ret += ('url: ' + url + '\n')
    ret += ('title: ' + str(photo['title'].encode('ascii', 'replace')) + '\n')
    ret += ('datetaken: ' + str(photo['datetaken'].encode('ascii', 'replace')) + '\n')
    tags = str(photo['tags'].encode('ascii', 'replace'))
    tags = tags.split(' ')
    tags = ','.join(tags)
    ret += ('tags: ' + tags + '\n')
    ret += ('license: ' + str(photo['license'].encode('ascii', 'replace')) + '\n')
    ret += ('latitude: '  + str(photo['latitude'].encode('ascii', 'replace')) + '\n')
    ret += ('longitude: ' + str(photo['longitude'].encode('ascii', 'replace')) + '\n')
    ret += ('accuracy: '  + str(photo['accuracy'].encode('ascii', 'replace')) + '\n')
    return ret

if __name__ == "__main__":
    download_image('http://farm2.staticflickr.com/1287/705243492_45046e14b3_z.jpg?zz=1', '../../..//test_dir/data/images/art/00000/00000032_705243492.jpg')
