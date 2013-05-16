Environment Setup:
  1. Install python 2.7
  2. Install nltk
  3. Install WordNet in nltk
    import nltk
    nltk.download('wordnet')
  4. Install Flickr API
    http://stuvel.eu/flickrapi#installation
  5. Matlab
  6. use Matlab to complie processor/HoG/features.cc
    If you are using Mac OS and you encounter error while mexing file, you may need this patch. http://www.mathworks.com/support/solutions/en/data/1-FR6LXJ/
  7. Choose the correct version of colorDescriptor in processor/visual_feature/HarrisRGB_SIFT/sift and processor/visual_feature/DenseRGB_SIFT/sift, depending on the platform (windows, linux, mac). For Windows user, you may need to change the extractDescriptor.m to invoke the colorDescriptor.exe.

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
    You can terminate the program any time you want. It can be re-runned and not downloading the data already downloaded.
    When you terminate your program, it will find the downloaded images Flickr id at ${root_dir}/data/dataset/${query}.txt . Then you know how many data you have downloaded so far.
    
  5. Extract tag features and do tag clustering.
    sh ./extract_tag_feature_and_semantics.sh ${query}
  6. Extract visual features.
    sh ./extract_visual_feature.sh ${query}
  7. Build iconic image clusters.
    sh ./gen_iconic.sh ${query}
    => Result is at ${root_dir}/web/iconic_${query}_${cluster_num}
  8. Build iconic visual themes.
    sh ./gen_visual_theme.sh ${query}
    => Result is at ${root_dir}/web/visual_theme_${query}
  
  9. Web Page Generation
    Copy the all the files in index_page to ${root_dir}/web

    After finishing step 7, you can view in your browser (Firefox, Safari) iconic clusters:
      ${root_dir}/web/image_tables.html?result_name=iconic_${query}_${cluster_num}&result_feed=iconic_${query}_${cluster_num}
    After finishing step 8, you can view in your browser (Firefox, Safari) visual theme and tag cloud:
      ${root_dir}/web/image_groups.html?result_name=visual_theme_${query}&result_feed=iconic_${query}_${cluster_num}
      ${root_dir}/web/tag_cloud.html?result_name=visual_theme_${query}&result_feed=iconic_${query}_${cluster_num}

    NOTE: Google Chrome does not support offline browsing, you need to set up a server to have access to the ${root_dir}/web and view the pages.
