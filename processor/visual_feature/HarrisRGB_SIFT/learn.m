function learn(image_root, feature_root, image_id_file, class_name, can_skip, gen_sift, gen_dict_only, output_file_name)

image_dir = sprintf('%s/%s/', image_root, class_name); 
data_dir = sprintf('%s/HarrisRGBSIFT/%s/', feature_root, class_name);
feature_all_root = sprintf('%s/%s', data_dir, 'all');
mkdir(feature_root);
mkdir(feature_all_root);
mkdir(data_dir);

filenames = getStringListFromTxt(image_id_file);
for i = 1:length(filenames)
  filenames{i} = filenames{i}(length(image_dir):end);
end

params.maxImageSize = 300;
params.gridSpacing = 4;
params.patchSize = 10;
params.dictionarySize = 1000;
params.numTextonImages = 300;
params.pyramidLevels = 2;

if (gen_dict_only)
  pfig = sp_progress_bar('Building Spatial Pyramid');
  CalculateDictionary(filenames,image_dir,data_dir,'_sift.mat',params,can_skip,pfig);
  return;
end

SPM = BuildPyramid(filenames,image_dir,data_dir,params,can_skip,gen_sift);

[drop, image_id_file_name] = fileparts(image_id_file);

if (~exist('output_file_name', 'var'))
  output_file_name = image_id_file_name;
end

feature_all_path = sprintf('%s/%s.mat', feature_all_root, output_file_name);
save(feature_all_path, 'SPM', '-v7.3');

exit(0);
