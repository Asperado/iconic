classdef visual_theme_generator
    %COMPAREBYVISUALTHEME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        query = '';
    end
    
    methods
        function clusters = LoadCluster(obj, cca_path) 
            input = load(cca_path);
            clusters = input.result{1}.clusters;
            clear input;                           
        end

	function Run(obj, query, iconic_methods, webpage_name, db_root, tag_dim, gen_page_style, webpage_output_root) 
            obj.query = query;
            
            clusters_set = {};
            for method_id = 1:length(iconic_methods)
                clusters_set{end + 1} = obj.LoadCluster(iconic_methods{method_id}.cca_path);
            end
            
            for method_id = 1:length(clusters_set)
                fprintf('%s %d\n', iconic_methods{method_id}.name, length(clusters_set{method_id}));
            end
            database = IconicDatabase(obj.query, db_root, tag_dim);
            do_gen_webpage = 1;
            
            tag_method_count = zeros(database.tag_dim_, length(clusters_set));
            
            for method_id = 1:length(clusters_set)
                clusters = clusters_set{method_id};
                for cid = 1:length(clusters)
                    fprintf('gen cluster %d of %d\n', cid, method_id);
                    image_ids = clusters{cid}.index;
                    %image_ids = image_ids(1:min(60, size(image_ids, 2)));
                    tags = database.GetImageTags(image_ids);
                    tags_cnt = sum(tags, 1);
                    tag_min_threshold = size(image_ids, 2) * 0.08;
                    good_tag_id = find(tags_cnt > tag_min_threshold);
                    for t = 1:size(good_tag_id, 2)
                        tid = good_tag_id(t);
                        if (do_gen_webpage == 1)
                            if (strcmp(gen_page_style, 'combine'))
                                good_cluster_cnt = sum(tag_method_count(tid, :)) + 1;
                                method_good_cluster_cnt = tag_method_count(tid, method_id) + 1; 
                                gen_image_list_v1(image_ids, ...
                                    obj.query, ...
                                    webpage_name, ...
                                    sprintf('%s', database.taglist_{tid}), ...
                                    good_cluster_cnt, ...
				    sprintf('%s_%s_%d', database.taglist_{tid}, iconic_methods{method_id}.name, method_good_cluster_cnt), ...
				    database,...
				    webpage_output_root);

                            else 
                                method_good_cluster_cnt = tag_method_count(tid, method_id) + 1; 
                                gen_image_list_v1(image_ids, ...
                                    obj.query, ...
                                    webpage_name, ...
                                    sprintf('%s_%s', database.taglist_{tid}, iconic_methods{method_id}.name), ...
                                    method_good_cluster_cnt, ...
                                    sprintf('%s_%d', database.taglist_{tid}, method_good_cluster_cnt), ...
				    database,...
				    webpage_output_root);
                            end
                        end
                        tag_method_count(tid, method_id) = tag_method_count(tid, method_id) + 1;
                    end
                end
            end
            
            tag_tot_count = sum(tag_method_count, 2);
            for tid = 1:size(tag_method_count, 1)
                if (tag_tot_count(tid) == 0 )
                    continue;
                end
                count_output = database.taglist_{tid};
                for method_id = 1:size(tag_method_count, 2)
                    count_output = sprintf('%s , %d', count_output, tag_method_count(tid, method_id));     
                end
                fprintf('%s\n', count_output); 
            end
        end
    end
end

