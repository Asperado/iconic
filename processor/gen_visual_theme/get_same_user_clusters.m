function get_same_user_clusters(config)
  clusters = config.database.get_iconic_clusters(config.default_iconic_path);
  image_owners = load(sprintf('%s/data/extra_info/%s_owners.mat', ...
			      config.root_path, ...
			      config.query));
  image_owners = image_owners.owners;

  cluster_image_size = 50;
  visual_theme_threshold = 0.1;
  same_threshold = ceil(cluster_image_size * visual_theme_threshold);
  %same_threshold = 2;
  same_owner_cluster_path = sprintf('%s/data/extra_info/%s_same_owner.mat', ...
				    config.root_path, ...
				    config.query);

  n_owners = max(image_owners);
  same_owner = zeros(1, length(clusters));
  for cid = 1:length(clusters)
      image_ids = clusters{cid}.index;
      image_ids = image_ids(1:cluster_image_size);
      cluster_image_owner = image_owners(image_ids);
      count = zeros(size(image_ids, 1), n_owners);
      for iter = 1:length(image_ids)
          count(cluster_image_owner(iter)) = count(cluster_image_owner(iter)) + 1;
      end
      max_user = max(count);
      if (max_user >= same_threshold)
          same_owner(cid) = 1;
      end
  end
  length(find(same_owner))
  save(same_owner_cluster_path, 'same_owner');

%  result_output_root = config.web_page_output_root;
%  result_name = sprintf('same_owner_%s', config.query);
%  cluster_rank = find(same_owner);
%  gen_clusters_result_header(cluster_rank,...
%                              clusters,...
%                              result_output_root,...
%                              result_name);
end
