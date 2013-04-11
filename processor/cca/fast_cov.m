function ret = fast_cov(A)
    fprintf('begin computer cov.\n');
    bin_size = 1500;
    ret = zeros(size(A, 2), size(A, 2), 'single');
    for i = 1:bin_size:size(A, 2)
        tic;
        headi = i;
        taili = min(i + bin_size - 1, size(A, 2));
        at = A(:, headi:taili)';
        at = full(at);
        at = single(at);
        for j = 1:bin_size:size(A,2)
            headj = j;
            tailj = min(j + bin_size - 1, size(A, 2));
            a = A(:, headj:tailj);
            a = full(a);
            a = single(a);
            tmp_cov = at * a;
            ret(headi:taili, headj:tailj) = tmp_cov;
        end
        toc;    
    end
end