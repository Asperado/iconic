# Begin parameters setting.
# query: the concept to process.
# tag_dim: the number of top tags we extract for tag features.
# cluster_num: the number of clusters.
  query=$1
  cca_dim=500
  tag_dim=1000
  cluster_num=100
  root=/Users/hongtaohuang/Desktop/magiconic/test_dir
# End parameters setting.

code_root='../processor/cca'
# Prefer to have 40 GB memory for 1 million images.

cd ${code_root}
matlab -nojvm -nosplash -nodisplay -singleCompThread -r task_run_iconic\(\'${query}\',\'${root}\',${tag_dim},${cca_dim},${cluster_num}\)
cd -
