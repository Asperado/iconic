query=$1
tag_dim=1000
cca_dim=500
cluster_num=100
root=~/Desktop/magiconic/test_dir

code_root='../processor/cca'

# Prefer to have 40 GB memory for 1 million images.

cd ${code_root}
matlab -nojvm -nosplash -nodisplay -singleCompThread -r task_run_iconic\(\'${query}\',\'${root}\',${tag_dim},${cca_dim},${cluster_num}\)
cd -
