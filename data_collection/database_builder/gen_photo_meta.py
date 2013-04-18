from core.timing import tic;
from core.timing import toc;
from tools.cmd_arguments_helper import CmdArgumentsHelper;

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
    
    # If do_skip is set to 1, will skip the item that we have previously
    # generated data. You should be careful to set it as 1, unless you 
    # are certain the data will not change, i.e. if you remove or add new
    # photo to the image id list, you should set it as 1 to regenerate 
    # all related data.
    do_skip = 0

    # If set as 1, will generate meta data for photos. Since the downloader
    # for collecting data already generate meta data for photos, we set it
    # as 0.
    save_meta = 0

    # Generate the meta data for photos.
    from core.task_gen_photo_meta import task_gen_photo_meta;
    task_gen_photo_meta(root, query, save_meta);
    
    # Generate the physical path of photos.
    from core.task_gen_photo_imagepath import task_gen_photo_imagepath;
    task_gen_photo_imagepath(root, query)

    from core.photo_dao import PhotoDao;
    from core.database import DBHelper;
    db_helper = DBHelper();
    db_helper.init(root);

    photo_dao = PhotoDao(db_helper);

    # Get all the valid photo ids.
    print('get photo ids.');
    tic();
    photo_ids = photo_dao.getClassPhotoIds(query, ''.join([query]));
    toc();

    # Get all the meta data of the photos.
    print('get photos ...');
    tic();
    photos = photo_dao.getPhotos(query, photo_ids);
    toc();

    # Generate top 'top_tag_num' tags.
    from core.task_gen_top_tags import task_gen_top_tag_via_user;
    print('gen top tags via user...');
    tic();
    top_word = task_gen_top_tag_via_user(photos, query, top_tag_num, root, do_skip);
    toc();

    # Build tag features based on top tags.
    print('load function.');
    from core.task_gen_top_tags import task_build_tag_features;

    print('build tag features...');
    tic()
    task_build_tag_features(top_word, query, photos, 0, root, do_skip)
    toc()
    import os
    output_root = os.path.join(root, 'output/%s/web' % query)

    # Generate index list of images sharing a tag.
    from core.task_gen_top_tags import task_gen_index_by_tag
    tic()
    task_gen_index_by_tag(query, root, top_tag_num, top_word, photo_ids, output_root)
    toc()

if __name__ == '__main__':
    main()

