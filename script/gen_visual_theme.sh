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

code_root='../processor/gen_visual_theme'

cd ${code_root}
matlab -nojvm -nosplash -nodisplay -singleCompThread -r task_gen_visual_theme_d3\(\'${query}\',\'${root}\',${tag_dim},${cca_dim},${cluster_num}\)
cd -
