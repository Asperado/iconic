function C = large_scale_multiply(A, B)
    lines = 20000;
    C = zeros(size(A, 1), size(B, 2), 'single');
    fprintf('begin multiply.\n');
    tic;
    for i = 1:lines:size(A, 1)
        i_beg = i;
        i_end = i_beg + lines - 1;
        i_end = min(size(A, 1), i_end);
        a = A(i_beg:i_end, :);
        a = full(a);
        a = a * B;
        C(i_beg:i_end, :) = a;
    end
    toc;
end