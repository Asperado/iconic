function learn(image_root, feature_root, image_id_file, className, output_file_name)

image_dir = sprintf('%s/%s/', image_root, className); 
data_dir = sprintf('%s/RGB/%s/', feature_root, className);
feature_all_root = sprintf('%s/%s', data_dir, 'all');
mkdir(feature_root);
mkdir(feature_all_root);
mkdir(data_dir);

filenames = getStringListFromTxt(image_id_file);
for i = 1:length(filenames)
  filenames{i} = filenames{i}(length(image_dir):end);
end

X = zeros(length(filenames),512);
for i=1:length(filenames)
    i
    [drop, output_filename] = fileparts(filenames{i});
    feature_output_path = sprintf('%s%s.mat', data_dir, output_filename);

    fprintf('%s\n', feature_output_path);
    if (exist(feature_output_path, 'file'))
      fprintf('skip image %d\n', i);
      clear data;
      clear h;
      data = load(feature_output_path);
      h = data.h;
      X(i,:)=h(:)';
      continue;
    end

    name = filenames{i};
    name = strcat(sprintf('%s', image_dir),name);    
    try 
        img = imread(name);
    catch 
        fprintf('Bad Image %s\n', name);
        img = round(rand(800,600,3)*100);
    end
    if(size(img,3)==1)
        disp('fake color image')
        im=zeros(size(img,1),size(img,2),3);
        im(:,:,1)=img;
        im(:,:,2)=img;
        im(:,:,3)=img;
        img = im;
    end
    h = getPatchHist(double(img), 8);
    
    [feature_output_dir, drop] = fileparts(feature_output_path);
    mkdir(feature_output_dir);
    save(feature_output_path, 'h');
    X(i,:)=h(:)';
end

[drop, image_id_file_name] = fileparts(image_id_file);

if (~exist('output_file_name', 'var'))
  output_file_name = image_id_file_name;
end

feature_all_path = sprintf('%s/%s.mat', feature_all_root, output_file_name);
save(feature_all_path, 'X', '-v7.3');

exit(0);
