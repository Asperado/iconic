function [d, f] = extractDescriptor(img, file_name)

[drop,file_name] = fileparts(file_name);
imwrite(img, sprintf('./temp/%s.jpg', file_name));

% http://koen.me/research/colordescriptors/readme
% detector harrislaplace or densesampling
% descriptor rgbsift


cmdLine = [sprintf('./sift/colorDescriptor ./temp/%s.jpg --outputFormat binary --output ./tdata/%s.data --detector densesampling --ds_spacing 8 --ds_scales 2 --descriptor rgbsift', file_name, file_name)];
system(cmdLine);

[d, f] = readBinaryDescriptors(sprintf('./tdata/%s.data', file_name));
delete(sprintf('./tdata/%s.data', file_name));
delete(sprintf('./temp/%s.jpg', file_name));










