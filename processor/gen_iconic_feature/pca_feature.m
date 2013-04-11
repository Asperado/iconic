function [X, u] = pcaFeature(X, dim)
    X = sqrt(X);
    C = cov(X);
    C = double(C);
    [u,v] = eigs(C,dim);
    X = X * u;
end
