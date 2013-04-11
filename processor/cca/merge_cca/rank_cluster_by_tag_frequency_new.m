function cluster_rank = rank_cluster_by_tag_frequency_new(cluster_image_id, tag_mat)
    n_clusters = length(cluster_image_id);
    fprintf('Ranking clusters.\n');
    tag_count = zeros(n_clusters, size(tag_mat, 2));
    for cid = 1:n_clusters
        cluster_image_size = 100;
        image_ids = cluster_image_id{cid};
        cluster_image_size = min(cluster_image_size, length(image_ids));
        image_ids = image_ids(1:cluster_image_size);
        tag_count(cid,:) = sum(tag_mat(image_ids,:), 1);
    end
    fprintf('Generating top tag clusters\n.');
    top_cluster_num = n_clusters;
    top_k_tags = 500;
    top_k_tags = min(size(tag_mat, 2), top_k_tags);
    global_tag_feature = sum(tag_mat, 1);
    global_tag_feature = global_tag_feature(:, 1:top_k_tags);
    tag_count = tag_count(:, 1:top_k_tags);
    tag_count = Normalize(tag_count);
    global_tag_feature = Normalize(global_tag_feature);
    tag_count = full(tag_count);
    global_tag_feature = full(global_tag_feature);
    tag_score = dist_mat(tag_count, global_tag_feature);
    [drop, cluster_rank] = sort(tag_score);
    assert(length(cluster_rank) == top_cluster_num);
end