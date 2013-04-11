function cca_feature = get_cca_features(dim, feature_path, tag_path, cluster_path, cca_path, cca_feature_path) 
    if (exist('cca_feature_path', 'var') && exist(cca_feature_path, 'file'))
        fprintf('Load cca feature from file %s.\n', cca_feature_path);
        data = load(cca_feature_path);
        cca_feature = data.cca_feature;
        assert(dim == size(cca_feature{1}.eSXX, 2))
        assert(dim == size(cca_feature{1}.tSXX, 2))
        assert(dim == size(cca_feature{1}.cSXX, 2))
        return;
    end
    
    fprintf('Load cca projection matrix from file %s.\n', cca_path);
    load(cca_path, 'Wx', 'D', 'feature_dim', 'tag_dim');
    size(Wx)
    size(D)
    
    t = 4;    
   
    % Gen cluster feature    
    fprintf('load tag cluster result.\n');
    cluster_mat = load(cluster_path);
    tmp = cluster_mat.cluster.index.data;
    cluster_mat = tmp;      
    
    tic;
        fprintf('gen cluster feature.\n');
        K = eye(max(cluster_mat));
        P = Wx(feature_dim+tag_dim+1:end, 1:dim) * (D(1:dim,1:dim).^t);

        record.cSXX = large_scale_multiply(K, P)  % this is the cluster embedding
        record.clusters = max(cluster_mat);
    toc;
    
    
    % Gen tag feature    
  	fprintf('load tag feature.\n');
    tag_mat = load(tag_path);
    tag_mat = tag_mat.featureData;
    
    tic;
        fprintf('gen tag feature.\n');
        P = Wx(feature_dim+1:feature_dim+tag_dim, 1:dim) * (D(1:dim,1:dim).^t);
        record.tSXX = large_scale_multiply(tag_mat, P)  % this is the tag embedding
        tag_mat = [];
        clear tag_mat;
        clear P;
    toc;
    
    % Gen visual feature    

    fprintf('load visual feature.\n');
    feature_mat = load(feature_path);
    feature_mat = feature_mat.visFeatures;
    
    tic;
        fprintf('gen visual feature.\n');
        P = Wx(1:feature_dim, 1:dim) * (D(1:dim,1:dim).^t);
        record.eSXX = large_scale_multiply(feature_mat, P)  % this is the visual embedding
        feature_mat = [];
        clear feature_mat;
        clear P;
    toc;
    
    cca_feature = {};
    cca_feature{end+1} = record;
    assert(dim == size(cca_feature{1}.eSXX, 2))
    assert(dim == size(cca_feature{1}.tSXX, 2))
    assert(dim == size(cca_feature{1}.cSXX, 2))
    fprintf('done generating cca featuers.\n');
    
    if (exist('cca_feature_path', 'var'))
        [output_dir, drop] = fileparts(cca_feature_path);
        mkDir(output_dir);
        save(cca_feature_path, 'cca_feature', '-v7.3');
    end
end