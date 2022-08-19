function writeToScreenAndFile(data)
    % Write data in log file
    writeDataInFile('log.txt', data);

    % Display data in "Command window"
    disp(data);
end