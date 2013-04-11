function [ff] = sp_gen_sift(imageFName,params)
    [file_dir, file_name, ext] = fileparts(imageFName);

    bad_image = 0;
    if (strcmp(ext, '.gif'))
      bad_image = 1;
      imageFName = sprintf('%s/%s.jpg', file_dir, file_name);
      fprintf('ERROR: Bad image, cannot load gif format file %s\n', imageFName);
    end

    if (bad_image) 
        I = round(rand(800,600,3)*100);
    else 
      try
        I = sp_load_image(imageFName);
      catch 
        fprintf('ERROR: Bad image, cannot load %s\n', imageFName);
        I = round(rand(800,600,3)*100);
      end
    end

    if(size(I,3)==1)
        II = zeros(size(I,1),size(I,2),3);
        II(:,:,1)=I;
        II(:,:,2)=I;
        II(:,:,3)=I;
        I = II;
        fprintf('ERROR: Bad image %s.\n', imageFName);
    end

    [hgt wid] = size(I);
    original_I = I;
    if min(hgt,wid) > params.maxImageSize
        I = imresize(I, params.maxImageSize/min(hgt,wid), 'bicubic');
        fprintf('Loaded %s: original size %d x %d, resizing to %d x %d\n', ...
            imageFName, wid, hgt, size(I,2), size(I,1));
        [hgt wid] = size(I);
    end

    try
      [d, f] = extractDescriptor(I, imageFName);
    catch
      fprintf('ERROR: unable to extract descriptor from resize image, try original image.\n');
      [d, f] = extractDescriptor(original_I, imageFName);
    end

    ff.data = d;
    ff.x = f(:,1);% + params.patchSize/2 - 0.5;
    ff.y = f(:,2);% + params.patchSize/2 - 0.5;
    ff.wid = wid;
    ff.hgt = hgt;
end
