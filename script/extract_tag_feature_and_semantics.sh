# Begin parameters setting.
# query: the concept to process.
# tag_dim: the number of top tags we extract for tag features.
# cluster_num: the number of clusters.
  query=$1
  tag_dim=1000
  cluster_num=100
  root_dir='/Users/hongtaohuang/Desktop/magiconic/test_dir'
# End parameters setting.

code_dir='..'
feature_root=${root_dir}/data/features
image_id_file=${root_dir}/data/dataset/${query}.txt
tag_feature_path=${feature_root}/tag${tag_dim}/${query}/tag${tag_dim}_sparse.mat
echo 'set feature root to: '${feature_root}
echo 'generate image id file at: ' $image_id_file

echo 'Constructing image meta data.'
# Memory 8GB for 1 million images, recommended core number 5.
python ${code_dir}/data_collection/database_builder/gen_photo_meta.py -r ${root_dir} -q ${query} -t ${tag_dim}

echo 'Building tag features.'
cd ../processor/tag_cluster
matlab -nojvm -nosplash -nodisplay -singleCompThread -r gen_tag_features_sparse_fast\(\'${query}\',${tag_dim},\'${feature_root}\',\'${image_id_file}\'\);
cd -

echo 'Building tag clusters.'
cd ../processor/tag_cluster
matlab -nojvm -nosplash -nodisplay -singleCompThread -r task_gen_tag_cluster\(\'${query}\',${tag_dim},\'${feature_root}\',\'${tag_feature_path}\',${cluster_num}\);