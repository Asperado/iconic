query=$1
root=~/Desktop/magiconic/test_dir
image_root=${root}/data/images
feature_root=${root}/data/features/
code_root='../processor/visual_feature'

do_dense_sift=0
do_harris_sift=0
do_hog=1

echo ${image_root}

if [ ${do_dense_sift} == 1 ]
then
  # Extract Dense RGB SIFT all
    cd ${code_root}/DenseRGB_SIFT/
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',0,0,1\); 
    cd -
fi

if [ ${do_harris_sift} == 1 ]
then
  # Extract Harris RGB SIFT all
    cd ${code_root}/HarrisRGB_SIFT
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',0,0,1\); 
    cd -
fi

if [ ${do_hog} == 1 ] 
then	
  # Extract HoG
    cd ${code_root}/HoG/
    matlab -nojvm -nosplash -nodisplay -r learn\(\'${image_root}\',\'${feature_root}\',\'${root}/data/dataset/$1_imagepath.txt\',\'${query}\',0,0,1\); 
    cd -
fi

