from photo import Photo

class PhotoBuilder(object):
	def get_photo_from_file(self,filepath):
		fin = open(filepath,'r')
		photos = []
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
				    keep = 0
				    for c in v:
					    if(c>='a' and c<='z' or c>='A' and c<='Z'):
						    keep = 1
					    else:
						    keep = 0
						    break
				    if (keep):
					    photo.tags.append(v)
			if(key=='url'):
				photo.url = value;
			if(key=='datetaken'):
				value = value.split(' ')
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
			
			if(len(key)==0):
			    if(self.is_valid_photo(photo)):
				    photos.append(photo)
		return photos

	def is_valid_photo(self, photo):
		valid = False
		if(len(photo.tags)>0):
			valid = True
			for i in photo.photoId:
				if (not(i >= '0' and i <= '9' or i == '_')):
					valid = False

		return valid

if __name__ == "__main__":
	photoBuilder = PhotoBuilder();
	photos = photoBuilder.getPhotoFromFile('/netscr/hongtao/Iconic/data/rawdata/memory-meta/memory-0003-meta.txt');
	for photo in photos:
		print (photo.ownerId)
		print (photo.photoId)
		print (photo.tags)
		print (photo.datetaken)
		print (photo.timetaken)
		print (photo.url_s)
		print (photo.url_q)
		print (photo.url_t)
		print (photo.url_m)
		print (photo.url_z)
		print (photo.url_b)
		print (photo.farm)
		print (photo.secret)
	print ('done debug photo builder')

