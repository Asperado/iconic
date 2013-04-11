function [ A ] = stl_sqrt( A )
%STL_SQRT Summary of this function goes here
%   Detailed explanation goes here
    bin_size = 10000;
    fprintf('begin sqrt.\n');
    tic;
    for i = 1:bin_size:size(A, 2)
        headi = i;
        taili = min(i + bin_size - 1, size(A, 2));
        A(:, headi:taili) = sqrt(A(:, headi:taili));
    end
    toc;
end

