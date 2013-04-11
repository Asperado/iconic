function [d , f]= readBinaryDescriptors(str)

fid = fopen(str,'rb');             % Open binary file
m = char(fread(fid,16,'uint8'));   % header BINDESC1 + datatype
Z1=fread(fid,4,'uint32');
elementsPerPoint = Z1(1);
dimensionCount = Z1(2);
pointCount = Z1(3);
bytesPerElement = Z1(4);

aa=fread(fid, elementsPerPoint * pointCount, 'double');
bb=fread(fid, dimensionCount * pointCount, 'double');

% if image is blank, fake the features (all zero) to avoid exception
if(isempty(aa))
    f = [0,0];
else
    f = my_vec2mat(aa, elementsPerPoint);
end

if(isempty(bb))
    d = zeros(1,128);
else
    d = my_vec2mat(bb, dimensionCount);
end

fclose(fid);


function b = my_vec2mat(c, nc)
b = reshape([c(:) ; zeros(rem(nc - rem(numel(c),nc),nc),1)],nc,[]).';