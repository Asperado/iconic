%
% Input = image (HxWxD)
% e.g. 
%   im = double(imread('test.jpg')); % Read in image 256x256x3
%   % compute 16x16x16 colour histogram of the image
%   h = getPatchHist(im, 16);
%   
% Output = 1D histogram vector, h
%
%   size(h) ==> (bins^D)x(1)
function h = getPatchHist(clip, bins)

if (nargin <= 1)
   bins = 8;
end


z = size(clip,3);
clip2 = zeros(size(clip,1),size(clip,2));

f = 1;
for i = 1:z
   clip2 = clip2 + f*floor(clip(:,:,i)*bins/256);
   f=f*bins;
end

h = hist(makelinear(clip2), 0:(f-1));
h = h / sum(h);
