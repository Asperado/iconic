function gen_clusters_result_group_header(clusters_index_list,...
                                       clusters,...
                                       result_output_root,...
                                       result_name,...
                                       varargin)
    opt=varargin2struct(varargin{:});
    group_comment = jsonopt('group_comment', {}, opt);
    
    all_group_info = {};

    for iter = 1:length(clusters_index_list)
     assert(max(clusters_index_list{iter}) <= length(clusters));
    end
    do_filter_image = 1;
    
    is_good_images = jsonopt('is_good_images', {}, opt);
    if (isempty(is_good_images))        
        do_filter_image = 0; 
    end
    
    related_node_desc = jsonopt('related_node_desc', {}, opt);
    
    is_good_cluster = ones(1, length(clusters));
    for cid = 1:length(clusters)
        image_index = clusters{cid}.index;
        if (do_filter_image && sum(is_good_images(image_index)) <= 460)
            is_good_cluster(cid) = 0;
        end
    end
        
    for index_list_iter = 1:length(clusters_index_list)
        clusters_index = clusters_index_list{index_list_iter};
        group_info = {};
        group_info.desc = '';
        group_info.group_id = index_list_iter;
        group_info.related_nodes = [];
        for iter = 1:length(clusters_index)
            cid = clusters_index(iter);
            if (~is_good_cluster(cid))           
                fprintf ('skip bad cluster %d\n', cid);
                continue;
            end
            group_info.related_nodes = [group_info.related_nodes, cid];
        end
        if (length(related_node_desc) == length(clusters_index_list))
            group_info.related_node_desc = related_node_desc{index_list_iter};
        end
        if (length(group_comment) == length(clusters_index_list))
            group_info.desc = group_comment{index_list_iter};
        end
        all_group_info{end + 1} = group_info;
    end

    all_node_info_doc = savejson('', all_group_info, 'NoRowBracket', 0);
    all_node_output_path = sprintf('%s/%s/nodes_tag_cluster.json', result_output_root, result_name);
    filewrite(all_node_info_doc, all_node_output_path);
end

