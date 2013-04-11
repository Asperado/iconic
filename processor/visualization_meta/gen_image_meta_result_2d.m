function gen_image_meta_result_2d(all_images_meta, ...
                                    result_output_root,...
                                    result_name)
    fprintf('Genearte nodes header.\n');
    all_node_info = cell(length(all_images_meta), 1);
    for iter = 1:length(all_images_meta)
        nid = iter;
        node_info = {};
        node_info.comment = '';
        node_info.node_id = nid;
        node_info.cluster_id = -1;
        all_node_info{iter} = node_info;
    end

    fprintf('Generate nodes header json.\n');
    all_node_info_doc = savejson('', all_node_info, 'NoRowBracket', 0);
    all_node_output_path = sprintf('%s/%s/nodes.json', result_output_root, result_name);
    fprintf('Save nodes header.\n');
    filewrite(all_node_info_doc, all_node_output_path);
    
    fprintf('Generate detail of nodes.\n');
    p = ProgressBar();
    p.reset();
    p.set_total(length(all_node_info));
    for nid = 1:length(all_node_info)
        node_info = all_node_info{nid};
        node_images_info = all_images_meta{nid};
        node_output_path = sprintf('%s/%s/node_%d.json', result_output_root, result_name, node_info.node_id);
        node_output_doc = savejson('', node_images_info, 'NoRowBracket', 0);
        node_output_path
        filewrite(node_output_doc, node_output_path);    
        fprintf('Finish processing cluster %d, %f second left\n', nid, p.log(nid));
    end
end

