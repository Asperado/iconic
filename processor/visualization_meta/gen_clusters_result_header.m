function gen_clusters_result_header(clusters_index,...
                                     clusters,...
                                     result_output_root,...
                                     result_name,...
                                     varargin)
    opt=varargin2struct(varargin{:});
    nodes_comment = jsonopt('nodes_comment', {}, opt);
    
    all_node_info = {};
    p = ProgressBar;
    p.reset();
    p.set_total(length(clusters_index));
    assert(max(clusters_index) <= length(clusters));
    do_filter_image = 1;
    
    is_good_images = jsonopt('is_good_images', {}, opt);
    if (isempty(is_good_images))        
        do_filter_image = 0; 
    end
    
    is_good_cluster = ones(1, length(clusters));
    for cid = 1:length(clusters)
        image_index = clusters{cid}.index;
        if (do_filter_image && sum(is_good_images(image_index)) <= 460)
            is_good_cluster(cid) = 0;
        end
    end
        
    for iter = 1:length(clusters_index)
        cid = clusters_index(iter);
        if (~is_good_cluster(cid))           
            fprintf ('skip bad cluster %d\n', cid);
            continue;
        end
        node_info = {};
        node_info.comment = '';
        node_info.node_id = cid;
        node_info.cluster_id = cid;
        if (length(nodes_comment) == length(clusters_index))
            node_info.comment = nodes_comment{iter};
        end
        all_node_info{end + 1} = node_info;
        fprintf('Finish processing cluster %d, %f second left\n', cid, p.log(cid));
    end

    all_node_info_doc = savejson('', all_node_info, 'NoRowBracket', 0);
    all_node_output_path = sprintf('%s/%s/nodes.json', result_output_root, result_name);
    filewrite(all_node_info_doc, all_node_output_path);
end

