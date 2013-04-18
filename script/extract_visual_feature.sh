# Begin parameter setting.
# query: the concept of the dataset.
# root: the root dir of all the produced data.
# do_{feature_name}: if set 1, will extract the corresponding visual feature.
#
# WARNING: gist not supported yet, need debuging if you select it.

  query=$1
  root=/Users/hongtaohuang/Desktop/magiconic/test_dir

  do_dictionary_generation=1
  do_dense_sift=1
  do_harris_sift=1
  do_hog=1
  do_rgb=1
  do_gist=0
# End parameter setting.

image_root=${root}/data/images
feature_root=${root}/data/features/
code_root='../processor/visual_feature'

echo 'Extracting images in :' ${image_root}
if [ ${do_dense_sift} == 1 ] && [ ${do_dictionary_generation} == 1 ]
then
    echo 'Building dictionary'
  # Build Dense RGB SIFT dictionary.
    cd ${code_root}/DenseRGB_SIFT/
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',0,0,1\); 
    cd -
fi

if [ ${do_harris_sift} == 1 ] && [ ${do_dictionary_generation} == 1 ]
then
    echo 'Building dictionary'
  # Build Harris RGB SIFT dictionary.
    cd ${code_root}/HarrisRGB_SIFT
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',0,0,1\); 
    cd -
fi

if [ ${do_hog} == 1 ] && [ ${do_dictionary_generation} == 1 ]
then	
    echo 'Building dictionary'
  # Build HoG dictionary.
    cd ${code_root}/HoG/
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',0,0,1\); 
    cd -
fi

# Extracting features.
mkdir ${root}/data/dataset/$1_folder 
echo $1
echo $1_folder
split -l 5000 -a 5 ${root}/data/dataset/$1_imagepath.txt ${root}/data/dataset/$1_folder/

input_folder=${root}/data/dataset/$1_folder;
files=`ls ${input_folder}`; 

echo ${image_root}

if [ ${do_dense_sift} == 1 ]
then
  # Extract Dense RGB SIFT
    feature_extraction_code_root=${code_root}/DenseRGB_SIFT
    cd ${feature_extraction_code_root}
    for file_name in $files
      do
      echo ${input_folder}/$file_name
      matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${input_folder}/$file_name\',\'${query}\',1,0,0\);
    done 

  # Extract Dense RGB SIFT all
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',1,0,0,\'DenseRGBSIFT\'\); 
    cd -
fi

if [ ${do_harris_sift} == 1 ]
then
  # Extract Harris RGB SIFT
    feature_extraction_code_root=${code_root}/HarrisRGB_SIFT
    
    cd ${feature_extraction_code_root}
    gen_sift=0;
    for file_name in $files
      do
      echo ${input_folder}/$file_name
      matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${input_folder}/$file_name\',\'${query}\',1,${gen_sift},0\);
    done 

  # Extract Harris RGB SIFT all
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',1,0,0,\'HarrisRGBSIFT\'\); 
    cd -
fi

if [ ${do_hog} == 1 ] 
then	
  # Extract HoG
    feature_extraction_code_root=${code_root}/HoG

    cd ${feature_extraction_code_root}
    for file_name in $files
      do
      echo ${input_folder}/$file_name
      matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${input_folder}/$file_name\',\'${query}\',1,0,0\);
    done 

  # Extract HoG all
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',1,0,0,\'HOG\'\); 
    cd -
fi

# Extract GIST
# files=`ls $1_folder`; 
# cd ~/FeatureLab/FeatureExtraction/GONG_feature/GIST/;

# for file_name in $files
# do
#   echo $file_name;
#   bsub -o /netscr/hongtao/log/${file_name}-gist.txt -M 3 -n 12 -R "span[hosts=1]" -x matlab -nojvm -nosplash -nodisplay -r learn\(\'${root}/data/dataset/${input_folder}/$file_name\',\'${query}\'\);
# done 

# Extract GIST all
# cd ~/FeatureLab/FeatureExtraction/GONG_feature/GIST/;
# bsub -q week -n 12 -R "span[hosts=1]" -o /netscr/hongtao/log/all_gist.txt -x matlab -nojvm -nosplash -nodisplay -r learn\(\'${root}/data/dataset/$1\',\'${query}\'\); 

if [ ${do_rgb} == 1 ]
then
  # Extract RGB
    feature_extraction_code_root=${code_root}/RGB/

    cd ${feature_extraction_code_root}
    for file_name in $files
      do
      echo ${input_folder}/$file_name;
      matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${input_folder}/$file_name\',\'${query}\'\);
    done 

  # Extract RGB all
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',\'RGB\'\); 
    cd -
fi


# Build combination of the visual features.
code_root=../processor/gen_iconic_feature

# Require 30~40 GB for 1 million images.
cd ${code_root}

matlab -nojvm -nosplash -nodisplay -singleCompThread -r get_iconic_features\(\'${query}\',\'${feature_root}\'\);

cd -