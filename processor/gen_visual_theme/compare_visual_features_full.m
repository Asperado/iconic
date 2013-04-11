classdef compare_visual_features_full
    %COMPAREBYVISUALTHEME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        query = 'love';
    end
    
    methods
        function clusters = LoadCluster(obj, method_name) 
            if (strcmp(method_name, 'GIST')) 
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_GIST.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;
            elseif (strcmp(method_name, 'DenseRGBSIFT')) 
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_DenseRGBSIFT_pca500.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;
            elseif (strcmp(method_name, 'HarrisRGBSIFT')) 
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_HarrisRGBSIFT_pca500.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;
            elseif (strcmp(method_name, 'all_features')) 
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_all_features.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;                
            elseif (strcmp(method_name, 'HOG')) 
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_HOG_pca500.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;                
            elseif (strcmp(method_name, 'DenseRGBSIFT_HOG'))
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_DenseRGBSIFT_and_Hogs.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;                
            elseif (strcmp(method_name, 'all_but_DenseRGBSIFT'))
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_all_but_DenseRGBSIFT.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;  
            elseif (strcmp(method_name, 'all_but_HarrisRGBSIFT'))
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_all_but_HarrisRGBSIFT.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;  
            elseif (strcmp(method_name, 'all_but_GIST_HarrisRGBSIFT'))
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_all_but_GIST_HarrisRGBSIFT.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;                  
            elseif (strcmp(method_name, 'all_but_GIST_DenseRGBSIFT'))
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_all_but_GIST_DenseRGBSIFT.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;                  
            elseif (strcmp(method_name, 'all_but_GIST'))
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_all_but_GIST.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;                  
            elseif (strcmp(method_name, 'RGB'))
                input = load(sprintf('D:\\Iconic\\data\\iconic_result\\%s\\result_256_iconic_love_all_RGB_pca500.mat', obj.query));
                clusters = input.result{2}.clusters;
                clear input;  
            end
        end
        function Run(obj) 
            method_name = {};
            method_name {end + 1} = 'all_features';
            method_name {end + 1} = 'all_but_HarrisRGBSIFT';
            method_name {end + 1} = 'all_but_DenseRGBSIFT';
            method_name {end + 1} = 'all_but_GIST';
            method_name {end + 1} = 'all_but_GIST_DenseRGBSIFT';
            method_name {end + 1} = 'all_but_GIST_HarrisRGBSIFT';
            method_name {end + 1} = 'DenseRGBSIFT_HOG';
            method_name {end + 1} = 'HarrisRGBSIFT';
            method_name {end + 1} = 'DenseRGBSIFT';
            method_name {end + 1} = 'HOG';
            method_name {end + 1} = 'GIST';
            method_name {end + 1} = 'RGB';
            
            
            clusters_set = {};
            for method_id = 1:length(method_name)
                clusters_set{end + 1} = obj.LoadCluster(method_name{method_id});
            end
            
            for method_id = 1:length(clusters_set)
                fprintf('%s %d\n', method_name{method_id}, length(clusters_set{method_id}));
            end
            database = IconicDatabase(obj.query);
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
                                sprintf('visual_theme_%s_features_full_large_scale', obj.query), ...
                                sprintf('%s', database.taglist_{tid}), ...
                                good_cluster_cnt, ...
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

