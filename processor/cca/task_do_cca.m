function task_do_cca(dim, feature_mat, tag_mat, cluster_mat, output_file)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CCA(V+T+C)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (~exist(output_file, 'file'))
        fprintf('generating cca...');
        tic;
        IDXs = cluster_mat;
        clear cluster_mat;
        result = {};
        X = feature_mat;
        clear feature_mat;
        size(X)

        T = tag_mat;
        clear tag_mat;
        size(T)
        
        for cid = 1:length(IDXs)
            c = IDXs{cid};
            nclusters = c.clusters;
            c = c.data(:);
            disp('done load label, index, tags etc...')
            size(c)    

            K = eye(max(c));
            t = 4;
            d = size(X,2);
                        
            [Wx, D] = CCA3(X, T, c);  % X is visual feature, T is tag, c is tag clusters

            record.eSXX = X * Wx(1:d, 1:dim) * (D(1:dim,1:dim).^t); % this is the visual embedding
            record.tSXX = T * Wx(d+1:d+size(T,2), 1:dim) * (D(1:dim,1:dim).^t); % this is the tag embedding
            record.cSXX = K * Wx(d+size(T,2)+1:end, 1:dim) * (D(1:dim,1:dim).^t); % this is the cluster embedding
            record.clusters = nclusters;
            result{end+1} = record;
        end
    
        [output_dir, drop] = fileparts(output_file);
        if (~exist(output_dir, 'dir'))
            mkdir(output_dir);
        end

        save(output_file, 'result', '-v7.3');
        fprintf('done generating %s\n', output_file);
        toc;
    end
end