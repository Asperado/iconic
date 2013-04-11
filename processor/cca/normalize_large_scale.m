function a = normalize_large_scale(a)
    batch_size = 10000;

    for i = 1:batch_size:size(a, 1)
        row_beg = i;
        row_end = row_beg + batch_size;
        row_end = min(row_end, size(a, 1));
        t = a(row_beg:row_end, :);
        a(row_beg:row_end, :) = Normalize(t);
    end
end