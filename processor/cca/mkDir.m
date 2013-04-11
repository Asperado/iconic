function mkDir(folder)
    if (~exist(folder, 'file'))
        try
            cmd = ['mkdir ' '"' folder '"'];
            dos(cmd);
        catch           
            lasterr
            fprintf('XX!! Error with creating the folder %s.\n',folder);
        end
    end
end