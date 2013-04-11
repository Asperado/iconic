function image_data = get_image_meta(image_id, meta_root)
%  get_image_meta('00000000_2679625914', 'C:/Iconic/data/meta/love')

    filepath = sprintf('%s/%s/%s.txt', meta_root, image_id(1:5), image_id);
    image_raw = getStringListFromTxt(filepath);

    image_data = {};
    for i = 1:length(image_raw)

        photo_fields = strread(char(image_raw{i}), '%s', 'delimiter', ':');
        if (isempty(photo_fields))
            continue;
        end
        key = photo_fields{1};
        value = image_raw{i}(length(key) + 2:end);
        value = strtrim(value);
        q = char(39);
        value = regexprep(value, q, ' ');
        value = regexprep(value, char(34), ' ');
%        q = char(47);
%        value = regexprep(value, q, ' ');
%        q = char(92);
%        value = regexprep(value, q, ' ');
        value = strrep(value, '%', ' ');
        exp = sprintf('image_data.%s=%s%s%s;', char(key), q, char(value), q);
        eval(exp);
    end
    image_data.thumbnail = strrep(image_data.url, '_z.jpg', '_s.jpg');
    image_data.thumbnail = strrep(image_data.thumbnail, '_o.jpg', '_s.jpg');
end

