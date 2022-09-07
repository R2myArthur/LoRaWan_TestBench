%% Save string data in a specified file
% Param
%   data      : string : Data to print
%   file_name : string : Address of the file to write (ex:'log.txt')
%
% Return nothing

function writeDataInFile(file_name, data)
    % Open file in Append and create if not exist
    fileID = fopen(file_name,'a+');
    
    % Add EOL
    log_data = sprintf('%s\n', data);
    
    % Write in the file
    nbytes = fprintf(fileID,'%s', log_data);
    
    % Verify all data has been written in the file
    if ( ~(nbytes == strlength(log_data)) )
        disp(strcat("ERROR: writing in file: ", file_name));
        fprintf("ERROR: writing in file: %s\n", file_name);
    end

    % Close file
    fclose(fileID);
end