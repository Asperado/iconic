%
% [h,mu,sigma] = getPatchSpatiogram_fast(clip,bins,mask)
%    Extract a Spatiogram from an image "clip"
%    Quantise each channel (image band) into "bins" buckets
%    "mask" is an optional parameter: a binary image the same size as "clip"
%    indicating whether each pixel should be included
%
% returns
%   h = 1xB   (histogram part)
%   mu = 2xB  (centroids)
%   sigma = 2x2xB  (variances)
%
% Where B = bins^D, where D is the number of bands in the image (3 for RGB)
%
% Note that all spatial coordinates are normalised to lie between (-1,-1) in the top left
% corner and (1,1) in the bottom right.
%
function [h,mu,sigma] = getPatchSpatiogram_fast(clip,bins,mask)


if (nargin < 7)
    mask=1;
end

z = size(clip,3);
xs = size(clip,2);
ys = size(clip,1);
binno = zeros(ys,xs);

f = 1;
for i = 1:z
   binno = binno + f*floor(clip(:,:,i)*bins/256);
   f=f*bins;
end

xf = 2/(xs-1);
yf = 2/(ys-1);
[xp,yp] = meshgrid(-1:xf:1, -1:yf:1);


kdist = ones(ys,xs) / (xs*ys);
kdist = kdist .* mask;


kdist = kdist / sum(sum(kdist));

MK = min(min(kdist));

h = zeros(1,f);
mu = zeros(2,f);
sigma = zeros(2,2,f);


binno = makelinear(binno);
xp = makelinear(xp);
yp = makelinear(yp);
kdist = makelinear(kdist);

binno = binno+1;

h = accumarray(binno, kdist)';
extra = f-length(h);
h = [h zeros(1,extra)];
wsum = accumarray(binno, kdist)';
wsum = [wsum zeros(1,extra)];
wsum = wsum + (wsum==0);
mu(1,:) = [accumarray(binno, xp.*kdist)' zeros(1,extra)];
mu(2,:) = [accumarray(binno, yp.*kdist)' zeros(1,extra)];

tmp = [accumarray(binno, xp.^2 .* kdist)' zeros(1,extra)] ./ wsum;
tmp = tmp - (mu(1,:)./wsum).^2;
sigma(1,1,:) = permute(tmp, [1 3 2]);
tmp = [accumarray(binno, yp.^2 .* kdist)' zeros(1,extra)] ./ wsum;
tmp = tmp - (mu(2,:)./wsum).^2;
sigma(2,2,:) = permute(tmp, [1 3 2]);

sigma(1,1,:) = sigma(1,1,:) + (MK-sigma(1,1,:)).*(sigma(1,1,:)<MK);
sigma(2,2,:) = sigma(2,2,:) + (MK-sigma(2,2,:)).*(sigma(2,2,:)<MK);

% normalise
mu(1,:) = mu(1,:) ./ wsum;
mu(2,:) = mu(2,:) ./ wsum;


