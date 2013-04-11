function task_run_iconic(query, root_path, tag_dim, cca_feature_dim, num_clusters)

  config = gen_iconic_config_data(query, ...
				  root_path, ...
				  tag_dim, ...
				  cca_feature_dim, ...
				  num_clusters)

  if (~exist(config.cluster_path, 'file'))
    fprintf('Generate tag cluster\n');
    tag_mat = config.database.get_tag_feature();
    
    [index, dict] = cluster_sparse_tag_feature(tag_mat, config.current_tag_cluster_dim);
    cluster = {};
    cluster.dict = dict;
    cluster.index = index;
    cluster.dim = config.current_tag_cluster_dim;
    save(config.cluster_path, 'cluster', '-v7.3');
  end

  for i = 1:length(config.cca_feature_dim)
    cca_feature_dim = config.cca_feature_dim(i);
    fprintf('Run dimension %d\n', cca_feature_dim);

    % Doing cca
    fprintf('Get cca result.\n');
    get_large_scale_cca(cca_feature_dim, ...
                                config.feature_path, ...
                                config.tag_path, ...
                                config.cluster_path, ...
                                config.cca_path, ...
                                0);

    % Generate web page showing clusters
    fprintf('Get iconic result.\n');
    
    current_result_name = sprintf('result_%d_%s', cca_feature_dim, config.iconic_result_id);
    iconic_result_output_root = config.iconic_result_output_root;
    
    result = get_iconic_result(current_result_name, ...
                            iconic_result_output_root, ...
                            config.iconic_cluster_size, ...
                            cca_feature_dim, ...
                            config.cca_feature_path, ...
                            config.cca_path, ...
                            config.tag_path, ...
                            config.feature_path, ...
                            config.cluster_path);
    
    config.iconic_web_page_name_rerank = sprintf('%s_11', config.iconic_web_page_name);
    fprintf('Gen rerank iconic result.\n');
    
    gen_iconic_web_page_json(result{1}.clusters, ...
                            config.database, ...
                            config.iconic_web_page_name, ...
                            config.web_page_output_root, ...
                            config.meta_root, ...
                            config.show_top_k);

%    gen_iconic_web_page_json_rerank(result{1}.clusters, ...
%                                    config.database, ...
%                                    config.iconic_web_page_name_rerank, ...
%                                    config.web_page_output_root, ...
%                                    config.meta_root, ...
%                                    config.show_top_k, ...
%                                    config);

    fprintf('Done generate iconic result for dimension %d\n', cca_feature_dim);
  end
  exit(0);
end
