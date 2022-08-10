function writeToScreenAndFile(data)
    % Use bultin for sprintf...
    writeDataInFile('log.txt', data);
    disp(data);
end