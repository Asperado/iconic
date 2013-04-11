function cluster_rank = rank_clusters_by_tag(clusters_index, clusters, tag_mat)
    cluster_image_id = {};
    for iter = 1:length(clusters_index)
        cid = clusters_index(iter);
        cluster_image_id {end + 1} = clusters{cid}.index;
    end
%    cluster_rank = rank_cluster_by_tag_frequency_tf_idf(cluster_image_id, tag_mat);
    cluster_rank = rank_cluster_by_tag_frequency_new_2(cluster_image_id, tag_mat);
end
