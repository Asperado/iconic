def getFileOfType(dir, type):	
	import os
	real_dir = os.path.abspath(dir)
#	os.chdir(dir)
	ret = []
	for filepath in os.listdir(real_dir):
		if filepath.endswith("."+str(type)):
			ret.append(filepath)
	return ret
