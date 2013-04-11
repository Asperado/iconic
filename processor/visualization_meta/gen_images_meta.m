function [images_meta] = gen_images_meta(images_index, ...
                                         meta_root, ...   
                                         varargin)
%                                         database, ...
%                                         top_k_images, ...
%                                         do_filter, ...
%                                         is_good_image_list)
% images_meta is an array containing the images meta.
% to do:
%    1. output the image meta to json file.
%    2. output the node infomation to json file, the node info is generally in tree format.
%    
    images_meta = {};
    if (isempty(images_index))
        return;
    end
    
    opt=varargin2struct(varargin{:});
    do_filter = jsonopt('do_filter', 0, opt);
    top_k_images = jsonopt('top_k_images', length(images_index), opt);
    is_good_image_list = jsonopt('is_good_image_list', ones(max(images_index), 1), opt);
    database = jsonopt('database', {}, opt);
    assert(~isempty(database));
    assert(length(is_good_image_list) >= max(images_index));

    
    images_id = database.get_image_ids(images_index);
    for i = 1:length(images_id)
        image_id = images_id{i};
        try 
            image_meta = get_image_meta(image_id, meta_root);
        catch
            continue;
        end
        is_good_image = 1;
        if (do_filter)
            try
                [drop, image_url] = urlread2(image_meta.thumbnail);
            catch
                fprintf('Exception occor, skip bad image.\n');
                is_good_image = 0;
            end
            if (~strcmp(image_url.url, image_meta.thumbnail))
                fprintf('Skip bad image.\n');
                is_good_image = 0;
            end               
        end
        if (~is_good_image_list(image_id))
            is_good_image = 0;
        end
        if (is_good_image)
            images_meta{end + 1} = image_meta;
            if (length(images_meta) == top_k_images)
                break;
            end       
        end
    end
end

