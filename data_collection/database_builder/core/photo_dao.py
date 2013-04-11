from photo import Photo


def getPhoto(info):
    photoMetaPath = info['photo_dao'].dbHelper.getMetaFile(info['query'], info['photo_id']);
    photo = info['photo_dao'].getPhotoFromFile(photoMetaPath);
    return photo;

def getPhotosMultiThread(root, query, photo_ids):
    from PhotoDao import PhotoDao;
    from DBHelper import DBHelper;
    db_helper = DBHelper();
    db_helper.init(root);
    photo_dao = PhotoDao(db_helper);

    infos = [];
    for photo_id in photo_ids:
        info = {};
        info['photo_dao'] = photo_dao;
        info['photo_id'] = photo_id;
        info['query'] = query;
        infos.append(info);
    print('done generaing infos for photo');

    import time;
    start=time.time()
    from multiprocessing import Pool
    pool = Pool(processes=30)              # start 4 worker processes
    photos = pool.map(getPhoto, infos)          # prints "[0, 1, 4,..., 81]"
    print "process_files_parallel()", time.time()-start

    return photos;
    

class PhotoDao(object):
    def __init__(self, dbHelper):
        self.dbHelper = dbHelper;
    
    def getClassPhotoIds(self, className, otherDatasetName = ''):
        file = self.dbHelper.getDatasetFile(className, otherDatasetName);
        fin = open(file, 'r');
        ret = [];
        for item in fin:
            item = item.strip();
            ret.append(item);
        print('Done get image from class %s' % className);
        return ret;

    def saveClassPhotoIds(self, className, photoIds, otherDatasetName = ''):
        file = self.dbHelper.getDatasetFile(className, otherDatasetName);
        fout = open(file, 'w');
        for item in photoIds:
            item = item.strip();
            fout.write(item + '\n');
        print('Done save image ids of class %s' % className);
        fout.close();

        file = ''.join([dbHelper.datasetDir, '\\', className, '_path.txt'])
        fout = open(file, 'w');
        for item in photoIds:
            fout.write(dbHelper.getPhotoImgPath(className, photo.photoId));
            fout.write('\n')
        print('Done save image path of class %s' % className);
        fout.close()

    def getPhotos(self, query, photoIds):
        photos = [];
        for photoId in photoIds:
            photoMetaPath = self.dbHelper.getMetaFile(query, photoId);
            photo = self.getPhotoFromFile(photoMetaPath);
            photos.append(photo);
        return photos;
   
    def getPhotoFromFile(self,filepath):
        fin = open(filepath,'r')
        photo = Photo()
        for line in fin:
            items = line.split(':', 1)
            key = items[0].strip()
            if(len(items)>1):
                value = items[1].strip()				
            if(key=='ID'):
                photo = Photo()
                photo.photoId = value
            if(key=='owner'):
                photo.ownerId = value
            if(key=='tags'):
                value = value.split(',')
                photo.tags = []
                for v in value:
                    v = v.strip()
                    if(len(v)>30):
                        continue;
                    if(v>='a' and v<='z' or v>='A' and v<='Z'):
                        photo.tags.append(v)
            if(key=='url'):
                photo.url = value;
            if(key=='datetaken'):
                value = value.split(' ');
                photo.datetaken = value[0].strip();
                if (len(value) > 1):
                    photo.timetaken = value[1].strip();
                
            if(key=='secret'):
                photo.secret = value
            if(key=='farm'):
                photo.farm = value
            if(key=='url_s'):
                photo.url_s = value
            if(key=='url_q'):
                photo.url_q = value
            if(key=='url_t'):
                photo.url_t = value
            if(key=='url_m'):
                photo.url_m = value
            if(key=='url_z'):
                photo.url_z = value
            if(key=='url_b'):
                photo.url_b = value

        return photo


    def savePhotoMeta(self, query, photo):
        filepath = self.dbHelper.getMetaFile(query, photo.photoId);
        import os;
        if (os.path.exists(filepath)):
            print ('skip meta for %s\n' % photo.photoId)
            return;
        print('create meta for %s\n' % photo.photoId);

        import os;
        dirName = os.path.dirname(filepath);
        self.dbHelper.mkDir(dirName);        
        fout = open(filepath, 'w');
        fout.write('ID: ' + photo.photoId + '\n')
        fout.write('owner: ' + photo.ownerId + '\n') 
        fout.write('tags: ' + ','.join(photo.tags) + '\n')
        fout.write('query: ' + query + '\n')
        fout.write('url: ' + photo.url + '\n')
        fout.write('datetaken: ' + photo.datetaken + '\n');
        fout.write('timetaken: ' + photo.timetaken + '\n');
        fout.write('secret: ' + photo.secret + '\n');
        fout.write('farm: ' + photo.farm + '\n');
        fout.write('url_s: ' + photo.url_s + '\n');
        fout.write('url_q: ' + photo.url_q + '\n');
        fout.write('url_t: ' + photo.url_t + '\n');
        fout.write('url_m: ' + photo.url_m + '\n');
        fout.write('url_z: ' + photo.url_z + '\n');
        fout.write('url_b: ' + photo.url_b + '\n');

        fout.close();
    
    def getPhotoOfUser(self, ownerId, photos):
        photos = [];
        for photo in photos:
            if(photo.ownerId == ownerId):
                photos.append(photo);
                print(photo.photoId);
        return photos;
    
    def converToUserPhotoList(self, photos):
        lists = {}
        for photo in photos:
            if(not(photo.ownerId in lists)):
                lists[photo.ownerId] = [];
                lists[photo.ownerId].append(photo);
            else:
                lists[photo.ownerId].append(photo);
                
#        print(len(lists))
        print('Done Debug Photo Builder')
        return lists;


top_tags = [];

def filter_photo_with_top_tags(photo):
    info = {};
    info['keep'] = True;
    info['photo'] = photo;
    for tag in photo.tags:
        if (tag in top_tags):
            return info;
    info['keep'] = False;
    return info;

def filter_photos_with_top_tags(photos):
    import time;
    start=time.time()
    from multiprocessing import Pool
    pool = Pool(processes=30)              # start worker processes
    photos_keep = pool.map(filter_photo_with_top_tags, photos)     
    print("process_files_parallel()", time.time()-start);
    photos = [];
    for photo_info in photos_keep:
        if(photo_info['keep']):
            photos.append(photo_info['photo']);
    return photos;

if __name__ == '__main__':
    from PhotoDao import PhotoDao;
    from DBHelper import DBHelper;
    db_helper = DBHelper();
    root = '/nas02/home/h/o/hongtao/Iconic';
    db_helper.init(root);

    query = 'love';
    photo_dao = PhotoDao(db_helper);
    photo_ids = photo_dao.getClassPhotoIds(query, ''.join([query]));
#    photo_ids = photo_ids[0:100];
#    photos = photo_dao.getPhotos(query, photo_ids);

    photos = getPhotosMultiThread(root, query, photo_ids);
    print('obtain ' + str(len(photos)) + ' photos.'); 

    top_tagfile = '/nas02/home/h/o/hongtao/magiconic/FlickrDownloader/tmp_dir/data/tags/%s.txt' % query;
    fin = open(top_tagfile, 'r');
    for tag in fin:
        top_tags.append(tag.strip());
    photos = filter_photos_with_top_tags(photos);
    print('after filter image photos, ' + str(len(photos)) + ' images left.'); 
    new_photo_ids = [];
    for photo in photos:
        new_photo_ids.append(photo.photoId);
    output_filepath = './tmp_%s_top_1000_label.txt' % query;
    from FileIO import FileIO;
    file_io = FileIO();
    file_io.write_strings_to_file(new_photo_ids, output_filepath);
