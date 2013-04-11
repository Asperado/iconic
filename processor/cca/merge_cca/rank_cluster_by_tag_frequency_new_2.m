function cluster_rank = rank_cluster_by_tag_frequency_new_2(cluster_image_id, tag_mat)
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
    top_k_tags = 300;
    top_k_tags = min(size(tag_mat, 2), top_k_tags);
    tag_count = tag_count(:, 1:top_k_tags);

    all_tag_count = sum(tag_count, 1);
    [drop, top_tag_index] = sort(-all_tag_count);
    top_k_tags_2 = 10;
    tag_count = tag_count(:, top_tag_index(1:top_k_tags_2));
    
    % Add the feature: only rank the tag that are popular. 
    % This will favor some clusters where images are tagged with lot
    % of similar tags. 
    % To make cluster with unique theme to come out, we rank cluster 
    % according to their average tag count.
    % min_tag_threshold = 20;
    % tag_count = tag_count > min_tag_threshold;
    % tag_count = tag_count./repmat(sum(tag_count,2), 1, size(tag_count, 2));
    
    tag_score = -tag_count;
    [drop, cluster_rank] = sortrows(tag_score);
    assert(length(cluster_rank) == top_cluster_num);
end