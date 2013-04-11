query=$1
root=~/Desktop/magiconic/test_dir
feature_root=${root}/data/features/
code_root=../processor/gen_iconic_feature

# Require 30~40 GB for 1 million images.
cd ${code_root}

matlab -nojvm -nosplash -nodisplay -singleCompThread -r get_iconic_features\(\'${query}\',\'${feature_root}\'\);

cd -