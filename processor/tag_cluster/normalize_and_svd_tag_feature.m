function U = normalize_and_svd_tag_feature(T, K)
% T: tag feature matrix.
% K: output the top K normalizd left singular vectors.
% U: the top K normalized left singular vectors.

    % normalization.
    d = T' * ones(size(T,1),1);
    d = T * d;
    d(d==0)=1;
    d = d.^(-1/2);
    
    % block wise normalizing T.
    %    for i=1:size(T,1)
    %        if(d(i)<20000000)
    %            T(i,:) = T(i,:)*d(i);
    %        end
    %    end
    block_size = 100000;
    blocks = ceil(size(T, 1) / block_size);
    for b = 1:blocks
        tic;
        block_beg = (b - 1) * block_size + 1;
        block_end = min(size(T, 1), block_beg + block_size - 1);
        T( block_beg:block_end, : ) = T( block_beg:block_end, : ) .* repmat(d(block_beg:block_end), 1, size(T,2));
        toc;
    end
    
    fprintf('start calcuating U.\n');

    % computing left singular vectors U, via right singular vectors V.
    % U = T*V*diag(diag(l.^(-1/2)));

    % calculating covariance matrix
    tic;
    C = fast_cov(T);
    fprintf('done calculating cov.\n');
    toc;

    % calculating right singular vectors V.
    tic;
    [V,l] = eigs(double(C),K + 2);
    fprintf('done calculating eigs.\n');
    toc;

    tic;
    l = diag(l);
    l = diag(l.^(-1/2));
    lines = size(T, 1);
    
    U = zeros(size(T, 1), K + 2, 'single');
    for i = 1:block_size:lines
        tic;
        U(i:min(i + block_size - 1, lines), :) = T(i:min(i+block_size - 1, lines), :) * V;
        toc;
    end
   
    clear T;
    for i = 1:block_size:lines
        tic;
        U(i:min(i + block_size - 1, lines), :) = U(i:min(i+block_size - 1, lines), :) * l;
        toc;
    end
    
    toc;
    fprintf('done computing svd tag feature.\n');
    clear V d l C;
    
    U = U(:,1:K);
    
    % L2 renormalizing the rows of U
    for i=1:size(U,1)
        v = sqrt(sum(U(i,:).^2));
        if (v ~= 0) 
            tic;
            U(i,:) = U(i,:)/v;
            toc;
        end
    end
    fprintf('done normalizing tag feature.\n');
end
