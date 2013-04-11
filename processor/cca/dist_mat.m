function D = dist_mat(P1, P2)
% Euclidian distances between vectors
    % P1 = double(P1);
    % P2 = double(P2);
    P1 = single(P1);
    P2 = single(P2);

    X1=repmat(sum(P1.^2,2),[1 size(P2,1)]);
    X2=repmat(sum(P2.^2,2),[1 size(P1,1)]);
    X2 = X2';

    % D= sqrt(X1+X2'-2*R);
    R = P1*P2';
    clear P1;
    clear P2;

    T = X1 + X2;
    clear X1;
    clear X2;
    
    D = T - 2*R;
    clear R;
    clear T;
    D = abs(D);
    T = stl_sqrt(D);
    %T = sqrt(D);
    D = T;
