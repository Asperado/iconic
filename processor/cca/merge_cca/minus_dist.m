function D = minus_dist(P1, P2)
    P1 = single(P1);
    P2 = single(P2);
    
    D = zeros(size(P1, 1), size(P2, 1));
    for i = 1:size(P1, 1)
        value = sum(repmat(P1(i, :), size(P2, 1), 1) - P2, 2);
        D(i, :) = value(:);
    end
%    X1=repmat(sum(P1,2),[1 size(P2,1)]);
%    X2=repmat(sum(P2,2),[1 size(P1,1)]);
%    X2 = X2';

%    D = X1 - X2;
