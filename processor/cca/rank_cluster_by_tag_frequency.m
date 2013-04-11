function cluster_rank = rank_cluster_by_tag_frequency(cluster_image_id, tag_mat)
    n_clusters = length(cluster_image_id);
    fprintf('Ranking clusters.\n');
    tag_count = zeros(n_clusters, size(tag_mat, 2));
    tic;
    for cid = 1:n_clusters
        tag_count(cid,:) = sum(tag_mat(cluster_image_id{cid}(1:100),:), 1);
    end
    toc;
    fprintf('Generating top tag clusters\n.');
    top_cluster_num = n_clusters;
    cluster_rank = zeros(1, top_cluster_num);
    cluster_visited = zeros(1, n_clusters);
    for c = 1:top_cluster_num
        for iter = 1:top_cluster_num
            [drop, top_cluster] = max(tag_count(:,c));
            if (cluster_visited(top_cluster) == 0)
                cluster_visited(top_cluster) = 1;
                break;
            else
                tag_count(top_cluster, c) = -1;
            end
        end
        cluster_rank(c) = top_cluster;
    end
end

