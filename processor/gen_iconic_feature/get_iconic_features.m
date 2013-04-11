function get_iconic_features(query, feature_root)
    config_data = gen_config_data(query, feature_root)
    features = config_data.features;
    for f = 1:length(features)
        feature = features{f};
        if(feature.doPCA==1)
            pcaFeaturePath = fullfile(config_data.featureRoot, feature.name, config_data.query, [feature.featureFileName, sprintf('_pca%d.mat', feature.pcaDim)]);
            pcaVectorPath = fullfile(config_data.featureRoot, feature.name, config_data.query, [feature.featureFileName, sprintf('_pca_vector_%d.mat', feature.pcaDim)]);
            if(~exist(pcaFeaturePath, 'file'))
   	        featurePath = fullfile(config_data.featureRoot, feature.name, config_data.query, 'all', [feature.featureFileName, '.mat'])
                load(featurePath);
                eval(feature.cmdGetFeature);
                fprintf('Doing PCA on %s\n', feature.name);
                % If data is larger than the set treshold, sample the data
                % to calculate pca projection matrix.
                max_size = 500000;
                if (size(data, 1) > max_size)
                    fprintf('sample data to %d\n', max_size);
                    sample_index = randperm(max_size);
                    data = data(sample_index, :);
                    size(data)
                    [data, u] = pca_feature(data, feature.pcaDim);
                    save(pcaVectorPath, 'u', '-v7.3');
                    clear data;
                    fprintf('Done PCA vector generation.\n');
                    featurePath = fullfile(config_data.featureRoot, feature.name, config_data.query, 'all', [feature.featureFileName, '.mat']);
                    fprintf('Load data again.\n');
                    load(featurePath);
                    eval(feature.cmdGetFeature);
                    class(data)
                    size(data)
                    fprintf('Doing PCA.\n');
                    
                    bin_size = 500;
                    fprintf('begin sqrt.\n');
                    tic;
                    for i = 1:bin_size:size(data, 2)
                      headi = i;
                      taili = min(i + bin_size - 1, size(data, 2));
                       data(:, headi:taili) = sqrt(data(:, headi:taili));
                    end
                    toc;

                    fprintf('begin projecting feature.\n');
                    data = data * u;
                else
                    [data, u] = pca_feature(data, feature.pcaDim);
                end
                
                fprintf('Done PCA\n');
                fprintf('Saving PCA data\n');
                save(pcaFeaturePath, 'data', '-v7.3');
                clear data;
            end
        end        
    end
    visFeatures = [];
    for f = 1:length(features)
        feature = features{f};
        if(~strncmp(feature.name, 'tag', length('tag')))
            fprintf('loading feature %s\n', feature.name);
            if(feature.doPCA==1)            
                pcaFeaturePath = fullfile(config_data.featureRoot, feature.name, config_data.query, [feature.featureFileName, sprintf('_pca%d.mat', feature.pcaDim)]);
                load(pcaFeaturePath);            
            else
                featurePath = fullfile(config_data.featureRoot, feature.name, config_data.query, [feature.featureFileName, '.mat']);
                load(featurePath);
                eval(feature.cmdGetFeature);
            end
            visFeatures = [visFeatures, data];
            clear data;
        end
    end
    tagFeatures = [];
    for f = 1:length(features)
        feature = features{f};
        if(strncmp(feature.name, 'tag', length('tag')))
            featurePath = fullfile(config_data.featureRoot, feature.name, config_data.query, [feature.featureFileName, sprintf('.mat')]);
            load(featurePath);            
            eval(feature.cmdGetFeature);
            tagFeatures = data;
            clear data;
        end
    end
    
    [output_dir, drop] = fileparts(config_data.visual_features_output_path);
    if (~exist(output_dir, 'dir'))
        mkdir(output_dir);
    end
    save(sprintf('%s', config_data.visual_features_output_path), 'visFeatures', '-v7.3');
    size(visFeatures)
    size(tagFeatures)    
end
