from core.timing import tic;
from core.timing import toc;
from tools.cmd_arguments_helper import CmdArgumentsHelper;

def main():
    arg_helper = CmdArgumentsHelper();
    arg_helper.add_argument('query', 'q', 'query', 1);
    arg_helper.add_argument('root_dir', 'r', 'root', 1);
#    arg_helper.add_argument('output_dir', 'o', 'outdir', 1);
    arg_helper.add_argument('top_tag_num', 't', 'top_tag_num', 1);    
    args = arg_helper.read_arguments();
    print (args);

    root = args['root_dir'];
    top_tag_num = int(args['top_tag_num']);
    query = args['query'];

    do_skip = 0
    save_meta = 0

    from core.task_gen_photo_meta import task_gen_photo_meta;
    task_gen_photo_meta(root, query, save_meta);

    from core.task_gen_photo_imagepath import task_gen_photo_imagepath;
    task_gen_photo_imagepath(root, query)

    from core.photo_dao import PhotoDao;
    from core.database import DBHelper;
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


    from core.task_gen_top_tags import task_gen_top_tag_via_user;
    print('gen top tags via user...');
    tic();
    top_word = task_gen_top_tag_via_user(photos, query, top_tag_num, root, do_skip);
    toc();

    print('load function.');
    from core.task_gen_top_tags import task_build_tag_features;

    print('build tag features...');
    tic()
    task_build_tag_features(top_word, query, photos, 0, root, do_skip)
    toc()
    import os
    output_root = os.path.join(root, 'output/%s/web' % query)

    from core.task_gen_top_tags import task_gen_index_by_tag
    tic()
    task_gen_index_by_tag(query, root, top_tag_num, top_word, photo_ids, output_root)
    toc()

if __name__ == '__main__':
    main()

