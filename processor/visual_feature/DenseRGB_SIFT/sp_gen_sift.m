function [ff] = sp_gen_sift(imageFName,params)
    try
        I = sp_load_image(imageFName);
    catch 
        fprintf('Broken image %s.\n', imageFName);
        I = round(rand(800,600,3)*100);
    end
    
    if(size(I,3)==1)
        II = zeros(size(I,1),size(I,2),3);
        II(:,:,1)=I;
        II(:,:,2)=I;
        II(:,:,3)=I;
        I = II;
        fprintf('Broken image %s.\n', imageFName);
    else
    end
    
    [hgt wid] = size(I);
    if min(hgt,wid) > params.maxImageSize
        I = imresize(I, params.maxImageSize/min(hgt,wid), 'bicubic');
        fprintf('Loaded %s: original size %d x %d, resizing to %d x %d\n', ...
            imageFName, wid, hgt, size(I,2), size(I,1));
        [hgt wid] = size(I);
    end
    
    [d, f] = extractDescriptor(I, imageFName);
    
    ff.data = d;
    ff.x = f(:,1);% + params.patchSize/2 - 0.5;
    ff.y = f(:,2);% + params.patchSize/2 - 0.5;
    ff.wid = wid;
    ff.hgt = hgt;
end
