function [clusters, result] = filter_non_photo_cluster(clusters, config, result)
    filter_info = result.filter_info;
    filtered_cluster = result.filtered_cluster_;

    tag_mat = config.database.get_tag_feature();
    taglist = config.database.get_taglist(config.taglist_path);
    config.cluster_image_size = 50;
    config.visual_theme_threshold = 0.2;
    
    % REFINE: remove non-photo relistic images
    filter_tag_ids = [];
    filter_keyword = {};
    filter_keyword{end + 1} = 'texture';
    filter_keyword{end + 1} = 'abstract';
    filter_keyword{end + 1} = 'sketch';
    filter_keyword{end + 1} = 'text';
    filter_keyword{end + 1} = 'cartoon';
    filter_keyword{end + 1} = 'cartoons';
    filter_keyword{end + 1} = 'collage';
    filter_keyword{end + 1} = 'explore';
    
    for keyword_id = 1:length(filter_keyword)
        keyword = filter_keyword{keyword_id};
        for tag_id = 1:length(taglist)
            if (strcmp(taglist{tag_id}, keyword))
                filter_tag_ids(end + 1) = tag_id;
            end
        end
    end
    
    non_photo_threshold = config.cluster_image_size * config.visual_theme_threshold / 2;
    non_photo_clusters = [];
    non_photo_clusters_desc = {};
    for cid = 1:length(clusters)
        images_ids = clusters{cid}.index;
        images_ids = images_ids(1:min(length(images_ids), config.cluster_image_size));
        tag_count = sum(tag_mat(images_ids, :), 1);
        for iter = 1:length(filter_tag_ids)
            filter_tag_id = filter_tag_ids(iter);
            if (tag_count(filter_tag_id) > non_photo_threshold)
                non_photo_clusters(end + 1) = cid;
                non_photo_clusters_desc{end + 1} = taglist{filter_tag_id};
                break;
            end
        end
    end
    filtered_cluster = [filtered_cluster, non_photo_clusters];
    filtered_cluster = unique(filtered_cluster);
    
    for i = 1:length(non_photo_clusters_desc)
        cid = non_photo_clusters(i);
        filter_info{cid}.desc{end + 1} = non_photo_clusters_desc{i};
    end
    result.filtered_cluster{end + 1} = non_photo_clusters;
    result.filtered_desc{end + 1} = 'non photo';

    % DONE
    result.filter_info = filter_info;
    result.filtered_cluster_ = filtered_cluster;
end