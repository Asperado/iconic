function state = filewrite(char_doc, filepath)
    try
        [file_dir, drop] = fileparts(filepath);
        if (~exist(file_dir, 'file'))
            mkdir(file_dir);
        end
        fout = fopen(filepath, 'w');
        fprintf(fout, char_doc);
        fclose(fout);
    catch
        state = 0;
        return;
    end
    state = 1;
end

