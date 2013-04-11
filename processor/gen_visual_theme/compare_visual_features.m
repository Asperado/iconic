classdef compare_visual_features
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
            elseif (strcmp(method_name, 'kmeans'))
                input = load(sprintf('D:\\Iconic\\data\\visual_clusters\\%s\\vis_clusters.mat', obj.query));
                cluster_labels = input.results{10}.cluster_labels;
                cluster_ids = unique(cluster_labels);
                clusters = {};
                for i = 1:length(cluster_ids)
                    cluster.index = find(cluster_labels == i);
                    clusters{end + 1} = cluster;
                end
                clear input;
            elseif (strcmp(method_name, 'rahul'))
                input = load(sprintf('D:\\Iconic\\data\\cocluster_result\\%s\\results.mat', obj.query));
                clusters = {};
                for i = 1:length(input.results)
                    cluster.index = input.results{i}.image_id;
                    clusters{end + 1} = cluster;
                end
                clear input;
            end
        end
        function Run(obj) 
            method_name = {};
            method_name {end + 1} = 'DenseRGBSIFT';
            method_name {end + 1} = 'HOG';
            method_name {end + 1} = 'HarrisRGBSIFT';
            method_name {end + 1} = 'all_features';
            method_name {end + 1} = 'GIST';
            clusters_set = {};
            for method_id = 1:length(method_name)
                clusters_set{end + 1} = obj.LoadCluster(method_name{method_id});
            end
            
            for method_id = 1:length(clusters_set)
                fprintf('%s %d\n', method_name{method_id}, length(clusters_set{method_id}));
            end
            database = IconicDatabase(obj.query);
            high_freq_tag_ids_all = [];
            for method_id = 1:length(clusters_set)
                clusters = clusters_set{method_id};                
                for cid = 1:length(clusters)
                    image_ids = clusters{cid}.index;
                    %image_ids = image_ids(1:min(60, size(image_ids, 2)));
                    tags = database.GetImageTags(image_ids);
                    tags_cnt = sum(tags, 1);
                    high_freq_tag_ids = find(tags_cnt > size(images_ids, 2) * 0.1);
                    high_freq_tag_ids_all = [high_freq_tag_ids_all, high_freq_tag_ids];                        
                end
            end
            high_freq_tag_ids_all = unique(high_freq_tag_ids_all); 
            database.taglist_(high_freq_tag_ids_all)
%            high_freq_tag_ids_all = high_freq_tag_ids_all(1:47);
%            database.taglist_(high_freq_tag_ids_all)
            do_gen_webpage = 1;
            count_results = {};
            for t = 2:size(high_freq_tag_ids_all, 2)
                good_cluster_cnt = 1;
                tag_id = high_freq_tag_ids_all(t);
                for method_id = 1:length(clusters_set)
                    method_good_cluster_cnt = 1;
                    clusters = clusters_set{method_id};
                    for cid = 1:length(clusters)
                        fprintf('gen cluster %d of %d\n', cid, method_id);
                        image_ids = clusters{cid}.index;
                        %image_ids = image_ids(1:min(60, size(image_ids, 2)));
                        tags = database.GetImageTags(image_ids);
                        tags_cnt = sum(tags(:, tag_id), 1);
                        if (tags_cnt >= size(image_ids, 2) * 0.1)
                            if (do_gen_webpage == 1)
                                gen_image_list_no_thumb(image_ids, obj.query, sprintf('visual_theme_%s_features', obj.query), sprintf('%s', database.taglist_{tag_id}), good_cluster_cnt, sprintf('%s_%s_%d', database.taglist_{tag_id}, method_name{method_id}, method_good_cluster_cnt));
                            end
                            method_good_cluster_cnt = method_good_cluster_cnt + 1;
                            good_cluster_cnt = good_cluster_cnt + 1;
                        end
                    end
                    clear count_result;
                    count_result.method = method_name{method_id};
                    count_result.tag = database.taglist_{tag_id};
                    count_result.count = method_good_cluster_cnt;
                    count_results{end + 1} = count_result;
                end
            end
            for i = 1:length(clusters_set):length(count_results)
                count_output = count_results{i}.tag;
                for j = 1:length(clusters_set)
                    count_output = sprintf('%s & %d', count_output, count_results{i + j - 1}.count);
                end
                fprintf('%s\n', count_output);
            end
        end
    end
    
end

