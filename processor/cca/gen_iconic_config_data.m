function config = gen_iconic_config_data(query, root_path, tag_dim, cca_feature_dim, num_clusters)

  fprintf('Load Configureation...\n');
  addpath('../tag_cluster'); 
  addpath('../visualization_meta'); 
  addpath('../database');
  addpath('../basic');
  addpath(genpath('../third_party_lib'));
  
  config.query = query;
  config.root_path = root_path;
  config.feature_root = sprintf('%s/data/features/', config.root_path);
  config.meta_root = sprintf('%s/data/meta/%s', config.root_path, config.query);

  % Tag Feature and Tag List Paths
  config.tag_dim = tag_dim;
  config.tag_path = sprintf('%s/data/features/tag%d/%s/tag%d_sparse.mat', config.root_path, ...
			    config.tag_dim, ...
			    config.query, ...
			    config.tag_dim);
  config.taglist_path = sprintf('%s/data/features/tag%d/%s/tag%d_tags.mat', config.root_path, ...
				config.tag_dim, ...
				config.query, ...
				config.tag_dim);

  % Visual Feature Path
  config.feature_path = sprintf('%s/data/features/VisualFeatures/%s/visFeatures.mat', config.root_path, config.query);

  % Cluster Path
  config.clusters = [num_clusters];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !!! If you change visual feature, tag feature, or clustering feature,
% please update the cca path, to avoid overriding previous results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  config.current_tag_cluster_dim  = config.clusters(1);
  config.cca_feature_dim = [cca_feature_dim];
  config.cluster_path = sprintf('%s/data/features/tag%d/%s/tag%d_cluster_1_%d.mat', ...
		              config.root_path, ...
			      config.tag_dim, ...
			      config.query, ...
			      config.tag_dim, ...
			      config.current_tag_cluster_dim);
  config.cca_output_dir = sprintf('%s/data/cca_result/%s_result', ...
				config.root_path, ...
				config.query);

  config.cca_path = (sprintf('%s/result_%d_tag_cluster.mat', ...
			   config.cca_output_dir, ...
			   config.current_tag_cluster_dim));

  config.cca_feature_path = sprintf('%s/tmp/cca_result_%s_%d_%d_tag_cluster.mat', ...
				    config.root_path, ...
				    config.query, ...
				    config.cca_feature_dim(1), ...
				    config.current_tag_cluster_dim);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !!!Update the web page name for a new run.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Iconic Result Parameters
  config.show_top_k = 100;
  config.iconic_cluster_size = 500;

  config.iconic_result_id = sprintf('iconic_%s_%d', config.query, config.current_tag_cluster_dim);
  config.iconic_web_page_name = config.iconic_result_id;
  config.iconic_result_output_root = sprintf('%s/data/iconic_result/%s/', ...
					     config.root_path, ...
					     config.query);

  % For loading iconic clusters of different applications.
  config.default_iconic_path =  sprintf('%s/result_%d_%s', ...
				      config.iconic_result_output_root, ...
				      config.cca_feature_dim(1), ...
				      config.iconic_result_id);
  config.classifier_iconic_path = config.default_iconic_path;
  config.merge_visual_theme_iconic_path = config.default_iconic_path;
                                        
  config.web_page_output_root = sprintf('%s/web/cluster', config.root_path);

  % Database
  config.database = IconicDatabase(config.query, config.root_path, config.tag_dim);
end
