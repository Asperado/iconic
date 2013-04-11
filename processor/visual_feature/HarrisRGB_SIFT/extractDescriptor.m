function [d, f] = extractDescriptor(img, file_name)

[drop,file_name, ext] = fileparts(file_name);
imwrite(img, sprintf('./temp/%s%s', file_name, ext));

% http://koen.me/research/colordescriptors/readme
% detector harrislaplace or densesampling
% descriptor rgbsift


cmdLine = [sprintf('./sift/colorDescriptor ./temp/%s%s --outputFormat binary --output ./tdata/%s.data --detector harrislaplace --ds_spacing 8 --ds_scales 2 --descriptor rgbsift', file_name, ext, file_name)]
system(cmdLine);

[d, f] = readBinaryDescriptors(sprintf('./tdata/%s.data', file_name));
delete(sprintf('./tdata/%s.data', file_name));
delete(sprintf('./temp/%s%s', file_name, ext));










