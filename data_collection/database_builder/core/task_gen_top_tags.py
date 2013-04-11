def save_tag_to_mat(lines, dim, query, root):
    feature_dao = FeatureDao()
    feature_dao.init(root)
    feature_id = 'tag%d' % dim
    feature_path =  ''.join([feature_dao.featureRoot ,'/', feature_id, '/',query , '/', 'tag%d_tags.mat' % dim])
    save_strings_to_mat(lines, 'tags', feature_path)

def save_strings_to_mat(lines, entry_name, file_path):
    import os
    output_dir = os.path.dirname(file_path)
    if(not os.path.exists(output_dir)):
        os.makedirs(output_dir)
        import scipy
        import scipy.io
        data = {}
        data[entry_name] = lines
        scipy.io.savemat(file_path,data)  

def task_gen_top_tag_via_user(photos, query, K, root, do_skip):
    tags_path = ''.join([root, '/data/tags/%s.txt' % query])
    import os
    if os.path.exists(tags_path) and do_skip:
        print ('top tags already generated.\n')
        fin = open(tags_path, 'r')
        top_word = []
        for line in fin:
            top_word.append(line.strip())
        return top_word

    print('begin gen top tag via user\n')
    tag_user_ids = {}
    for photo in photos:
        tags = photo.tags
        for tag in tags:
            if (not(tag in tag_user_ids)):
                tag_user_ids[tag] = ''
            tag_user_ids[tag] = ''.join([tag_user_ids[tag], ',', photo.ownerId])

    tags_score = {}
    for tag in tag_user_ids:
        user_ids = tag_user_ids[tag]
        user_ids = user_ids.split(',')
        tags_score[tag] = len(user_ids)

    top_word_freq = sorted(tags_score.items(), key=lambda t: -t[1])
    K = min(len(top_word_freq), K)
    top_word_freq = top_word_freq[0:K]
    top_word = []
    for line in top_word_freq:
        top_word.append(line[0].strip())

    print('done gen top tag via user, saving output ...\n')

    # print out top tags.
    from file_io import FileIO
    file_io = FileIO()
    file_io.write_strings_to_file(top_word, tags_path)

    # print out score for tags.
    top_word_str = []
    for line in top_word_freq:
        top_word_str.append(line[0].strip() + ' ' + str(line[1]))
    output_path = ''.join([root, '/data/tags/%s_score.txt'%query])
    from file_io import FileIO
    file_io = FileIO()
    file_io.write_strings_to_file(top_word_str, output_path)
    
    save_tag_to_mat(top_word, K, query, root)

    return top_word

def task_gen_top_tag_via_number(query, K, root):
    from photo_dao import PhotoDao
    from database import DBHelper
    db_helper = DBHelper()
    db_helper.init(root)

    photo_dao = PhotoDao(db_helper)
    photo_ids = photo_dao.getClassPhotoIds(query, ''.join([query]))

    photos = photo_dao.getPhotos(query, photo_ids)

    hist = {}
    for photo in photos:
        tags = photo.tags
        for tag in tags:
            if(tag in hist):
                hist[tag] = hist[tag] + 1
            else:
                hist[tag] = 0
    top_word_freq = sorted(hist.items(), key=lambda t: -t[1])
    top_word_freq = top_word_freq[0:min(len(top_word_freq), K)]
    top_word = []
    for line in top_word_freq:
        top_word.append(line[0].strip())

    output_path = ''.join([root, '/data/tags/%s.txt'%query])
    from file_io import FileIO
    file_io = FileIO()
    file_io.write_strings_to_file(top_word, output_path)

    return top_word

def task_gen_index_by_tag(query, root, top_tag_num, top_tags, photo_ids, output_root):
    from photo_dao import PhotoDao
    from database import DBHelper
    db_helper = DBHelper()
    db_helper.init(root)

    photo_dao = PhotoDao(db_helper)
    photos = photo_dao.getPhotos(query, photo_ids)
    top_tags_index = {}
    for i, tag in enumerate(top_tags):
        top_tags_index[tag] = i
    
    tag_image_index = ['']*top_tag_num
    for photo in photos:
        tags = photo.tags
        for tag in tags:
            if(tag in top_tags):
                tag_index = top_tags_index[tag]
                tag_image_index[tag_index] = ''.join([tag_image_index[tag_index], ',', photo.photoId])
    
    web_dao = WebPageResultDao()
    web_dao.init(output_root)
    for key in top_tags:
        tag_index = top_tags_index[key]
        line = tag_image_index[tag_index]
        line = line.strip()

        if (line != ""):
            tag_image_ids = []
            image_ids = line.split(',')
            for image_id in image_ids:
                image_id = image_id.strip()
                if (image_id != ""):
                    tag_image_ids.append(image_id)
            try:
                web_dao.save_photo_ids('tag_images/%s' % key, '1', tag_image_ids)
            except:
                print('error in generating %s' % key)

def get_top_tags(query, root):
    top_tag_path = ''.join([root, '/data/tags/%s.txt'%query])
    fin = open(top_tag_path, 'r')
    top_tags = []
    for tag in fin:
        tag = tag.strip()
        top_tags.append(tag)
    fin.close()
    return top_tags

def task_build_tag_features(wordList, query, photos, gen_all_features, root, do_skip):
    tag2Id = {}
    for index, tag in enumerate(wordList):
        tag2Id[tag] = index
    
    featureDao = FeatureDao()
    featureDao.init(root)
    featureId = 'tag%d'%(len(wordList))
    features = []    
    for id, photo in enumerate(photos):
        tags = photo.tags
        feature = [0]*len(wordList)
        for tag in tags:
            if(tag in wordList):
                feature[tag2Id[tag]] = 1
        featureDao.save_feature(query, photo.photoId, featureId, feature, do_skip)        
        print('done extracting tag feature for photo %d'%id)
        if (gen_all_features):
            features.append(feature)
    return features

class FeatureDao:
    featureRoot = 'D:/Iconic/data/features'
    def init(self, root):
        self.featureRoot = ''.join([root, '/data/', 'features'])

    def getFeaturePath(self, query, photoId, featureId):
        from database import DBHelper 
        db_helper = DBHelper()        
        subPath = db_helper.getPhotoSubDir(photoId)
        featurePath = ''.join([self.featureRoot ,'/', featureId, '/',query , '/' , subPath , '/', '%s_%s.mat'%(featureId, photoId)])
        return featurePath
    
    def save_feature(self, query, photoId, featureId, featureData, do_skip):
        import os

        featurePath =self.getFeaturePath(query, photoId, featureId)
        if(os.path.exists(featurePath) and do_skip == 1):
            print ('skip photo %s' % photoId)
            return

        featureDir = os.path.dirname(featurePath)
        if(not os.path.exists(featureDir)):
            os.makedirs(featureDir)
        
        import scipy
        import scipy.io
        data = {}
        dim = self.getFeatureDim(featureId)
        data['featureData'] = scipy.reshape(scipy.array(featureData), (1, dim))
        scipy.io.savemat(featurePath,data)
    
    def save_features(self, query, photoIds, featureId, featureData, fileName = ''):
        if(fileName == ''):
            fileName = featureId
        
        import os                        
        featurePath =  ''.join([self.featureRoot ,'/', featureId, '/',query , '/', '%s.mat'%fileName])
        featureDir = os.path.dirname(featurePath)
        if(not os.path.exists(featureDir)):
            os.makedirs(featureDir)
        
        import scipy
        import scipy.io
        data = {}
        data['featureData'] = scipy.array(featureData)
        print(featurePath)
        scipy.io.savemat(featurePath,data)        
        
    def read_feature(self, query, photoId, featureId):                
        import scipy
        import scipy.io
        featurePath =self.getFeaturePath(query, photoId, featureId)
        featureData = scipy.io.loadmat(featurePath)
        return featureData

    def read_features(self, query, photoIds, featureId):
        import scipy
        nPhotos = len(photoIds)
        dim = self.getFeatureDim(featureId)
        features = scipy.zeros((nPhotos, dim))
                
        for index, photoId in enumerate(photoIds):
            featureData = self.read_feature(query, photoId, featureId)
            data = featureData['featureData']
            data = scipy.reshape(data, (1, dim))
            features[index, :] = data        
            print('Done Reading Photo %s'%(photoId))
        return features

    def getFeatureDim(self, featureId):
        dim = -1
        if(featureId.startswith('tag')):
            dim = int(featureId[len('tag'):])
        return dim


def taskBuildAllFeatures():
    from photo_dao import PhotoDao
    from database import DBHelper
    db_helper = DBHelper()
    
    query = 'beauty'
    db_helper.init('D:/Iconic')
    photoDao = PhotoDao(db_helper)
    photoIds = photoDao.getClassPhotoIds(query, ''.join([query]))
    featureDao = FeatureDao()
    features = featureDao.read_features(query, photoIds, 'tag3000')
    featureDao.save_features(query, photoIds, 'tag3000', features)
    
class WebPageResultDao:
  root_path = 'D:/Iconic/web/cluster'
  def init(self, output_root):
      self.root_path = output_root

  def _get_folder_name(self, folder_name):
    return ''.join([self.root_path, '/', folder_name, '/'])

  def _get_file_name(self, folder_name, result_id):
    return ''.join([self._get_folder_name(folder_name), '/', result_id, '.txt'])

  def save_photo_ids(self, folder_name, result_id, photoIds):
      from file_io import FileIO
      file_path = self._get_file_name(folder_name, result_id)
      io = FileIO()
      io.write_strings_to_file(photoIds, file_path)


if __name__ == '__main__':
    top_tag_num = 6000
    query = 'love'
    root = '/nas02/home/h/o/hongtao/Iconic'

    from photo_dao import PhotoDao
    from database import DBHelper
    db_helper = DBHelper()
    db_helper.init(root)

    photo_dao = PhotoDao(db_helper)
    photo_ids = photo_dao.getClassPhotoIds(query, ''.join([query]))
    photo_ids = photo_ids[1:100]
    photos = photo_dao.getPhotos(query, photo_ids)

    top_word = task_gen_top_tag_via_user(photos, query, top_tag_num, root)
    task_build_tag_features(top_word, query, photos, 0, root)    
    import os
    output_root = os.path.join(root, 'output/%s/web' % query)
    task_gen_index_by_tag(query, root, top_tag_num, top_word, photo_ids, output_root)




