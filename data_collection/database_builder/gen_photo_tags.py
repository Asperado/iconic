from Timing import tic;
from Timing import toc;
from CmdArgumentsHelper import CmdArgumentsHelper;

# This function is similar to gen_photo_meta, the different is that
# it does not generate image ids list and meta data as what
# gen_photo_meta does. Instead, it assume that image ids list and
# meta data is already generated, and generate the top tags and
# tag features accordingly. 

def main():
    arg_helper = CmdArgumentsHelper();
    arg_helper.add_argument('query', 'q', 'query', 1);
    arg_helper.add_argument('root_dir', 'r', 'root', 1);
    arg_helper.add_argument('top_tag_num', 't', 'top_tag_num', 1);    
    args = arg_helper.read_arguments();
    print (args);

    root = args['root_dir'];
    top_tag_num = int(args['top_tag_num']);
    query = args['query'];

    from PhotoDao import PhotoDao;
    from DBHelper import DBHelper;
    db_helper = DBHelper();
    db_helper.init(root);
    photo_dao = PhotoDao(db_helper);

    print('get photo ids.');
    tic();
    photo_ids = photo_dao.getClassPhotoIds(query, ''.join([query]));
    toc();

    print('get photos ...');
    tic();
    photos = photo_dao.getPhotos(query, photo_ids);
    toc();

    print('gen top tags via user...');
    from task_gen_top_tags import task_gen_top_tag_via_user;
    tic();
    top_word = task_gen_top_tag_via_user(photos, query, top_tag_num, root);
    toc();

    print('build tag features...');
    from task_gen_top_tags import task_build_tag_features;
    tic();
    task_build_tag_features(top_word, query, photos, 0, root);
    toc();

if __name__ == '__main__':
    main();

