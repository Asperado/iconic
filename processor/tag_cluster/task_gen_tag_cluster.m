function task_gen_tag_cluster(query, tag_dim, feature_root, feature_path, cluster_num)
  run_id = 1;
  output_root = sprintf('%s/tag%d/%s', feature_root, tag_dim, query);
  output_path = sprintf('%s/tag%d_cluster_%d_%d.mat', ...
			output_root, tag_dim, run_id, cluster_num);
  if (~exist(output_path, 'file'))
    addpath('./kmeans');
    tag_mat = load(feature_path);
    tag_mat = tag_mat.featureData;
    mkdir(output_root);
  
    [index, dict] = cluster_sparse_tag_feature(tag_mat, cluster_num);
    cluster = {};
    cluster.dict = dict;
    cluster.index = index;
    cluster.dim = cluster_num;
    save(output_path, 'cluster', '-v7.3');
  else
    fprintf('Tag clustering already done.\n');
  end
  exit(0);
end
