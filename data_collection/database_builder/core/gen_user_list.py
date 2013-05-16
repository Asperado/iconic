from file_io import FileIO
from photo import Photo

def gen_owner_id(photos):
    owner_id = {}
    user_count = 0
    photo_owner_id = []

    for index, photo in enumerate(photos):
        photo_owner = photo.ownerId
        if (not(photo_owner in owner_id)):
            user_count = user_count + 1
            owner_id[photo_owner] = user_count
        photo_user_id = owner_id[photo_owner]        
        photo_owner_id.append(photo_user_id)
        if (index % 10000 == 0):
            print (index)
    return photo_owner_id

def task_gen_image_user_id(query, photos, output_path):
    image_owner_id = gen_owner_id(photos)
    import scipy
    import scipy.io
    data = {}
    data['owners'] = scipy.reshape(scipy.array(image_owner_id), (len(image_owner_id), 1))
    scipy.io.savemat(output_path, data)

def gen_user_list(root, query, photos):
    output_path = "%s/data/extra_info/%s_owners.mat" % (root, query)
    file_io = FileIO()
    file_io.create_folders_for_path(output_path)

    task_gen_image_user_id(query, photos, output_path)
    
if __name__ == "__main__":
    photos = []

    photo = Photo()
    photo.ownerId = 'test_owner_1'
    photos.append(photo)

    photo = Photo()
    photo.ownerId = 'test_owner_2'
    photos.append(photo)

    photo = Photo()
    photo.ownerId = 'test_owner_3'
    photos.append(photo)

    gen_user_list('../../../../test_dir/debug', 'test', photos)
