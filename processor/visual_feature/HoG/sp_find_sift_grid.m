function sift_arr = sp_find_sift_grid(I, grid_x, grid_y, patch_size)


grid_x = grid_x(:);
grid_y = grid_y(:);



% adapted for HOG feature
num_patches = numel(grid_x)
sift_arr = zeros(num_patches, 108);
% for all patches
for i=1:num_patches   
    % extract the local patches
    lp = I(grid_y(i):grid_y(i)+patch_size-1,grid_x(i):grid_x(i)+patch_size-1);
    H=HOG(lp);
    sift_arr(i,:) = H(:)';
end
