query=$1
code_dir='..'
code_dir=`echo $(cd ${code_dir}; pwd)`
root_dir='../../test_dir'
root_dir=`echo $(cd ${root_dir}; pwd)`


# Memory 8GB for 1 million images, recommended core number 5.
python ${code_dir}/data_collection/database_builder/gen_photo_meta.py -r ${root_dir} -q ${query} -t 1000
