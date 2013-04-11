function gen_iconic_web_page_json_rerank( clusters, ...
                                        database, ...
                                        result_name, ...
                                        result_output_root, ...
                                        meta_root, ...
                                        show_top_k_images, ...
                                        config)

    cluster_image_id = cell(length(clusters), 1);
    for cid = 1:length(clusters)
        cluster_image_id{cid} = clusters{cid}.index;
    end
    assert(length(cluster_image_id) == length(clusters));
        
    tag_mat = database.get_tag_feature();
    cluster_rank = 1:length(cluster_image_id);
    
    nodes_comment = {};
    do_merge = 1;
    if (do_merge)
        top_k_overlap = 0.3;

        cluster_score = ones(length(clusters));

        vis_mat = [];
        fprintf('Load cca visual feature.\n');
        cca_feature = get_cca_features(config.cca_feature_dim(1),...
                                 config.feature_path,...
                                 config.tag_path,...
                                 config.cluster_path,...
                                 config.cca_path,...
                                 config.cca_feature_path);
        vis_mat = cca_feature{1}.eSXX;
        clusters_vis_density_path = sprintf('%s/Iconic/tmp/clusters_vis_density_%s_new.mat', config.root_path, config.query);
        cluster_density = get_clusters_feature_density(clusters_vis_density_path, clusters, vis_mat, 100);
        clear vis_mat;
        cluster_score = -cluster_density;

%        [is_merged_tmp, new_clusters, mapped_index, merged_info] = merge_clusters_by_visual_theme( clusters, ...,
%                                                                                            cluster_score, ...
%                                                                                            tag_mat, ...
%                                                                                            100, ...
%                                                                                            0.2);
                                                                                        
        [is_merged, new_clusters, mapped_index, merged_info] = merge_clusters_by_visual_theme_2(clusters, ...,
                                                                                                    tag_mat);
                                                                                        
%        [is_merged, new_clusters, mapped_index, merged_info] = merge_clusters_iterative(clusters, ...
%                                                                                        cluster_score, ...
%                                                                                        0.1, ...
%                                                                                        36, ...
%                                                                                        is_merged);
        

         new_cluster_rank = [];
         for iter = 1:length(cluster_rank)
             cid = cluster_rank(iter);
             if (~is_merged(cid))
                 new_cluster_rank(end + 1) = cid;
             end
         end
         cluster_rank = new_cluster_rank;

        % Rank clusters according to its synsets's size
        cluster_synsets_size = zeros(1, length(cluster_rank));
        for iter = 1:length(cluster_rank)
            cid = cluster_rank(iter);
            cluster_synsets_size(iter) = length(merged_info{cid}.synsets);
        end
        [drop, temp_order] = sort(-cluster_synsets_size);
        cluster_rank = cluster_rank(temp_order);         

        for iter = 1:length(cluster_rank)
         cid = cluster_rank(iter);
         comment = sprintf('visual consistency: %f', cluster_density(cid));
         nodes_comment{end + 1} = comment;
        end

    end
    
    gen_clusters_result_header(cluster_rank,...
                              clusters,...
                              result_output_root,...
                              result_name, ...
                             'nodes_comment', nodes_comment);
     
end

