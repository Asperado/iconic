import os
import os.path

from stl import getFileOfType
from photo_builder import PhotoBuilder
from filter_tag import is_good_word;
from database import DBHelper;
from photo_dao import PhotoDao

class PhotoFilter(object):
	def get_photo_with_tag(self, metaFilePath):
		photoBuilder = PhotoBuilder();

		files = getFileOfType(metaFilePath,'txt')
		for i in range(0, len(files)):
			files[i] = metaFilePath + '/' + files[i]

		photos = []
		for filepath in files:
			items = photoBuilder.get_photo_from_file(filepath)
			photos.extend(items)
		return photos
	
	def filter_photo_without_tags(self, photos):
		new_photos = [];
		for photo in photos:
			if (len(photo.tags) > 0):
				new_photos.append(photo);
		return new_photos;

	def filter_photo_tags(self, photos):
		new_photos = [];
		for photo in photos:
			new_tags = [];
			for tag in photo.tags:
				if (is_good_word(tag)):
					new_tags.append(tag);
			photo.tags = new_tags;
			new_photos.append(photo);
		return new_photos;
		
	def make_unique_user(self, photos):
		visitedUser = {}
		refinedPhoto = []
		for photo in photos:
			if(not(photo.ownerId in visitedUser)):
				visitedUser[photo.ownerId] = [];
				visitedUser[photo.ownerId].append(photo.datetaken);
				refinedPhoto.append(photo)
			else:
				if(not(photo.datetaken in visitedUser[photo.ownerId])):
					visitedUser[photo.ownerId].append(photo.datetaken);
					refinedPhoto.append(photo)
					
		print('done removing same users uploading images on the same day.')
		return refinedPhoto;

	def get_photo_meta_files(self, query, db_helper):
		meta_root = db_helper.get_meta_root(query)
		meta_dirs = [o for o in os.listdir(meta_root) if os.path.isdir(meta_root + '/' + o)]
		files = []
		for meta_dir in meta_dirs:
			tmp_files = getFileOfType(meta_root + '/' + meta_dir, 'txt')
			for tmp_file in tmp_files:
				tmp_file = meta_root + '/' + meta_dir + '/' + tmp_file
				files.append(tmp_file)
		return files
		
	def get_photo_metas(self, query, db_helper):
		photo_files = self.get_photo_meta_files(query, db_helper)
		photos = []
		photoBuilder = PhotoBuilder();
		for filepath in photo_files:
			items = photoBuilder.get_photo_from_file(filepath)
			photos.extend(items)
		return photos
		
		
	def get_photo_with_tag_and_unique(self, query, db_helper):
		metaFilePath = db_helper.getRawMetaFileDir(query);
		photos = self.get_photo_with_tag(metaFilePath);

#		photos = self.get_photo_metas(query, db_helper)

		photos = self.filter_photo_tags(photos);
		print(len(photos));
		photos = self.make_unique_user(photos);
		print(len(photos));
		return photos;

if __name__ == "__main__":
	root = '../../../../test_dir'
	db_helper = DBHelper()
	db_helper.init(root)
	filter = PhotoFilter()
	photos = filter.get_photo_meta_files('art', db_helper)
	print (photos[0:10])
	print (len(photos))

