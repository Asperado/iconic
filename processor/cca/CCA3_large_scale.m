function [Wx, D] = cca3_large_scale(X, T, y)
% X is visual feature data
% T is tag SVD results
% y is the clustering indexes

y = y(:);
Y = zeros(length(y),max(y), 'single');
for i=1:length(y)
    Y(i,y(i))=1;
end

A = gen_cov_matrix(X, T, Y); 

index = [ones(size(X,2),1);ones(size(T,2),1)*2;ones(size(Y,2),1)*3];
[Wx, D] = multiview_cov_cca(A, index, 0.0001);


