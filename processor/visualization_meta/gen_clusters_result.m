function gen_clusters_result(clusters_index,...
                             clusters,...
                             database,...
                             result_output_root,...
                             result_name,...
                             meta_root,...
                             varargin)
%    is_good_images, ...
%    show_top_k_images)
    assert(exist(meta_root, 'file') ~= 0);

    opt=varargin2struct(varargin{:});
    is_good_images = jsonopt('is_good_images', {}, opt);
    show_top_k_images = jsonopt('show_top_k_images', 100, opt);

    all_node_info = {};
    p = ProgressBar;
    p.reset();
    p.set_total(length(clusters_index));
    assert(max(clusters_index) <= length(clusters));
    do_filter_image = 1;
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
        all_node_info{end + 1} = node_info;
        fprintf('Finish processing cluster %d, %f second left\n', cid, p.log(cid));
    end

    all_node_info_doc = savejson('', all_node_info, 'NoRowBracket', 0);
    all_node_output_path = sprintf('%s/%s/nodes.json', result_output_root, result_name);
    filewrite(all_node_info_doc, all_node_output_path);
    
    p.reset();
    p.set_total(length(all_node_info));
    for nid = 1:length(all_node_info)
        node_info = all_node_info{nid};
        image_index = clusters{node_info.cluster_id}.index;
        
        if (do_filter_image)
            node_images_info = gen_images_meta(image_index, ...
                                               meta_root, ...
                                               'database', database,...
                                               'top_k_images', show_top_k_images, ...
                                               'is_good_image_list', is_good_images);
        else
            node_images_info = gen_images_meta(image_index, ...
                                               meta_root, ...
                                               'database', database,...
                                               'top_k_images', show_top_k_images);
        end

        node_output_path = sprintf('%s/%s/node_%d.json', result_output_root, result_name, node_info.node_id);
        node_output_doc = savejson('', node_images_info, 'NoRowBracket', 0);
        node_output_path
        filewrite(node_output_doc, node_output_path);    
        fprintf('Finish processing cluster %d, %f second left\n', nid, p.log(nid));
    end
end
