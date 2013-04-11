Environment Setup:
  1. Install python 2.7
  2. Install nltk
  3. Install WordNet in nltk
  4. Matlab
  5. use Matlab to complie processor/HoG/features.cc

  NOTE: the system can be modified to run on Windows system, currently, it supports linux.

Running:

  1. Decide the parameters, before running.
    query: the single keyword to use for collecting data from Flickr.
    root_dir/root: the root directory for all data, please use absolute path.
    tag_dim: the number of top tags we extract for tag features.
    cluster_num: the number of clusters.
    do_dictionary_generation: set to 1, if dictionary has not been generated, i.e. first time doing step 5.
    do_dense_sift: set to 1, if you want to use dense RGB SIFT.
    do_harris_sift: set to 1, if you want to use harris RGB SIFT.
    do_hog: set to 1, if you want to use HoG.
    do_rgb: set to 1, if you want to use RGB.
    
  2. Change the parameters in step 1, in all the shell script in the following steps accordingly.
  3. Go to script directory.
  4. Download Flickr data.
    sh ./download_data.sh ${query}
  5. Extract tag features and do tag clustering.
    sh ./extract_tag_feature_and_semantics.sh ${query}
  6. Extract visual features.
    sh ./extract_visual_feature.sh ${query}
  7. Build iconic image clusters.
    sh ./gen_iconic.sh ${query}
