classdef compare_visual_features_dim_dog
    %COMPAREBYVISUALTHEME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        query = 'dog';
    end
    
    methods
        function clusters = LoadCluster(obj, method_name) 
            if (strcmp(method_name, '256')) 
                input = load(sprintf('C:/Iconic/data/iconic_result/%s/result_256_iconic_dog_all_large_scale_all_data_2.mat', obj.query));
                clusters = input.result{1}.clusters;
                clear input;
            elseif (strcmp(method_name, '500')) 
                input = load(sprintf('C:/Iconic/data/iconic_result/%s/result_500_iconic_dog_all_large_scale_all_data_2.mat', obj.query));
                clusters = input.result{1}.clusters;
                clear input;
            elseif (strcmp(method_name, '1000')) 
                input = load(sprintf('C:/Iconic/data/iconic_result/%s/result_1000_iconic_dog_all_large_scale_all_data_2.mat', obj.query));
                clusters = input.result{1}.clusters;
                clear input;
            elseif (strcmp(method_name, '2000_2000_tag_cluster')) 
                input = load(sprintf('C:/Iconic/data/iconic_result/%s/result_2000_iconic_dog_all_large_scale_all_data_5.mat', obj.query));
                clusters = input.result{1}.clusters;
                clear input;
            elseif (strcmp(method_name, 'merged_1500_tag_cluster')) 
                input = load(sprintf('C:/Iconic/data/iconic_result/%s/result_2000_iconic_dog_all_large_scale_all_data_6.mat', obj.query));
                clusters = input.result{1}.clusters;
                clear input;                
            end
        end
        function Run(obj) 
            method_name = {};
            %method_name {end + 1} = '256';
            %method_name {end + 1} = '500';
            %method_name {end + 1} = '1000';
            method_name {end + 1} = '2000_2000_tag_cluster';
            method_name {end + 1} = 'merged_1500_tag_cluster';
            
            clusters_set = {};
            for method_id = 1:length(method_name)
                clusters_set{end + 1} = obj.LoadCluster(method_name{method_id});
            end
            
            for method_id = 1:length(clusters_set)
                fprintf('%s %d\n', method_name{method_id}, length(clusters_set{method_id}));
            end
            database = IconicDatabase(obj.query, 'G:', 6000);
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
                            good_cluster_cnt = sum(tag_method_count(tid, :)) + 1;
                            method_good_cluster_cnt = tag_method_count(tid, method_id) + 1; 
                            gen_image_list_v1(image_ids, ...
                                obj.query, ...
                                sprintf('visual_theme_%s_features_dim_compare_large_scale_2', obj.query), ...
                                sprintf('%s_%s', database.taglist_{tid}, method_name{method_id}), ...
                                method_good_cluster_cnt, ...
                                sprintf('%s_%s_%d', database.taglist_{tid}, method_name{method_id}, method_good_cluster_cnt), ...
                                database);
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

