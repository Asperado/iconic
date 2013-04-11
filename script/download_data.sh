query=$1
root_dir='../../test_dir'
code_dir='..'

python ${code_dir}/data_collection/task_download_meta.py -q ${query} -r ${root_dir} 

# For running on multiple machines, use i to specify the chunk each machine will handle.
#for i in {0..3}
#do
#    python ${code_dir}/data_collection/task_mr_download_meta.py -q ${query} -r ${root_dir} -d ${i}
#done