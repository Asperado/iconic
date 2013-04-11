function [gridX,gridY,descrs] = generateHOG(I, patchSize)


d = features(double(I), patchSize);
xmax = size(d,1);
ymax = size(d,2);
n = 1;
for xx=1:xmax-1
    for yy=1:ymax-1
        gridX(n) = 1+ size(I,2) / xmax * xx;
        gridY(n) = 1+ size(I,1) / ymax * yy;
        descrs(n, 1:31) = double( min(d(xx,yy,:),1) * 255);
        descrs(n, 32:62) = double( min(d(xx+1,yy,:),1) * 255);
        descrs(n, 63:93) = double( min(d(xx,yy+1,:),1) * 255);
        descrs(n, 94:124) = double( min(d(xx+1,yy+1,:),1) * 255);
        n=n+1;
    end
end
