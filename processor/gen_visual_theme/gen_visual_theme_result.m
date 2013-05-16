function result = gen_visual_theme_result(clusters, ...
                                          database, ...
                                          top_k_images, ...
                                          tag_min_threshold_ratio)
    if (~exist('tag_min_threshold_ratio', 'var'))
        tag_min_threshold_ratio = 0.08;
    end
    result = {};
    taglist = database.get_taglist();
    theme_entry = cell(length(taglist), 1);
    for t = 1:length(taglist)
        entry = {};
        entry.tag = taglist{t};
        entry.cluster_ids = [];
        theme_entry{t} = entry;
    end
    
    for cid = 1:length(clusters)
        fprintf('processing %d\n', cid);
        image_ids = clusters{cid}.index;
        if (exist('top_k_images', 'var'))
            image_ids = image_ids(1:min(top_k_images, size(image_ids, 2)));
        end
        tags = database.get_image_tags(image_ids);
        tags_cnt = sum(tags, 1);
        tag_min_threshold = size(image_ids, 2) * tag_min_threshold_ratio;
        good_tag_id = find(tags_cnt > tag_min_threshold);
        for t = 1:size(good_tag_id, 2)
            tid = good_tag_id(t);
            entry = theme_entry{tid};
            entry.cluster_ids = [entry.cluster_ids;cid];
            theme_entry{tid} = entry;
        end
    end
    result.theme_entry = theme_entry;
end
