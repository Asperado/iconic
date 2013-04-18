function [min_val, index] = get_min_dist(feature, dict)
    lines = 20000;
    index = zeros(size(feature, 1), 1);
    min_val = zeros(size(feature, 1), 1);
    fprintf('Get min distance.\n');
    beg_time = tic;
    for i = 1:lines:size(feature, 1)
        line_beg = i;
        line_end = line_beg + lines - 1;
        line_end = min(line_end, size(feature, 1));
        current_feature = feature(line_beg:line_end, :);
        D = dist_mat(current_feature, dict);
        [current_min_val, current_index] = min(D');
        index(line_beg: line_end) = current_index;
        min_val(line_beg: line_end) = current_min_val;
    end
    toc(beg_time);
    fprintf('Get min distance done.\n');
end