function gen_tag_features_sparse_fast(query, tag_dim, feature_root, image_id_file)
    filenames = getStringListFromTxt(image_id_file);
    root_dir = sprintf('%s/tag%d/%s', feature_root, tag_dim, query);

    max_files = length(filenames);
    for i = 1:max_files
        sub_folder = filenames{i}(1:5);
        tag_file = sprintf('%s/%s/tag%d_%s.mat', root_dir, sub_folder, tag_dim, filenames{i});
        filenames{i} = tag_file;
    end
    
    feature = load(filenames{i});
    feature = feature.featureData;
    dim = size(feature, 2);
    
    last_run_time = 1;
    fprintf('%d elements.\n', length(filenames));
    tic;
    rows = zeros(1, 20000000);
    cols = zeros(1, 20000000);
    cnts = 1;
    rows_num = length(filenames);
    cols_num = tag_dim;

    bad_count = 0;
    for i = 1:max_files
      try
        feature = load(filenames{i});
      catch
        delete(filenames{i});
        bad_count = bad_count + 1;
        fprintf('remove element %s.\n', filenames{i})
        continue;
      end
        feature = feature.featureData;
             
        [x,y] = find(feature==1);
        x = x.*i;
        rows(cnts:cnts + length(x) - 1) = x;
        cols(cnts:cnts + length(y) - 1) = y;
        cnts = cnts + length(x);
        
        if (mod(i,1000) == 0)
            last_run_time = toc;
            fprintf('%d %f\n', i, last_run_time * (length(filenames) - i) / 1000);
            tic;
        end
    end
    rows = rows(1:cnts - 1);
    cols = cols(1:cnts - 1);
    featureData = sparse(rows, cols, 1, rows_num, cols_num);
    
    output_file = sprintf('%s/%s.mat', root_dir, sprintf('tag%d_sparse', tag_dim));
    if (bad_count == 0)
      save(output_file, 'featureData', '-v7.3');
    else
      fprintf('Has %d bad features.\n', bad_count);
    end
    exit(0);
end

