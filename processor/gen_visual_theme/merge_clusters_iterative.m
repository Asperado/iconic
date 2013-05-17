function [is_merged, new_clusters, mapped_index, merged_info] = merge_clusters_iterative( clusters, ...
                                                                                        cluster_score, ...
                                                                                        top_k_overlap, ...
                                                                                        cluster_image_size, ...
                                                                                        pre_merged)

    if (~exist('cluster_score', 'var'))
        fprintf('Not provide cluster score, treat all clusters equally.\n');
        cluster_score = zeros(1, length(clusters));
    end
    if (~exist('top_k_overlap', 'var'))
        top_k_overlap = 0.1;
    end
    if (~exist('top_k_overlap', 'var'))
        cluster_image_size = 100;
    end    
    
    fprintf('Top k overlap threshold set to %f.\n', top_k_overlap);
    
    is_merged = zeros(1, length(clusters));
    if (exist('pre_merged', 'var'))
       is_merged = pre_merged;
       assert(length(is_merged) == length(clusters));
    end
    
    merged_info = cell(length(clusters), 1);
    for c1 = 1:length(merged_info)
        merged_info{c1}.synsets = [];
    end
    
    for c1 = 1:length(clusters)
        if (is_merged(c1))
            continue;
        end
        for c2 = c1 + 1:length(clusters)
            if (is_merged(c2))
                continue;
            end
            I1 = clusters{c1}.index(1:min(length(clusters{c1}.index), cluster_image_size));
            I2 = clusters{c2}.index(1:min(length(clusters{c2}.index), cluster_image_size));
            I = intersect(I1, I2);
            do_merge = 0;
            if (length(I) > (length(I1) + length(I2) - length(I))* top_k_overlap)
                do_merge = 1;
            end
            if (do_merge)
                merged_id = c2;
                merged_to = c1;
%                if (is_merged(c1) || cluster_score(c1) < cluster_score(c2))

                merged_info{merged_to}.synsets(end + 1) = merged_id;
                fprintf('merge cluster %d to %d, with %d shared images.\n', merged_id, merged_to, length(I));
            end
        end
        merged_info{c1}.synsets(end + 1) = c1;
        merged_info{c1}.synsets = unique(merged_info{c1}.synsets);
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
    
    for cid = 1:length(clusters)
        synsets = merged_info{cid}.synsets;
        max_id = -1;
        for sid = 1:length(synsets)
            current_cid = synsets(sid);
            if (max_id == -1 || cluster_score(max_id) < cluster_score(current_cid))
                max_id = current_cid;
            end
        end
        merged_cid = setdiff(synsets, max_id);
        is_merged(merged_cid) = 1;
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
