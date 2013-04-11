function [is_merged, new_clusters, mapped_index, merged_info] = merge_clusters_by_visual_theme_2( clusters, ...,
                                                                        tag_mat, ...
                                                                        varargin)
%                                                                        cluster_score, ...
%                                                                        cluster_image_size, ...
%                                                                        visual_theme_threshold)
    opt=varargin2struct(varargin{:});
    cluster_score = jsonopt('cluster_score', zeros(1, length(clusters)), opt);
    cluster_image_size = jsonopt('cluster_image_size', 100, opt);
    visual_theme_threshold = jsonopt('visual_theme_threshold', 0.1, opt);
    filtered_cluster = jsonopt('filtered_cluster', [], opt);
    
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

    % Excluding the most frequent tags, which is the query.
    cluster_tag_mat = cluster_tag_mat(:, 2:end);
    
    is_merged = zeros(1, length(clusters));
    merged_info = cell(length(clusters), 1);
    for c1 = 1:length(merged_info)
        merged_info{c1}.synsets = [];
    end
    is_merged(filtered_cluster) = 1;
    
    for c1 = 1:length(clusters)
        if (is_merged(c1))
            continue;
        end
        for c2 = c1 + 1:length(clusters)
            if (is_merged(c2))
                continue;
            end
            c1_mat = cluster_tag_mat(c1, :);
            c2_mat = cluster_tag_mat(c2, :);
            union_mat = cluster_tag_mat(c1, :) | cluster_tag_mat(c2, :);
            do_merge = 0;
            if (sum(union_mat - c1_mat) == 0)
                do_merge = 1;
                merged_id = c2;
                merged_to = c1;
                if (sum(union_mat - c2_mat) == 0)
                    if (cluster_score(c2) > cluster_score(c1))
                        merged_id = c1;
                        merged_to = c2;
                    end
                end
            elseif (sum(union_mat - c2_mat) == 0)
                do_merge = 1;
                merged_id = c1;
                merged_to = c2;
            end
            if (do_merge)
                merged_info{merged_to}.synsets(end + 1) = merged_id;
                fprintf('merge cluster %d to %d.\n', merged_id, merged_to);
                is_merged(merged_id) = 1;
            end
            if (is_merged(c1))
                break;
            end
        end
        merged_info{c1}.synsets(end + 1) = c1;
        merged_info{c1}.synsets = unique(merged_info{c1}.synsets);
        transfer_merged_info = merged_info{c1}.synsets;
        for iter = 1:length(merged_info{c1}.synsets)
            c2 = merged_info{c1}.synsets(iter);
            merged_info{c2}.synsets(end + 1 : end + length(transfer_merged_info)) = transfer_merged_info;
            merged_info{c2}.synsets = unique(merged_info{c2}.synsets);
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