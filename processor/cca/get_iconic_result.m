function result = get_iconic_result(iconic_result_name, ...
                            iconic_result_output_root, ...
                            iconic_cluster_size, ...
                            cca_feature_dim, ...
                            cca_feature_path, ...
                            cca_path, ...
                            tag_path, ...
                            visual_feature_path, ...
                            cluster_feature_path)
    output_dir = iconic_result_output_root;
    output_file = sprintf('%s/%s.mat', output_dir, iconic_result_name);
                        
    if (exist(output_file, 'file'))     
        fprintf('Load iconic result.\n');
        data = load(output_file);
        result = data.result;
    else
        fprintf('Generate iconic result.\n');
        cca_result = get_cca_features(cca_feature_dim, ...
                                        visual_feature_path, ...
                                        tag_path, ...
                                        cluster_feature_path, ...
                                        cca_path, ...
                                        cca_feature_path);                        

        tag = load(tag_path);
        tag_mat = tag.featureData;

        for r = 1:length(cca_result)
            tic;
            rid = length(cca_result) - r + 1;

            % Load projected feature.
            cluster_feature = cca_result{rid}.cSXX;
            database_feature = cca_result{rid}.eSXX;
            n_clusters = size(cluster_feature, 1);

            % Clear CCA result projected feature.
            cca_result{rid}.cSXX = [];
            cca_result{rid}.eSXX = [];
            cca_result{rid}.tSXX = [];

            fprintf('Calculating distance.\n');
            cluster_feature = Normalize(cluster_feature);
            database_feature = Normalize(database_feature);

            fprintf('Construct image ids.\n');
            cluster_image_id = {}; 
            lines = 500;
            for line_id = 1:lines:n_clusters
                cbeg = line_id;
                cend = min(line_id + lines - 1, n_clusters);
                D = dist_mat(cluster_feature(cbeg:cend, :), database_feature);
                for cid = cbeg:cend
                    d = D(cid - cbeg + 1, :);
                    [drop, image_ids]=sort(d);
                    image_ids = image_ids(1:iconic_cluster_size);
                    cluster_image_id{end+1} = image_ids;
                end
            end
          
            cluster_rank = rank_cluster_by_tag_frequency(cluster_image_id, tag_mat);
            
            clusters = {};
            mapped_index = zeros(length(cluster_rank), 1);
            for c = 1:length(cluster_rank)
                cid = cluster_rank(c);
                mapped_index(cid) = c;
                image_ids = cluster_image_id{cid};
                cluster.index = image_ids;
                clusters{end + 1} = cluster;
            end

            cca_result{rid}.clusters = clusters;
            cca_result{rid}.mapped_index = mapped_index;
            fprintf('Done gen iconic result %s.', iconic_result_name);
            toc;
        end
        result = cca_result;
        clear cca_result;
        mkdir(output_dir);
        save(output_file, 'result', '-v7.3');  
    end
end

