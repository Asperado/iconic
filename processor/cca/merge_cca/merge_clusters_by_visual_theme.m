function [is_merged, new_clusters, mapped_index, merged_info] = merge_clusters_by_visual_theme( clusters, ...,
                                                                        cluster_score, ...
                                                                        tag_mat, ...
                                                                        cluster_image_size, ...
                                                                        visual_theme_threshold)
    if (~exist('cluster_score', 'var'))
        fprintf('Not provide cluster score, treat all clusters equally.\n');
        cluster_score = zeros(1, length(clusters));
    end
    if (~exist('cluster_image_size', 'var'))
        cluster_image_size = 100;
    end
    if (~exist('visual_theme_threshold', 'var'))
        visual_theme_threshold = 0.2;
    end
    
    
    cluster_tag_mat = zeros(length(clusters), size(tag_mat, 2));
    for cid = 1:length(clusters)
        image_ids = clusters{cid}.index;
        image_ids = image_ids(1:min(length(image_ids), cluster_image_size));
        cluster_tag_mat(cid, :) = sum(tag_mat(image_ids, :), 1);
    end

    cluster_image_size = length(image_ids);
    visual_theme_num = floor(cluster_image_size * visual_theme_threshold);

    fprintf('cluster image size set to %d.\n', cluster_image_size);
    fprintf('visual theme number set to %d.\n', visual_theme_num);
    cluster_tag_mat = cluster_tag_mat > visual_theme_num;
    
    % Using L2 distance, try to compare whether two vectors are similar or
    % not.
    cluster_dist = dist_mat(cluster_tag_mat, cluster_tag_mat);

    is_merged = zeros(1, length(clusters));
    merged_info = cell(length(clusters));
    for c1 = 1:length(merged_info)
        merged_info{c1}.synsets = [];
    end
    
    for c1 = 1:length(clusters)
        if (is_merged(c1))
            continue;
        end
        similar_clusters = find(cluster_dist(c1, :) == 0);
        for sid = 1:length(similar_clusters)
            c2 = similar_clusters(sid);
            if (c2 <= c1)
                continue;
            end
            if (is_merged(c2))
                continue;
            end
            merged_id = c1;
            merged_to = c2;
            if (is_merged(c1) || cluster_score(c1) < cluster_score(c2))
                merged_id = c2;
                merged_to = c1;
            end
            merged_info{merged_to}.synsets(end + 1) = merged_id;
            fprintf('merge cluster %d to %d.\n', merged_id, merged_to);
            is_merged(merged_id) = 1;
        end
        merged_info{c1}.synsets(end + 1) = c1;
        for iter = 1:length(merged_info{c1}.synsets)
            c2 = merged_info{c1}.synsets(iter);
            transfer_merged_info = merged_info{c1}.synsets;
            merged_info{c2}.synsets(end + 1 : end + length(transfer_merged_info)) = transfer_merged_info;
            merged_info{c2}.synsets(end + 1) = c1;
        end
    end
          
    for c1 = 1:length(clusters)
        merged_info{c1}.synsets = unique(merged_info{c1}.synsets);
    end
    
    mapped_index = [];
    next_cluster_index = 1;
    new_clusters = {};
    for i = 1:length(clusters)
        if (~is_merged(i))
            mapped_index(next_cluster_index) = i;
            new_clusters{end + 1} = clusters{i};
            next_cluster_index = next_cluster_index + 1;
        end
    end
    assert(next_cluster_index - 1 == length(new_clusters));
    fprintf('After merging, has %d clusters.\n', length(new_clusters));    
end
