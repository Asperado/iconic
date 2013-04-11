function [IDX, dic] = run_kmeans_with_dict(X,k)

options = [];
options(1) = 1; % display
options(2) = 1;
options(3) = 0.1; % precision
options(5) = 1; % initialization
options(14) = 20; % maximum iterations

centers = zeros(k, size(X,2));
dic = sp_kmeans(centers, X, options);
dic = full(dic);

% use get min distance to compute the following faster and more memory efficient block by block.
%   D = dist_mat(X,dic);
%   [value, index] = min(D');
[value, index] = get_min_dist(X, dic);
IDX = index;


