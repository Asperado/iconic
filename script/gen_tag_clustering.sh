query=$1
tag_dim=1000
cluster_num=100

root=~/Desktop/magiconic/test_dir
feature_root=${root}/data/features/
feature_path=${feature_root}/tag${tag_dim}/${query}/tag${tag_dim}_sparse.mat

cd ../processor/tag_cluster

matlab -nojvm -nosplash -nodisplay -singleCompThread -r task_gen_tag_cluster\(\'${query}\',${tag_dim},\'${feature_root}\',\'${feature_path}\',${cluster_num}\);