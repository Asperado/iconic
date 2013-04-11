function ret = getStringListFromTxt(txtpath)
    fid = fopen(txtpath, 'r');
    ret = {};
    while(1)
        tline = fgetl(fid);
        if ~ischar(tline)
            break
        end
        ret{end+1} = tline;
    end
    fclose(fid);
end