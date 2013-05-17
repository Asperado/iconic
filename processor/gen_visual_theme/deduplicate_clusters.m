function [clusters, clusters_id, near_images] = deduplicate_clusters(clusters, config)
    cluster_image_size = 500;
    clusters_id = [];
    vis_mat = config.database.get_visual_feature(config.feature_path);
    near_images = cell(length(clusters), 1);
    for cluster_id = 1:length(clusters)
        image_ids = clusters{cluster_id}.index;
        image_ids = image_ids(1:min(length(image_ids), cluster_image_size));

        f = vis_mat(image_ids, :);
        D = dist_mat(f, f);
        D(eye(size(D)) == 1) = 100;
        [i, j] = find(D < 0.1);
        near_image_ids = image_ids(intersect(i, j));
        if (length(near_image_ids) > 0)
            clusters_id(end + 1) = cluster_id;
            length(clusters{cluster_id}.index)
            new_image_ids = [];
            for i = 1:length(image_ids)
                if (isempty(find(near_image_ids == image_ids(i))))
                    new_image_ids(end + 1) = image_ids(i);
                end
            end
            clusters{cluster_id}.index = new_image_ids;
            near_images{cluster_id}.index = near_image_ids;
            length(clusters{cluster_id}.index)
        end
    end
end