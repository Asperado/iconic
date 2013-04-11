function b = Normalize(a)
    N = sqrt(sum(abs(a).^2,2));
    b = a./repmat(N,1,size(a,2));
end