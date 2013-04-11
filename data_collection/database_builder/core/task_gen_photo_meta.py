from database import DBHelper
from photo_filter import PhotoFilter
from photo_dao import PhotoDao

def task_gen_photo_meta(root, query, do_save_meta):
	print('generating photo meta for %s'%(query));
	filter = PhotoFilter();
	dbHelper = DBHelper();
	dbHelper.init(root);
	photos = filter.get_photo_with_tag_and_unique(query, dbHelper);
	if (do_save_meta):
		photo_dao = PhotoDao(dbHelper)
		for photo in photos:
			photo_dao.savePhotoMeta(query, photo);
	photos = filter.filter_photo_without_tags(photos);

	outputPath = ''.join([dbHelper.datasetDir, '/', query, '.txt']);
	print(outputPath);
	fout = open(outputPath, 'w');
	for photo in photos:
		fout.write(photo.photoId)
		fout.write('\n')
	fout.close();

