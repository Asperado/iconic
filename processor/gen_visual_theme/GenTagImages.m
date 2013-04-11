classdef GenTagImages
    %GENTAGIMAGES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        query = 'bird';
    end
    
    methods
        function Run(obj)
            database = IconicDatabase(obj.query);
            database.GetImageTags([]);
            tags = database.tags_;
            taglist = database.taglist_;
            for i = 1:length(taglist)
                image_ids = find(tags(:, i)==1);
                image_ids = image_ids(1 : min(1000, size(image_ids, 1)));
                GenImageList(image_ids, obj.query, sprintf('tag_%s', obj.query), sprintf('%s', strtrim(taglist{i})), 1, '');
            end
        end
    end
    
end

