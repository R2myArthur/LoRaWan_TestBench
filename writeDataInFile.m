function writeDataInFile(file_name, data)
    tamp = fileread(file_name);
    fileID = fopen(file_name,'w');
%     log_data = sprintf('%s%s: %s\n', tamp, datestr(now, 'dd-mmm-yyyy HH:MM:SS:FFF'), data);
    log_data = sprintf('%s %s\n', tamp, data);
    nbytes = fprintf(fileID,'%s', log_data);
    if ( ~(nbytes == strlength(log_data)) )
%         msg = sprintf("ERROR: writing in file: %s \n", file_name);
%         disp(msg);
%         disp(strcat("ERROR: writing in file: ", file_name));
        fprintf("ERROR: writing in file: %s\n", file_name);
    end
    fclose(fileID);
end