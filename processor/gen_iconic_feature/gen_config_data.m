function config_data = gen_config_data(query, feature_root)
  config_data.query = query;
  config_data.featureRoot = feature_root;
  config_data.visual_features_output_path = sprintf('%s/VisualFeatures/%s/visFeatures.mat',... 
                config_data.featureRoot, ...
                config_data.query);

  config_data.blocks = 1;
  config_data.features = {};

  config_data.use_rgb = 1;
  config_data.use_hog = 1;
  config_data.use_dense_rgb_sift = 1;
  config_data.use_harris_rgb_sift = 1;
  config_data.use_gist = 0;

  if (config_data.use_rgb == 1)
    feature.name = 'RGB';
    feature.cmdGetFeature = 'data = X;clear X;';
    feature.featureFileName = feature.name;
    feature.doPCA = 1;
    feature.pcaDim = 500;
    config_data.features{end+1} = feature;
  end

  if (config_data.use_gist == 1)
    feature.name = 'GIST';
    feature.cmdGetFeature = 'data = data.featureData;';
    feature.featureFileName = feature.name;
    feature.doPCA = 0;
    feature.pcaDim = 512;
    config_data.features{end+1} = feature;
  end

  if (config_data.use_hog == 1)
    feature.name = 'HOG';
    feature.cmdGetFeature = 'data = SPM;clear SPM;';
    feature.featureFileName = feature.name;
    feature.doPCA = 1;
    feature.pcaDim = 500;
    config_data.features{end+1} = feature;
  end

  if (config_data.use_dense_rgb_sift == 1)
    feature.name = 'DenseRGBSIFT';
    feature.cmdGetFeature = 'data = SPM;clear SPM;';
    feature.featureFileName = feature.name;
    feature.doPCA = 1;
    feature.pcaDim = 500;
    config_data.features{end+1} = feature;
  end

  if (config_data.use_harris_rgb_sift == 1)
    feature.name = 'HarrisRGBSIFT';
    feature.cmdGetFeature = 'data = SPM;clear SPM;';
    feature.featureFileName = feature.name;
    feature.doPCA = 1;
    feature.pcaDim = 500;
    config_data.features{end+1} = feature;
  end
end
