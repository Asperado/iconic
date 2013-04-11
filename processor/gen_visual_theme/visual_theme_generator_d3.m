%   
%   Node
%       desc: 
%       related_nodes: 
%   
function visual_theme_generator_d3(web_page_output_root, ...
                                result_name, ...
                                clusters, ...
                                database)
    cluster_images_size = 60;
    tag_min_threshold_ratio = 0.2;
    
    theme_entry = gen_visual_theme_result(clusters, ...
                                     database, ...
                                     cluster_images_size, ...
                                     tag_min_threshold_ratio);
    theme_entry = theme_entry.theme_entry;
    
    nodes = {};
    for eid = 1:length(theme_entry)
        entry = theme_entry{eid};
        if (~isempty(entry.cluster_ids))
            node = {};
            node.desc = entry.tag;
            node.related_nodes = entry.cluster_ids(:)';
            nodes{end + 1} = node;
        end
    end

    nodes_output_path = sprintf('%s/%s/nodes_tag_cluster.json', web_page_output_root, result_name);
    nodes_doc = savejson('', nodes, 'NoRowBracket', 0);
    filewrite(nodes_doc, nodes_output_path);
end

