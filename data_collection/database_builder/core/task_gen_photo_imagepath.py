from database import DBHelper
from photo_dao import PhotoDao;
from timing import tic;
from timing import toc;
from file_io import FileIO

def get_photo_imagepath(root, query, image_ids):
    db = DBHelper()
    db.init(root)

    imagepaths =[]
    for image_id in image_ids:
        imagepath = db.getPhotoImgPath(query, image_id)
        imagepaths.append(imagepath)
    return imagepaths

def task_gen_photo_imagepath(root, query):
    print('Get photo ids.');
    db_helper = DBHelper();
    db_helper.init(root);

    photo_dao = PhotoDao(db_helper);

    tic();
    photo_ids = photo_dao.getClassPhotoIds(query, ''.join([query]));
    toc();

    print('Get photo path.');
    imagepaths = get_photo_imagepath(root, query, photo_ids)

    output_path = ''.join([db_helper.datasetDir, '/', query, '_imagepath.txt']);
    file_io = FileIO();
    file_io.write_strings_to_file(imagepaths, output_path);
    
    
if __name__ == "__main__":
    task_gen_photo_imagepath('/netscr/hongtao/Iconic', 'memory')
    
