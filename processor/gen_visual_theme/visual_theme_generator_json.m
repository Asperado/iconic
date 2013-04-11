classdef visual_theme_generator_json

    properties
    end
    
    methods
        function clusters = LoadCluster(obj, iconic_path) 
            input = load(iconic_path);
            clusters = input.result{1}.clusters;
            clear input;                           
        end
        
        function Run(obj, iconic_methods, web_page_output_root, result_name, all_database)
            cluster_images_size = 50;
            tag_min_threshold_ratio = 0.2;

            clusters_set = {};
            for method_id = 1:length(iconic_methods)
                clusters_set{end + 1} = obj.LoadCluster(iconic_methods{method_id}.iconic_path);
            end
            
            for method_id = 1:length(clusters_set)
                fprintf('%s %d\n', iconic_methods{method_id}.name, length(clusters_set{method_id}));
            end

            all_theme_entry = {};
            for method_id = 1:length(clusters_set)
                clusters = clusters_set{method_id};
                
                theme_entry = gen_visual_theme_result(clusters, ...
                                                     all_database{method_id}, ...
                                                     cluster_images_size, ...
                                                     tag_min_threshold_ratio);
                theme_entry = theme_entry.theme_entry;
                all_theme_entry{end + 1} = theme_entry;
            end
            
            nodes = {};      
            tag_id = [];
            tag_map = {};
            for method_id = 1:length(all_theme_entry)
                theme_entry = all_theme_entry{method_id};
                for eid = 1:length(theme_entry)
                    entry = theme_entry{eid};
                    if (isempty(entry.cluster_ids))
                        continue;
                    end
                    current_tag = entry.tag;
                    current_tag_id = length(tag_map) + 1;
                    for tag_map_iter = 1:length(tag_map)
                        if (strcmp(tag_map{tag_map_iter}, current_tag))
                            current_tag_id = tag_map_iter;
                            break;
                        end
                    end
                    assert(length(nodes) == length(tag_map));
                    if (current_tag_id > length(nodes))
                        node = {};
                        node.desc = entry.tag;
                        node.related_nodes = [];
                        node.related_node_desc = {};
                        node.related_node_result_feed = {};
                        nodes{end + 1} = node;
                        tag_map{end + 1} = current_tag;
                    end
                    node = nodes{current_tag_id};
                    nodes{current_tag_id}.related_nodes = [node.related_nodes, entry.cluster_ids(:)'];
                    for related_nodes_index = 1:length(entry.cluster_ids)
                        nodes{current_tag_id}.related_node_desc{end + 1} = sprintf('%s_%d', current_tag, method_id);
                        nodes{current_tag_id}.related_node_result_feed{end + 1} = iconic_methods{method_id}.result_feed;
                    end
                    assert(length(nodes{current_tag_id}.related_nodes) == length(nodes{current_tag_id}.related_node_desc));
                end
            end
            
            nodes_output_path = sprintf('%s/%s/nodes_tag_cluster.json', web_page_output_root, result_name);
            nodes_doc = savejson('', nodes, 'NoRowBracket', 0);
            filewrite(nodes_doc, nodes_output_path);

% This part generate the csv format statistics of the visual themes.
%             for t = 1:size(good_tag_id, 2)
%                 tid = good_tag_id(t);
%                 tag_method_count(tid, method_id) = tag_method_count(tid, method_id) + 1;
%             end           
%             tag_tot_count = sum(tag_method_count, 2);
%             for tid = 1:size(tag_method_count, 1)
%                 if (tag_tot_count(tid) == 0 )
%                     continue;
%                 end
%                 count_output = database.taglist_{tid};
%                 for method_id = 1:size(tag_method_count, 2)
%                     count_output = sprintf('%s , %d', count_output, tag_method_count(tid, method_id));     
%                 end
%                 fprintf('%s\n', count_output); 
%             end
        end
    end
    
end