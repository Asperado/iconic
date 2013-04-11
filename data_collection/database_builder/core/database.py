from file_io import FileIO;

class DBHelper(object):
    dataRoot = ''
    dataDir = ''
    configDir = ''
    layerDigits = [];
    topLayerFolders = 0;
    has_initialized = 0;
    def __init__(self):
      self.has_initialized = 0;
      
    def init(self, dataRoot):
        self.dataRoot = dataRoot;
        self.dataDir = ''.join([self.dataRoot, '/', 'data'])
        self.datasetDir = ''.join([self.dataDir, '/', 'dataset'])
        self.imageDir = ''.join([self.dataDir, '/', 'images'])
        self.thumbDir = ''.join([self.dataDir, '/', 'thumbs'])
        self.metaDir = ''.join([self.dataDir, '/', 'meta'])
        self.rawdataDir = ''.join([self.dataDir, '/', 'rawdata'])
        self.configDir = ''.join([self.dataRoot, '/', 'config'])
        
        self.mkDir(self.dataRoot)
        self.mkDir(self.dataDir)
        self.mkDir(self.datasetDir)
        self.mkDir(self.imageDir)
        self.mkDir(self.thumbDir)
        self.mkDir(self.metaDir)
        self.mkDir(self.rawdataDir)
        self.mkDir(self.configDir)
		
        self.layerDigits= [5];
        self.topLayerFolders = 20000;
        self.has_initialized = 1;

    def gen_config_file(self, query):
        output_dir = self.configDir;
        file_io = FileIO();
        file_io.create_folders(output_dir);
        output_path = self.get_config_filepath(query);
        fout = open(output_path, 'w');
        fout.write('getExifEnabled: True\n');
        fout.close();
        print('generate config file at ' + output_path + '\n');
        
    def get_config_filepath(self, query):
        import os;
        return os.path.join(self.configDir, 'config.txt');
        
    def genPCDBFile(self, query):        
        outputDir = ''.join([self.configDir, '//', query, '//']);
        import os;
        if(not(os.path.exists(outputDir))):
            os.mkdir(outputDir);
        
        outputPath = ''.join([outputDir, 'pcdb.txt']);
        
        fout = open(outputPath, 'w');
        fout.write('#DB_VERSION_0');
        fout.write('\n');
        
        folderStr = ''.join([str(len(self.layerDigits))])
        for id, value in enumerate(self.layerDigits):
            folderStr = ''.join([folderStr, ' ', str(value)]);
        
        fout.write(''.join(['image DIR jpg ', folderStr]));
        fout.write('\n');
        fout.write('image DEF %d %d %s'%(0, self.topLayerFolders, ''.join([self.imageDir, '/', query])));        
        fout.write('\n');
        fout.write(''.join(['thumbnail DIR jpg ', folderStr]));
        fout.write('\n');
        fout.write('thumbnail DEF %d %d %s'%(0, self.topLayerFolders, ''.join([self.thumbDir, '/', query])));                
        fout.write('\n');
        fout.write(''.join(['meta DIR txt ', folderStr]));
        fout.write('\n');
        fout.write('meta DEF %d %d %s'%(0, self.topLayerFolders, ''.join([self.metaDir, '/', query])));                
        fout.write('\n');
        fout.close()
        print('finish gen PCDB');
    
    def getPCDBPath(self, query):
        ret = ''.join([self.configDir,'//%s//pcdb.txt' % query]);
        return ret;
      
#    def getPhotoSubDir(self, photoId):
#        folderStr = photoId.split('_')[0];
#        folderSubdir = '';        
#        for i in range(len(self.layerDigits)):
#            folderSubdir = ''.join([folderSubdir, '//', folderStr[0:self.layerDigits[i]]]);
#            folderStr = folderStr[self.layerDigits[i]:];
#        folderSubdir = folderSubdir[1:];
#        return folderSubdir;

    def getPhotoSubDir(self, photoId):
        folderStr = photoId.split('_')[0];
        folderSubdir = folderStr[0:-3];
        return folderSubdir;

    def get_meta_root(self, query):
        path = ''.join([self.metaDir, '/', query])
        return path;
    
    def getMetaFile(self, query, photoId):
        path = ''.join([self.metaDir, '/', query,'/', self.getPhotoSubDir(photoId), '/', photoId, '.txt']);
        return path;
    
    def getRawMetaFileDir(self, query):
        path = ''.join([self.rawdataDir, '/', query,'-meta']);
        return path;
        
    def getPhotoImgPath(self, query, photoId):
        import os;

        path = ''.join([self.imageDir, '/', query,'/', self.getPhotoSubDir(photoId), '/', photoId, '.jpg']);
        if (os.path.exists(path)):
            return path;

        path = ''.join([self.imageDir, '/', query,'/', self.getPhotoSubDir(photoId), '/', photoId, '.png']);
        if (os.path.exists(path)):
            return path;

        path = ''.join([self.imageDir, '/', query,'/', self.getPhotoSubDir(photoId), '/', photoId, '.gif']);
        if (not(os.path.exists(path))):
            print (path);

        return path;
        

    def getPhotoThumbnailPath(self, query, photoId):
        path = ''.join([self.thumbDir, '/', query,'/', self.getPhotoSubDir(photoId), '/', photoId, '.jpg']);
        return path;

    
    def getDatasetFile(self, query, otherFileName=''):
        path = '';
        if(len(otherFileName)==0):
            path = ''.join([self.datasetDir, '//', query, '.txt']);
        else:
            path = ''.join([self.datasetDir, '//', otherFileName, '.txt']);
        return path;

    def mkDir(self, dir_name):
        import os;
        if(not(os.path.exists(dir_name))):
            os.makedirs(dir_name)
		
if __name__ == '__main__':
    dbHelper = DBHelper()
    dbHelper.init('/nas02/home/h/o/hongtao/Iconic')
    dbHelper.genPCDBFile('apple')
    dbHelper.gen_config_file('apple');

