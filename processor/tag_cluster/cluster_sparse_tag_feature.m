function [IDX, dict] = cluster_sparse_tag_feature(T, K)
% cluster large dimension of matrix, using normalized svd
% in use version of tag clustering
% T: tag feature matrix
% K: number of clusters to generate.

    U =  normalize_and_svd_tag_feature(T, K);
    clear T;
    
    fprintf('begin kmeans\n');
    % kmeans clustering
    [index, dict] = run_kmeans_with_dict(U, K);
    
    IDX.data = index;
    IDX.clusters = K;
    fprintf('done clustering.\n');
end

