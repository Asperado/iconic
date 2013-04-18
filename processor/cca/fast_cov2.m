function ret = fast_cov2(A, B)
% blockwise computing A*B'

    fprintf('begin computer cov.\n');
    bin_size = 400;
    ret = zeros(size(A, 2), size(B, 2), 'single');
    mean_a = mean(A);
    mean_b = mean(B);
    mean_a = full(mean_a);
    mean_a = single(mean_a);
    mean_b = full(mean_b);
    mean_b = single(mean_b);
    
    size(A)
    size(B)
    instance_number = size(A, 1);
    for i = 1:bin_size:size(A, 2)
        i
        tic;
        headi = i;
        taili = min(i + bin_size - 1, size(A, 2));
        at = A(:, headi:taili);
        at = full(at);
        at = single(at);
        at = at - repmat(mean_a(:, headi:taili), instance_number, 1);
        at = at';
        for j = 1:bin_size:size(B,2)
            tic;
            headj = j;
            tailj = min(j + bin_size - 1, size(B, 2));
            b = B(:, headj:tailj);
            b = full(b);
            b = single(b);
            b = b - repmat(mean_b(:, headj:tailj), instance_number, 1);
            tmp_cov = at * b;
            ret(headi:taili, headj:tailj) = tmp_cov;
            toc;
        end
        toc;    
    end
end
