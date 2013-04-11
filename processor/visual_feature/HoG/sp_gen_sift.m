function [ff] = sp_gen_sift(imageFName,params)
    try
        I = sp_load_image(imageFName);
    catch        
        fprintf('Bad Image in loading image %s.\n', imageFName);
        I = round(rand(800,600,3)*100);
    end

    if(size(I,3)==1)
      II = zeros(size(I,1),size(I,2),3);
      II(:,:,1)=I;
      II(:,:,2)=I;
      II(:,:,3)=I;
      I = II;
    else
    end

    [hgt wid aa] = size(I);
    if min(hgt,wid) > params.maxImageSize
        I = imresize(I, params.maxImageSize/min(hgt,wid), 'bicubic');
        fprintf('Loaded %s: original size %d x %d, resizing to %d x %d\n', ...
            imageFName, wid, hgt, size(I,2), size(I,1));
        [hgt wid] = size(I);
    end
    
    [hgt wid aa] = size(I);
    % resize image for HOG when image is too small...
    if min(hgt,wid) <= 100
        I = imresize(I, [200,200], 'bicubic');
        disp('resize image to 200 if it is too small...')
        size(I)
    end
    
    size(I)
    
    [gridX1,gridY1,descrs1] = generateHOG(double(I), params.patchSize);
    [gridX2,gridY2,descrs2] = generateHOG(double(I), params.patchSize*2);
    gridX = [gridX1(:);gridX2(:)];
    gridY = [gridY1(:);gridY2(:)];
    descrs = [descrs1;descrs2];
    
    ff.data = descrs;
    ff.x = gridX(:);% + params.patchSize/2 - 0.5;
    ff.y = gridY(:);% + params.patchSize/2 - 0.5;
    ff.wid = wid;
    ff.hgt = hgt;
end
