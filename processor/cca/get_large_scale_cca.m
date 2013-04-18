function get_large_scale_cca(cca_feature_dim, ...
                                visual_feature_path, ...
                                tag_path, ...
                                cluster_path, ...
                                output_file, ...
                                over_write)
% cca_feature_dim: the dimension of final generated cca result.
% visual_feature_path: visual feature.
% tag_path: tag feature.
% cluster_path: tag cluster path.
% output_file: file to save the following cca result:
%              Wx is the projection matrix, i.e. eigenvectors.
%              D is the eigenvalues in diagonal matrix.
%              cluster_mat is cluster matrix.
%              feature_mat is visual feature matrix.
%              tag_mat is tag feature matrix.
%              feature_dim is column-wise dimension of visual feature matrix.
%              tag_mat is column-wise dimension of tag feature matrix.
% over_write: if set to 0, will skip if the output_file already exist.

    if (~exist(output_file, 'file') || over_write == 1)
        fprintf('Generate cca feature of dimension %d\n', cca_feature_dim);
        feature_mat = load(visual_feature_path);
        fprintf('Load visual feature.\n');
        feature_mat = feature_mat.visFeatures;

        fprintf('Load tag feature.\n');
        tag_mat = load(tag_path);
        tag_mat = tag_mat.featureData;

        cluster_mat = load(cluster_path);
        fprintf('Load tag cluster result.\n');
        tmp = cluster_mat.cluster.index.data;
        cluster_mat = tmp;

        fprintf('Begin generating cca result.\n');
        % feature_mat is visual feature, tag_mat is tag, cluster_mat is tag
        % clusters.
        [output_dir, drop] = fileparts(output_file);
        if (~exist(output_dir, 'dir'))
            mkdir(output_dir);
        end
        
        tag_dim = size(tag_mat, 2);
        feature_dim = size(feature_mat, 2);
        [Wx, D] = cca3_large_scale(feature_mat, tag_mat, cluster_mat);
        save(output_file, 'Wx', 'D', 'tag_mat', 'cluster_mat', 'feature_mat', 'tag_dim', 'feature_dim', 'cca_feature_dim', '-v7.3');
    else
        fprintf('Great. CCA result already exists.\n')
    end
end
