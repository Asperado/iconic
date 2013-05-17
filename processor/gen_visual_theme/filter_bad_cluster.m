function [clusters, result] = filter_bad_cluster(clusters, config)
    get_same_user_clusters(config);
    
    database = config.database;
    cluster_image_size = 50;
    visual_theme_threshold = 0.2;

    filter_info = cell(length(clusters), 1);
    for i = 1:length(filter_info)
        filter_info{i}.desc = {};
        filter_info{i}.synset = {};
        filter_info{i}.duplicate = [];
    end
    result.filtered_cluster = {};
    result.filtered_desc = {};

    tag_mat = database.get_tag_feature();
    old_clusters = clusters;
    
    is_good_file_path = sprintf('%s/extra_info/is_good_%s.mat', ...
				config.root_path, ...
				config.query);

    if (exist(is_good_file_path, 'file'))
        data = load(is_good_file_path);
        is_good_image = data.is_good;
    else
        is_good_image = [];
    end    
    
    [clusters, duplicate_clusters_id, near_images] = deduplicate_clusters(clusters, config);
    new_duplicate_clusters_id = [];
    for c = 1:length(duplicate_clusters_id)
        cid = duplicate_clusters_id(c);
        duplicate = near_images{cid}.index;
        if (~isempty(is_good_image))
            is_good_duplicate = is_good_image(duplicate);
            duplicate = duplicate(is_good_duplicate == 1);
        end
        if (length(duplicate) > 1)
            filter_info{cid}.desc{end + 1} = 'duplicate';
            filter_info{cid}.duplicate = duplicate;
            new_duplicate_clusters_id(end + 1) = cid;
        end
    end
    result.filtered_cluster{end + 1} = new_duplicate_clusters_id;
    result.filtered_desc{end + 1} = 'duplicate'; 
    
    
    % REFINE: remove same owner.
    same_owner = load(sprintf('%s/data/extra_info/%s_same_owner.mat', ...
			      config.root_path, ...
			      config.query));
    same_owner = same_owner.same_owner;
    filtered_cluster = find(same_owner);
    % DONE
    
    for i = 1:length(filtered_cluster)
        cid = filtered_cluster(i);
        filter_info{cid}.desc{end + 1} = 'same owner';
    end
    result.filtered_cluster{end + 1} = filtered_cluster;
    result.filtered_desc{end + 1} = 'same owner';
    
    % REFINE: remove bad clusters.
    bad_clusters = [];
    if (~isempty(is_good_image))
        for cid = 1:length(clusters)
            is_good_cnt = sum(is_good_image(clusters{cid}.index));
            if (is_good_cnt < length(clusters{cid}.index) * 0.95)
                bad_clusters(end + 1) = cid;
            end
        end
    else
        fprintf('skip is good.\n');
    end
    filtered_cluster = [filtered_cluster, bad_clusters];
    filtered_cluster = unique(filtered_cluster);
    % DONE
    
    for i = 1:length(bad_clusters)
        cid = bad_clusters(i);
        filter_info{cid}.desc{end + 1} = 'broken image';
    end
    result.filtered_cluster{end + 1} = bad_clusters;
    result.filtered_desc{end + 1} = 'broken image';
    
    % REFINE: remove no theme.
    no_theme_clusters = [];
    for cid = 1:length(clusters)
        images_ids = clusters{cid}.index;
        tag_count = sum(tag_mat(images_ids(1:min(length(images_ids), cluster_image_size)), 2:end), 1);
        if (isempty(find(tag_count > cluster_image_size * visual_theme_threshold, 1)))
            no_theme_clusters(end + 1) = cid;
        end        
    end
    filtered_cluster = [filtered_cluster, no_theme_clusters];
    filtered_cluster = unique(filtered_cluster); 
    % DONE
    
    for i = 1:length(no_theme_clusters)
        cid = no_theme_clusters(i);
        filter_info{cid}.desc{end + 1} = 'no theme';
    end
    result.filtered_cluster{end + 1} = no_theme_clusters;
    result.filtered_desc{end + 1} = 'no theme';
    
    % REFINE: remove overlap.
    is_merged = zeros(1, length(clusters));
    is_merged(filtered_cluster) = 1;
    cluster_score = zeros(1, length(clusters));
    [is_merged, new_clusters, mapped_index, merged_info] = merge_clusters_iterative(clusters, ...
                                                                                      cluster_score, ...
                                                                                      visual_theme_threshold * 2.5, ...
                                                                                      cluster_image_size, ...
                                                                                      is_merged);    
    overlap_clusters = setdiff(find(is_merged), filtered_cluster);
    filtered_cluster = [filtered_cluster, overlap_clusters];
    filtered_cluster = unique(filtered_cluster);
    % DONE
    
    for i = 1:length(overlap_clusters)
        cid = overlap_clusters(i);
        filter_info{cid}.desc{end + 1} = sprintf('merged');
        filter_info{cid}.synset{end + 1} = merged_info{cid}.synsets;
    end
    result.filtered_cluster{end + 1} = overlap_clusters;
    result.filtered_desc{end + 1} = 'merged';
    result.filtered_cluster_ = filtered_cluster;    
    result.filter_info = filter_info;
    
    [clusters, result] = filter_non_photo_cluster(clusters, config, result);
    
    % Reorder the good clusters using the original order of clusters.
    new_clusters = {};
    is_good_cluster = ones(1, length(clusters));
    is_good_cluster(result.filtered_cluster_) = 0;
    for i = 1:length(clusters)
        if (is_good_cluster(i))
            new_clusters{end + 1} = clusters{i};
        end
    end
    clusters = new_clusters;
end
