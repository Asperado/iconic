query=$1
tag_dim=1000
feature_root=../../../test_dir/data/features
image_id_file=../../../test_dir/data/dataset/${query}.txt
echo $feature_root
echo $image_id_file
cd ../processor/tag_cluster
/Applications/MATLAB_R2011a.app/bin/matlab -nojvm -nosplash -nodisplay -singleCompThread -r gen_tag_features_sparse_fast\(\'${query}\',${tag_dim},\'${feature_root}\',\'${image_id_file}\'\);