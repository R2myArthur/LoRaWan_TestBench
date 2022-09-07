%% Log data in a file and trace in Matlab
% Param
%   data : string or timetable : Data to print
%
% Return nothing

function writeToScreenAndFile(data)
    % Write data in log file
    if ( class(data) == "timetable" )
        writetimetable(data, "log.txt", WriteMode='append', Delimiter='tab');
    else
        writeDataInFile('log.txt', data);
    end

    % Display data in "Command window"
    disp(data);
end