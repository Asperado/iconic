classdef ImageMetaReader
    %IMAGEMETAREADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [images_meta] = gen_images_meta(obj, ...
                                        images_index, ...
                                         meta_root, ...   
                                         varargin)
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
                    if (~strcmp(image_url.url, info.thumbnail))
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
        function[imagepath] = gen_images_url(obj, ...
                                        images_index, ...
                                         meta_root, ...   
                                         varargin)
            opt=varargin2struct(varargin{:});
            do_filter = jsonopt('do_filter', 0, opt);
            top_k_images = jsonopt('top_k_images', length(images_index), opt);
            is_good_image_list = jsonopt('is_good_image_list', ones(max(images_index), 1), opt);
            database = jsonopt('database', {}, opt);
            assert(~isempty(database));
            assert(length(is_good_image_list) >= max(images_index));            
            [images_meta] = gen_images_meta(images_index, ...
                                             meta_root, ...   
                                             'do_filter', do_filter, ...
                                             'top_k_images', top_k_images, ...
                                             'is_good_image_list', is_good_image_list, ...
                                             'database', database);
            imagepath = {};
            for id = 1:length(images_meta)
                imagepath{end + 1} = images_meta{id}.url_m;
            end
        end
    end
end

