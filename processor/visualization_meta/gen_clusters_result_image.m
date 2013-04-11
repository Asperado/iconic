function gen_clusters_result_image(clusters_index,...
                                     clusters,...
                                     result_output_root,...
                                     result_name,...
                                     meta_root, ...
                                     varargin)
    opt=varargin2struct(varargin{:});
    database = jsonopt('database', {}, opt);
    top_k_images = jsonopt('top_k_images', 9, opt);
    desc = jsonopt('desc', {}, opt);
    output_prefix = jsonopt('output_prefix', '', opt);
    assert(~isempty(database));
    width = floor(sqrt(top_k_images));
    height = ceil(top_k_images/width);
    
    for iter = 1:length(clusters_index)
        cid = clusters_index(iter);
        image_ids = clusters{cid}.index;
        image_meta = gen_images_meta(image_ids, ...
                                    meta_root, ...
                                    'top_k_images', top_k_images, ...
                                    'database', database, ...
                                    'do_filter', 1);
        imagepath = {};
        for id = 1:length(image_meta)
            imagepath{end + 1} = image_meta{id}.url_m;
        end
        
        all = showImages3(width, height, imagepath);
        
        image_handle = image(all); 
        image_format = 'pdf';
        set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
        set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 5 and height 5.

        axis square;
        axis off;
        if (length(desc) == length(clusters_index))
            title(desc{iter}, 'FontSize', 16);
        end
        
        output_root = sprintf('%s/%s', result_output_root, result_name);
        mkDir(output_root);
        output_path = sprintf('%s/%s%d.%s', output_root, output_prefix, cid, image_format);
        saveas(image_handle, output_path, image_format);
        %imwrite(all, output_path);
    end
end
